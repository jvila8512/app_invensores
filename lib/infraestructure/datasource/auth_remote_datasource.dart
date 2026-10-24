// lib/infraestructure/datasource/auth_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/domain/entities/account.dart';
import 'package:etecsa_supervision/infraestructure/model/json_read.dart';

/// Implementacion real del contrato de auth contra el backend (design D3).
///
/// El token se devuelve tal cual: persistirlo en `flutter_secure_storage` y
/// adjuntarlo a cada peticion es responsabilidad de WU5.
class AuthRemoteDatasource implements AuthDatasource {
  AuthRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<String> authenticate({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/authenticate',
        data: <String, dynamic>{
          'username': username,
          'password': password,
          'rememberMe': rememberMe,
        },
      );
      final body = response.data;
      final token =
          readString(body, 'id_token') ??
          _bearerToken(response.headers.value('authorization'));
      if (token == null || token.isEmpty) {
        throw const AuthException('El backend no devolvio un token.');
      }
      return token;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw const AuthException('Credenciales invalidas.');
      }
      rethrow;
    }
  }

  @override
  Future<Account> fetchAccount() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/account');
    final body = response.data ?? const <String, dynamic>{};
    return Account(
      id: readInt(body, 'id'),
      login: readString(body, 'login'),
      activated: readBool(body, 'activated'),
      authorities: readStringList(body, 'authorities'),
    );
  }

  String? _bearerToken(String? header) {
    if (header == null) return null;
    final value = header.trim();
    if (value.toLowerCase().startsWith('bearer ')) {
      return value.substring(7).trim();
    }
    return value.isEmpty ? null : value;
  }
}
