// lib/domain/policy/jwt_decoder.dart

import 'dart:convert';

/// Decodificacion minima del JWT para la sesion (spec §1 "Proactive expiry
/// check"): leer `exp` y decidir si hay que ir a `/login` SIN tocar el
/// backend. Pure Dart, sin dependencias.
class JwtDecoder {
  const JwtDecoder._();

  /// `exp` (segundos desde epoch) como UTC, o `null` si el token, el
  /// payload o el claim no se pueden leer. Nunca lanza excepcion.
  static DateTime? expirationDate(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final payload = jsonDecode(_decodeBase64Url(parts[1]));
      if (payload is! Map<String, dynamic>) return null;
      final exp = payload['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }

  /// `true` cuando el token ya vencio (`now >= exp`, spec §1) o no se pudo
  /// validar: sin `exp` verificable no hay sesion confiable => login.
  static bool isExpired(String? token, {required DateTime now}) {
    final exp = expirationDate(token);
    if (exp == null) return true;
    return !now.isBefore(exp);
  }

  static String _decodeBase64Url(String segment) {
    final normalized = segment.replaceAll('-', '+').replaceAll('_', '/');
    final pad = (4 - normalized.length % 4) % 4;
    final padded = normalized.padRight(normalized.length + pad, '=');
    return utf8.decode(base64.decode(padded));
  }
}
