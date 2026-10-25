// test/presentation/auth_session_provider_test.dart

import 'package:dio/dio.dart';
import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/domain/entities/account.dart';
import 'package:etecsa_supervision/domain/repository/auth_repository.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_holder.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_storage.dart';
import 'package:etecsa_supervision/presentation/provider/auth_session_provider.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio de prueba con errores inyectables.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.login = 'admin'});

  final String login;

  /// Error que lanza [authenticate].
  Object? loginError;

  /// Error que lanza [fetchAccount] (simula un JWT vencido).
  Object? accountError;

  int authenticateCalls = 0;
  int fetchAccountCalls = 0;

  @override
  Future<String> authenticate({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    authenticateCalls++;
    final error = loginError;
    if (error != null) throw error;
    return 'jwt-de-$username';
  }

  @override
  Future<Account> fetchAccount() async {
    fetchAccountCalls++;
    final error = accountError;
    if (error != null) throw error;
    return Account(id: 1, login: login, activated: true, authorities: const [
      'ROLE_ADMIN',
    ]);
  }
}

ProviderContainer _container({
  required AuthRepository repository,
  TokenStorage? storage,
  TokenHolder? holder,
}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      tokenStorageProvider.overrideWithValue(storage ?? InMemoryTokenStorage()),
      tokenHolderProvider.overrideWithValue(holder ?? TokenHolder()),
    ],
  );
}

void main() {
  test('arranca sin sesión cuando no hay token guardado', () async {
    final container = _container(repository: _FakeAuthRepository());
    addTearDown(container.dispose);

    final session = await container.read(authSessionProvider.future);

    expect(session.status, AuthStatus.unauthenticated);
    expect(session.isAuthenticated, isFalse);
  });

  test('restaura la sesión desde el token guardado y resuelve la cuenta', () async {
    final storage = InMemoryTokenStorage();
    await storage.write('jwt-guardado');
    final repository = _FakeAuthRepository(login: 'operador');
    final container = _container(repository: repository, storage: storage);
    addTearDown(container.dispose);

    final session = await container.read(authSessionProvider.future);

    expect(session.status, AuthStatus.authenticated);
    expect(session.account?.login, 'operador');
    expect(session.token, 'jwt-guardado');
    expect(repository.fetchAccountCalls, 1);
    // El token quedó en el holder para que el interceptor lo adjunte.
    expect(container.read(tokenHolderProvider).token, 'jwt-guardado');
  });

  test('un token rechazado por el backend cierra la sesión y borra el token', () async {
    final storage = InMemoryTokenStorage();
    await storage.write('jwt-vencido');
    final holder = TokenHolder();
    final repository = _FakeAuthRepository()
      ..accountError = const AuthException('Sesión expirada.');
    final container = _container(
      repository: repository,
      storage: storage,
      holder: holder,
    );
    addTearDown(container.dispose);

    final session = await container.read(authSessionProvider.future);

    expect(session.status, AuthStatus.unauthenticated);
    expect(await storage.read(), isNull, reason: 'token guardado borrado');
    expect(holder.hasToken, isFalse, reason: 'holder en memoria limpio');
  });

  test('un fallo de red al restaurar también deja sin sesión', () async {
    final storage = InMemoryTokenStorage();
    await storage.write('jwt-guardado');
    final repository = _FakeAuthRepository()
      ..accountError = DioException(
        requestOptions: RequestOptions(path: '/api/account'),
        type: DioExceptionType.connectionTimeout,
      );
    final container = _container(repository: repository, storage: storage);
    addTearDown(container.dispose);

    final session = await container.read(authSessionProvider.future);

    expect(session.status, AuthStatus.unauthenticated);
    expect(await storage.read(), isNull);
  });

  test('login exitoso autentica, publica el token y persiste el JWT', () async {
    final storage = InMemoryTokenStorage();
    final repository = _FakeAuthRepository(login: 'admin');
    final container = _container(repository: repository, storage: storage);
    addTearDown(container.dispose);

    final session = await container
        .read(authSessionProvider.notifier)
        .login(username: 'admin', password: 's3cret', rememberMe: true);

    expect(session.status, AuthStatus.authenticated);
    expect(session.account?.login, 'admin');
    expect(repository.authenticateCalls, 1);
    expect(repository.fetchAccountCalls, 1);
    expect(await storage.read(), 'jwt-de-admin');
    expect(container.read(tokenHolderProvider).token, 'jwt-de-admin');
    expect(
      container.read(authSessionProvider).value?.isAuthenticated,
      isTrue,
      reason: 'el estado del provider quedó autenticado',
    );
  });

  test('credenciales rechazadas lanzan AuthException sin cambiar la sesión', () async {
    final storage = InMemoryTokenStorage();
    final repository = _FakeAuthRepository()
      ..loginError = const AuthException('Credenciales inválidas.');
    final container = _container(repository: repository, storage: storage);
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(authSessionProvider.notifier)
          .login(username: 'admin', password: 'mala'),
      throwsA(isA<AuthException>()),
    );

    expect(container.read(authSessionProvider).value?.status,
        AuthStatus.unauthenticated);
    expect(await storage.read(), isNull, reason: 'nada persistido');
    expect(container.read(tokenHolderProvider).hasToken, isFalse);
  });

  test('logout limpia el token en memoria y el almacenamiento', () async {
    final storage = InMemoryTokenStorage();
    await storage.write('jwt-viejo');
    final holder = TokenHolder()..set('jwt-viejo');
    final container = _container(
      repository: _FakeAuthRepository(),
      storage: storage,
      holder: holder,
    );
    addTearDown(container.dispose);
    await container.read(authSessionProvider.future);

    await container.read(authSessionProvider.notifier).logout();

    expect(
      container.read(authSessionProvider).value?.status,
      AuthStatus.unauthenticated,
    );
    expect(holder.hasToken, isFalse);
    expect(await storage.read(), isNull);
  });

  test('la señal de 401 del interceptor deja la sesión sin autenticar', () async {
    final storage = InMemoryTokenStorage();
    await storage.write('jwt-1');
    final container = _container(
      repository: _FakeAuthRepository(),
      storage: storage,
    );
    addTearDown(container.dispose);
    final authenticated = await container.read(authSessionProvider.future);
    expect(authenticated.isAuthenticated, isTrue);

    // El interceptor publica la expiración...
    container.read(unauthorizedSignalProvider).notify();
    // ...se difiere en un microtask para no chocar con un build en curso.
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(authSessionProvider).value?.status,
      AuthStatus.unauthenticated,
    );
  });
}
