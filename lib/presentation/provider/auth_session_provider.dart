// lib/presentation/provider/auth_session_provider.dart

import 'package:dio/dio.dart';
import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/domain/entities/account.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de la sesion (spec §1).
enum AuthStatus {
  /// Arrancando: leyendo el token guardado / resolviendo `GET /api/account`.
  restoring,

  /// Sesión válida: hay JWT y cuenta resuelta.
  authenticated,

  /// Sin sesión: hay que mostrar el login.
  unauthenticated,
}

class AuthSession {
  const AuthSession._(this.status, {this.token, this.account});

  const AuthSession.restoring() : this._(AuthStatus.restoring);

  const AuthSession.unauthenticated() : this._(AuthStatus.unauthenticated);

  const AuthSession.authenticated({
    required String token,
    required Account account,
  }) : this._(AuthStatus.authenticated, token: token, account: account);

  final AuthStatus status;
  final String? token;
  final Account? account;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get isRestoring => status == AuthStatus.restoring;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthSession &&
        other.status == status &&
        other.token == token &&
        other.account == account;
  }

  @override
  int get hashCode => Object.hash(status, token, account);

  @override
  String toString() => 'AuthSession($status, login: ${account?.login})';
}

/// Ciclo de vida del JWT: arranque, login, logout y expiracion.
///
/// El backend no ofrece refresh token (TTL 24 h), asi que un token vencido
/// o un 401 en cualquier endpoint conducen al login (spec §1).
class AuthSessionNotifier extends AsyncNotifier<AuthSession> {
  @override
  Future<AuthSession> build() async {
    final holder = ref.watch(tokenHolderProvider);
    final storage = ref.watch(tokenStorageProvider);
    final signal = ref.watch(unauthorizedSignalProvider);

    signal.addListener(_handleUnauthorized);
    ref.onDispose(() => signal.removeListener(_handleUnauthorized));

    final token = holder.hasToken ? holder.token : await storage.read();
    if (token == null || token.isEmpty) {
      return const AuthSession.unauthenticated();
    }

    // Se publica antes de consultar la cuenta: el interceptor lo adjunta.
    holder.set(token);
    try {
      final account = await ref.watch(authRepositoryProvider).fetchAccount();
      return AuthSession.authenticated(token: token, account: account);
    } catch (error) {
      holder.clear();
      await storage.delete();
      if (error is AuthException || error is DioException) {
        // Token vencido, revocado o backend caido: sin sesión.
        return const AuthSession.unauthenticated();
      }
      rethrow;
    }
  }

  /// Abre sesión con usuario y contraseña y persiste el JWT.
  ///
  /// Lanza [AuthException] si el backend rechaza las credenciales; en ese
  /// caso el estado no cambia y la pantalla de login muestra el mensaje.
  Future<AuthSession> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final holder = ref.read(tokenHolderProvider);
    final storage = ref.read(tokenStorageProvider);

    final token = await repository.authenticate(
      username: username,
      password: password,
      rememberMe: rememberMe,
    );

    // El token se publica ANTES de /api/account para que el interceptor lo
    // adjunte a esa misma peticion.
    holder.set(token);
    await storage.write(token);

    try {
      final account = await repository.fetchAccount();
      final session = AuthSession.authenticated(token: token, account: account);
      state = AsyncData<AuthSession>(session);
      return session;
    } catch (error) {
      holder.clear();
      await storage.delete();
      rethrow;
    }
  }

  /// Cierra la sesión locally y borra el token guardado.
  Future<void> logout() async {
    ref.read(tokenHolderProvider).clear();
    await ref.read(tokenStorageProvider).delete();
    state = const AsyncData<AuthSession>(AuthSession.unauthenticated());
  }

  /// Reaccion al 401 emitido por el interceptor.
  ///
  /// Se difiere un microtask porque el 401 puede llegar mientras el propio
  /// `build` esta resolviendo `GET /api/account`, y en ese caso no se puede
  /// modificar el estado del provider todavia.
  void _handleUnauthorized() {
    Future.microtask(() {
      try {
        state = const AsyncData<AuthSession>(AuthSession.unauthenticated());
      } catch (_) {
        // Provider ya desmontado: nada que actualizar.
      }
    });
  }
}

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, AuthSession>(
      AuthSessionNotifier.new,
    );
