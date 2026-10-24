// lib/infraestructure/datasource/auth_fake_datasource.dart

import 'dart:convert';

import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/domain/entities/account.dart';

/// Auth fake para la demo offline (spec §5).
///
/// Acepta cualquier usuario/contrasena no vacios y devuelve un JWT sin firma
/// con `exp` en el ano 2100, de modo que la sesion fake nunca vence y
/// `JwtDecoder` puede leerlo sin tocar el backend.
class FakeAuthDatasource implements AuthDatasource {
  FakeAuthDatasource({
    this.login = 'admin',
    this.authorities = const <String>['ROLE_ADMIN'],
  });

  final String login;
  final List<String> authorities;

  /// 2100-01-01T00:00:00Z: caducidad lejana para la demo.
  static const int fakeExpEpochSeconds = 4102444800;

  @override
  Future<String> authenticate({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    if (username.trim().isEmpty || password.isEmpty) {
      throw const AuthException('Usuario y contrasena son obligatorios.');
    }
    return _fakeToken(username.trim());
  }

  @override
  Future<Account> fetchAccount() async =>
      Account(id: 1, login: login, activated: true, authorities: authorities);

  String _fakeToken(String subject) {
    final header = _segment(<String, Object?>{'alg': 'none', 'typ': 'JWT'});
    final payload = _segment(<String, Object?>{
      'sub': subject,
      'auth': authorities.isEmpty ? null : authorities.first,
      'exp': fakeExpEpochSeconds,
    });
    return '$header.$payload.';
  }

  String _segment(Map<String, Object?> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
}
