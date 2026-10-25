// test/presentation/login_screen_test.dart

import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/domain/entities/account.dart';
import 'package:etecsa_supervision/domain/repository/auth_repository.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_holder.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_storage.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:etecsa_supervision/presentation/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.loginError});

  final Object? loginError;

  int authenticateCalls = 0;

  @override
  Future<String> authenticate({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    authenticateCalls++;
    final error = loginError;
    if (error != null) throw error;
    return 'jwt-ok';
  }

  @override
  Future<Account> fetchAccount() async =>
      const Account(id: 1, login: 'admin', activated: true);
}

Widget _app(AuthRepository repository) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
      tokenHolderProvider.overrideWithValue(TokenHolder()),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

Future<void> _fillCredentials(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(2));
  await tester.enterText(fields.at(0), 'admin');
  await tester.enterText(fields.at(1), 'secreto');
}

void main() {
  testWidgets('valida los dos campos vacíos antes de llamar al backend', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Ingresá el usuario'), findsOneWidget);
    expect(find.text('Ingresá la contraseña'), findsOneWidget);
    expect(repository.authenticateCalls, 0, reason: 'no se llamó al backend');
  });

  testWidgets('muestra el error del backend bajo el formulario', (
    tester,
  ) async {
    final repository = _FakeAuthRepository(
      loginError: const AuthException('Credenciales inválidas.'),
    );
    await tester.pumpWidget(_app(repository));
    await _fillCredentials(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(find.text('Credenciales inválidas.'), findsOneWidget);
    expect(repository.authenticateCalls, 1);
  });

  testWidgets('login exitoso no muestra error y llama al backend una sola vez', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_app(repository));
    await _fillCredentials(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error')), findsNothing);
    expect(repository.authenticateCalls, 1);
  });
}
