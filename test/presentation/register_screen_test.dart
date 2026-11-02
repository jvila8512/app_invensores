// test/presentation/register_screen_test.dart

import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/domain/entities/account.dart';
import 'package:etecsa_supervision/domain/repository/auth_repository.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_holder.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_storage.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:etecsa_supervision/presentation/screen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.registerError});

  final Object? registerError;

  int authenticateCalls = 0;

  @override
  Future<String> authenticate({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    authenticateCalls++;
    final error = registerError;
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
    child: const MaterialApp(home: RegisterScreen()),
  );
}

Future<void> _fillForm(WidgetTester tester, {String? confirm}) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(4));
  await tester.enterText(fields.at(0), 'operador');
  await tester.enterText(fields.at(1), 'operador@etecsa.cu');
  await tester.enterText(fields.at(2), 'secreto123');
  await tester.enterText(fields.at(3), confirm ?? 'secreto123');
}

void main() {
  testWidgets('valida los campos vacíos antes de llamar al backend', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();

    expect(find.text('Ingresá el usuario'), findsOneWidget);
    expect(find.text('Ingresá el correo'), findsOneWidget);
    expect(find.text('Ingresá la contraseña'), findsOneWidget);
    expect(find.text('Confirmá la contraseña'), findsOneWidget);
    expect(repository.authenticateCalls, 0, reason: 'no se llamó al backend');
  });

  testWidgets('rechaza contraseñas que no coinciden', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_app(repository));
    await _fillForm(tester, confirm: 'otra-clave');

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(repository.authenticateCalls, 0);
  });

  testWidgets('muestra el error del backend bajo el formulario', (
    tester,
  ) async {
    final repository = _FakeAuthRepository(
      registerError: const AuthException('Usuario ya existe.'),
    );
    await tester.pumpWidget(_app(repository));
    await _fillForm(tester);

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('register-error')), findsOneWidget);
    expect(find.text('Usuario ya existe.'), findsOneWidget);
    expect(repository.authenticateCalls, 1);
  });

  testWidgets('registro exitoso no muestra error y llama una sola vez', (
    tester,
  ) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_app(repository));
    await _fillForm(tester);

    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('register-error')), findsNothing);
    expect(repository.authenticateCalls, 1);
  });
}
