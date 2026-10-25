// lib/infraestructure/auth/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_holder.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_storage.dart';

/// Adjunta `Authorization: Bearer <jwt>` a cada peticion y gestiona el 401
/// (spec §1: "401 en cualquier endpoint => token limpiado => login").
///
/// El backend no tiene refresh token, asi que un 401 significa sesión
/// expirada o revocada: se limpia el holder, se borra el almacenamiento
/// seguro y se avisa via [onUnauthorized] para que la sesión pase a
/// no autenticada y el router redirija al login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenHolder holder,
    required TokenStorage storage,
    void Function()? onUnauthorized,
  }) : _holder = holder,
       _storage = storage,
       _onUnauthorized = onUnauthorized;

  final TokenHolder _holder;
  final TokenStorage _storage;
  final void Function()? _onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _holder.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && _holder.hasToken) {
      _holder.clear();
      await _storage.delete();
      _onUnauthorized?.call();
    }
    handler.next(err);
  }
}
