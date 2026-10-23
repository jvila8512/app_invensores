import 'dart:convert';

import 'package:etecsa_supervision/domain/policy/jwt_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

/// JWT sintetico con el mismo formato que manda el backend
/// (`{header}.{payload}.{firma}`, base64url sin relleno).
String buildJwt({required Map<String, dynamic> payload}) {
  String encode(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS512'})}.${encode(payload)}.firma-de-prueba';
}

void main() {
  final now = DateTime.utc(2026, 6, 17, 12);

  group('JwtDecoder.expirationDate', () {
    test('decodifica exp como UTC', () {
      final token = buildJwt(payload: {'sub': 'admin', 'exp': 1781707200});
      expect(
        JwtDecoder.expirationDate(token),
        DateTime.fromMillisecondsSinceEpoch(1781707200 * 1000, isUtc: true),
      );
    });

    test('token, payload o exp ilegibles => null, sin excepcion', () {
      expect(JwtDecoder.expirationDate(null), isNull);
      expect(JwtDecoder.expirationDate(''), isNull);
      expect(JwtDecoder.expirationDate('no-es-un-jwt'), isNull);
      expect(JwtDecoder.expirationDate('a.b'), isNull);
      expect(
        JwtDecoder.expirationDate(buildJwt(payload: {'sub': 'admin'})),
        isNull,
      );
      expect(
        JwtDecoder.expirationDate(buildJwt(payload: {'exp': 'ayer'})),
        isNull,
      );
    });
  });

  group('JwtDecoder.isExpired (spec §1)', () {
    test('exp en el pasado => vencido (sin pedir al backend)', () {
      final token = buildJwt(payload: {'exp': now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000});
      expect(JwtDecoder.isExpired(token, now: now), isTrue);
    });

    test('exp en el futuro => vigente', () {
      final token = buildJwt(payload: {'exp': now.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000});
      expect(JwtDecoder.isExpired(token, now: now), isFalse);
    });

    test('en el instante exacto de exp ya esta vencido (now >= exp)', () {
      final token = buildJwt(payload: {'exp': now.millisecondsSinceEpoch ~/ 1000});
      expect(JwtDecoder.isExpired(token, now: now), isTrue);
    });

    test('token ilegible => vencido (no hay sesion confiable)', () {
      expect(JwtDecoder.isExpired('roto', now: now), isTrue);
      expect(JwtDecoder.isExpired(null, now: now), isTrue);
      expect(JwtDecoder.isExpired('', now: now), isTrue);
    });
  });
}
