// lib/domain/datasources/auth_datasource.dart

import 'package:etecsa_supervision/domain/entities/account.dart';

/// Error de autenticacion legible por la capa de presentacion (spec §1).
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Contrato de autenticacion: login contra el backend y cuenta actual.
///
/// El almacenamiento seguro del token y el interceptor de `Authorization`
/// los aporta la capa de infraestructura (WU5); esta interfaz solo define
/// el intercambio de datos.
abstract class AuthDatasource {
  /// `POST /api/authenticate`: devuelve el JWT (`id_token` del body o
  /// `Authorization` de la respuesta).
  Future<String> authenticate({
    required String username,
    required String password,
    bool rememberMe = false,
  });

  /// `GET /api/account`: login y authorities de la sesion actual.
  Future<Account> fetchAccount();
}
