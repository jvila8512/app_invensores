import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/infraestructure/mapper/lectura_inversor_mapper.dart';
import 'package:etecsa_supervision/infraestructure/model/dato_inversor_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  group('LecturaInversorMapper — mapeo completo', () {
    test('mapea id, tiempo, inversor y los 26 campos de telemetria', () {
      final lectura =
          LecturaInversorMapper.fromJson(fullDatoInversorJson());

      expect(lectura.id, 7);
      expect(lectura.tiempo, DateTime.utc(2026, 6, 17, 10));
      expect(lectura.inversorId, 1);
      expect(lectura.inversorNombre, 'INV-001');

      expect(lectura.bateriaVoltajeV, 48.6);
      expect(lectura.bateriaCorrienteA, -12.5);
      expect(lectura.bateriaPotenciaW, -607.5);
      expect(lectura.pvVoltajeV, 120.3);
      expect(lectura.pvPotenciaW, 45000.0);
      expect(lectura.pvCorrienteA, 374.0);
      expect(lectura.salidaVoltajeV, 220.0);
      expect(lectura.salidaPotenciaW, 43000.0);
      expect(lectura.salidaCorrienteA, 195.5);
      expect(lectura.salidaAparenteVa, 44000.0);
      expect(lectura.salidaFrecuenciaHz, 60.0);
      expect(lectura.cargaPorcentaje, 65);
      expect(lectura.socPct, 82);
      expect(lectura.redVoltajeV, 221.0);
      expect(lectura.redFrecuenciaHz, 59.9);
      expect(lectura.busVoltajeV, 400.0);
      expect(lectura.temperaturaC, 41.5);
      expect(lectura.eficienciaPct, 92.5);
      expect(lectura.consumoRedW, 1500.0);
      expect(lectura.modoOperacion, 'GRID_TIE');
      expect(lectura.codigoFallo, 7);
      expect(lectura.bateriaCargando, isTrue);
      expect(lectura.pvActivo, isTrue);
      expect(lectura.redActiva, isTrue);
      expect(lectura.crcValido, isTrue);
      expect(lectura.latenciaMs, 35);
    });

    test('el fixture cubre exactamente los 26 campos del DTO', () {
      final json = fullDatoInversorJson();
      for (final key in datoInversorTelemetryKeys) {
        expect(json.containsKey(key), isTrue, reason: 'falta $key');
      }
      final telemetryInJson = json.keys
          .where((k) => datoInversorTelemetryKeys.contains(k))
          .toList();
      expect(telemetryInJson.length, datoInversorTelemetryKeys.length);
    });

    test('normaliza tiempo a UTC (igualdad de DateTime)', () {
      final lectura =
          LecturaInversorMapper.fromJson(fullDatoInversorJson());
      expect(lectura.tiempo!.isUtc, isTrue);
      expect(lectura.tiempo, DateTime.utc(2026, 6, 17, 10));
    });

    test('convierte numeros al tipo del campo (int <-> double)', () {
      final lectura = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'pvPotenciaW': 45000,
        'codigoFallo': 7.0,
        'latenciaMs': 35.0,
      });
      expect(lectura.pvPotenciaW, 45000.0);
      expect(lectura.pvPotenciaW, isA<double>());
      expect(lectura.codigoFallo, 7);
      expect(lectura.latenciaMs, 35);
    });

    test('fromJson y fromDto producen la misma entidad', () {
      final json = fullDatoInversorJson();
      final fromJson = LecturaInversorMapper.fromJson(json);
      final fromDto =
          LecturaInversorMapper.fromDto(DatoInversorDTO.fromJson(json));
      expect(fromJson, fromDto);
      expect(fromJson.hashCode, fromDto.hashCode);
    });
  });

  group('LecturaInversorMapper — nulos (nunca 0, nunca excepcion)', () {
    test('claves presentes en null => campos null, sin convertir a 0', () {
      final lectura = LecturaInversorMapper.fromJson(allNullDatoInversorJson());

      expect(lectura.tiempo, isNull);
      expect(lectura.pvPotenciaW, isNull);
      expect(lectura.socPct, isNull);
      expect(lectura.cargaPorcentaje, isNull);
      expect(lectura.codigoFallo, isNull);
      expect(lectura.eficienciaPct, isNull);
      expect(lectura.bateriaVoltajeV, isNull);
      expect(lectura.latenciaMs, isNull);
      expect(lectura.modoOperacion, isNull);
      expect(lectura.bateriaCargando, isNull);
      expect(lectura.enAlarma, isFalse);
      for (final campo in datoInversorTelemetryKeys) {
        expect(
          _valor(lectura, campo),
          isNull,
          reason: '$campo no debe ser 0 ni false, debe ser null',
        );
      }
    });

    test('claves ausentes del JSON tampoco lanzan', () {
      final lectura = LecturaInversorMapper.fromJson(minimalDatoInversorJson());
      expect(lectura.id, 1);
      expect(lectura.pvPotenciaW, isNull);
      expect(lectura.inversorId, isNull);
      expect(lectura.inversorNombre, isNull);
      expect(lectura.tiempo, DateTime.utc(2026, 6, 17, 10));
    });

    test('JSON sin inversor anidado => referencia null', () {
      final lectura = LecturaInversorMapper.fromJson({
        'id': 1,
        'tiempo': null,
        'inversor': null,
      });
      expect(lectura.inversorId, isNull);
      expect(lectura.inversorNombre, isNull);
      expect(lectura.tiempo, isNull);
    });

    test('valores de tipo invalidos se ignoran sin excepcion', () {
      final lectura = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'pvPotenciaW': 'abc',
        'codigoFallo': 'oops',
        'bateriaCargando': 3,
        'modoOperacion': 42,
        'tiempo': 12345,
        'inversor': 'no-objeto',
      });
      expect(lectura.pvPotenciaW, isNull);
      expect(lectura.codigoFallo, isNull);
      expect(lectura.bateriaCargando, isNull);
      expect(lectura.modoOperacion, isNull);
      expect(lectura.tiempo, isNull);
      expect(lectura.inversorId, isNull);
      expect(lectura.inversorNombre, isNull);
    });

    test('claves desconocidas del backend se ignoran', () {
      final lectura = LecturaInversorMapper.fromJson({
        ...fullDatoInversorJson(),
        'campoFuturoDelBackend': {'anidado': true},
      });
      expect(lectura.pvPotenciaW, 45000.0);
    });
  });

  group('LecturaInversor.enAlarma', () {
    test('codigoFallo > 0 => alarma; null o 0 => sin alarma', () {
      expect(LecturaInversorMapper.fromJson(fullDatoInversorJson()).enAlarma,
          isTrue);
      expect(
        LecturaInversorMapper.fromJson({
          ...fullDatoInversorJson(),
          'codigoFallo': 0,
        }).enAlarma,
        isFalse,
      );
      expect(
        LecturaInversorMapper.fromJson(allNullDatoInversorJson()).enAlarma,
        isFalse,
      );
    });
  });
}

