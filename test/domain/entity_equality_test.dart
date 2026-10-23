import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/domain/entities/sitio.dart';
import 'package:etecsa_supervision/infraestructure/mapper/inversor_mapper.dart';
import 'package:etecsa_supervision/infraestructure/mapper/lectura_inversor_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  group('LecturaInversor — igualdad de valores (spec §3 / task 3.3)', () {
    test('dos lecturas con los mismos campos son iguales', () {
      final a = LecturaInversorMapper.fromJson(fullDatoInversorJson());
      final b = LecturaInversorMapper.fromJson(fullDatoInversorJson());
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('instancias distintas del mismo valor funcionan como clave de mapa',
        () {
      // Esto es exactamente lo que hace el `select` por tarjeta del
      // dashboard: si el valor no cambio, la tarjeta NO se reconstruye.
      final a = LecturaInversorMapper.fromJson(fullDatoInversorJson());
      final b = LecturaInversorMapper.fromJson(fullDatoInversorJson());
      final map = <LecturaInversor, String>{a: 'tarjeta'};
      expect(map[b], 'tarjeta');
      expect(map.containsKey(b), isTrue);
    });

    test('un solo campo distinto rompe la igualdad', () {
      final base = LecturaInversorMapper.fromJson(fullDatoInversorJson());

      final sinPotencia = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'pvPotenciaW': null,
      });
      expect(base == sinPotencia, isFalse);

      final otraPotencia = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'pvPotenciaW': 44000.0,
      });
      expect(base == otraPotencia, isFalse);

      final otroTiempo = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'tiempo': '2026-06-17T10:00:01Z',
      });
      expect(base == otroTiempo, isFalse);

      final otroModo = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'modoOperacion': 'SOLAR',
      });
      expect(base == otroModo, isFalse);

      final otroId = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'id': 8,
      });
      expect(base == otroId, isFalse);
    });

    test('null y 0 NO son iguales (el 0 nunca sustituye a un ausente)', () {
      final conCero = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'codigoFallo': 0,
      });
      final sinCodigo = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'codigoFallo': null,
      });
      expect(conCero == sinCodigo, isFalse);
      expect(sinCodigo.codigoFallo, isNull);
      expect(conCero.codigoFallo, 0);
    });

    test('lecturas 100% nulas entre si son iguales', () {
      final a = LecturaInversorMapper.fromJson(allNullDatoInversorJson());
      final b = LecturaInversorMapper.fromJson(allNullDatoInversorJson());
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('Inversor — igualdad de valores (task 3.3)', () {
    test('dos inversores con el mismo contenido son iguales', () {
      final a = InversorMapper.fromJson(fullInversorJson());
      final b = InversorMapper.fromJson(fullInversorJson());
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('relacion de sitio distinta rompe la igualdad', () {
      const a = Inversor(id: 1, nombre: 'INV', sitio: Sitio(id: 1, nombre: 'Norte'));
      const b = Inversor(id: 1, nombre: 'INV', sitio: Sitio(id: 1, nombre: 'Sur'));
      expect(a == b, isFalse);
    });

    test('un solo escalar distinto rompe la igualdad', () {
      final base = InversorMapper.fromJson(fullInversorJson());
      final otro = InversorMapper.fromJson({
        ...fullInversorJson(),
        'slaveId': 4,
      });
      expect(base == otro, isFalse);

      final sinMaster = InversorMapper.fromJson({
        ...fullInversorJson(),
        'masterReferencia': null,
      });
      expect(base == sinMaster, isFalse);
    });

    test('dos inversores sin sitio construidos a mano son iguales', () {
      const a = Inversor(id: 1, nombre: 'Huerfano');
      const b = Inversor(id: 1, nombre: 'Huerfano');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('tipos distintos nunca son iguales', () {
    test('Inversor != LecturaInversor', () {
      final inversor = InversorMapper.fromJson(fullInversorJson());
      final lectura = LecturaInversorMapper.fromJson(fullDatoInversorJson());
      expect(inversor, isNot(equals(lectura)));
      expect(lectura, isNot(equals(inversor)));
    });

    test('entidades contra null y contra otros objetos', () {
      final lectura = LecturaInversorMapper.fromJson(fullDatoInversorJson());
      expect(lectura, isNot(equals(null)));
      expect(lectura, isNot(equals('texto')));
    });
  });
}