/// Lee un campo por nombre de la entidad para el barrido de nulos.
Object? _valor(LecturaInversor lectura, String campo) {
  switch (campo) {
    case 'bateriaVoltajeV':
      return lectura.bateriaVoltajeV;
    case 'bateriaCorrienteA':
      return lectura.bateriaCorrienteA;
    case 'bateriaPotenciaW':
      return lectura.bateriaPotenciaW;
    case 'pvVoltajeV':
      return lectura.pvVoltajeV;
    case 'pvPotenciaW':
      return lectura.pvPotenciaW;
    case 'pvCorrienteA':
      return lectura.pvCorrienteA;
    case 'salidaVoltajeV':
      return lectura.salidaVoltajeV;
    case 'salidaPotenciaW':
      return lectura.salidaPotenciaW;
    case 'salidaCorrienteA':
      return lectura.salidaCorrienteA;
    case 'salidaAparenteVa':
      return lectura.salidaAparenteVa;
    case 'salidaFrecuenciaHz':
      return lectura.salidaFrecuenciaHz;
    case 'cargaPorcentaje':
      return lectura.cargaPorcentaje;
    case 'socPct':
      return lectura.socPct;
    case 'redVoltajeV':
      return lectura.redVoltajeV;
    case 'redFrecuenciaHz':
      return lectura.redFrecuenciaHz;
    case 'busVoltajeV':
      return lectura.busVoltajeV;
    case 'temperaturaC':
      return lectura.temperaturaC;
    case 'eficienciaPct':
      return lectura.eficienciaPct;
    case 'consumoRedW':
      return lectura.consumoRedW;
    case 'modoOperacion':
      return lectura.modoOperacion;
    case 'codigoFallo':
      return lectura.codigoFallo;
    case 'bateriaCargando':
      return lectura.bateriaCargando;
    case 'pvActivo':
      return lectura.pvActivo;
    case 'redActiva':
      return lectura.redActiva;
    case 'crcValido':
      return lectura.crcValido;
    case 'latenciaMs':
      return lectura.latenciaMs;
    default:
      throw StateError('campo desconocido en el barrido: $campo');
  }
}
