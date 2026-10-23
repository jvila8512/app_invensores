import 'package:etecsa_supervision/infraestructure/mapper/inversor_mapper.dart';
import 'package:etecsa_supervision/infraestructure/model/inversor_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  group('InversorMapper — mapeo completo', () {
    test('mapea los escalares del InversorDTO', () {
      final inversor = InversorMapper.fromJson(fullInversorJson());

      expect(inversor.id, 1);
      expect(inversor.nombre, 'INV-001');
      expect(inversor.numeroSerie, 'SN-001');
      expect(inversor.esMaster, isTrue);
      expect(inversor.tipoConexion, 'TcpModbus');
      expect(inversor.puertoSerial, isNull);
      expect(inversor.slaveId, 1);
      expect(inversor.activo, isTrue);
      expect(inversor.estadoDispositivo, 'Conectado');
      expect(inversor.ultimaLectura, DateTime.utc(2026, 6, 17, 10));
      expect(inversor.ultimoError, isNull);
      expect(inversor.periodoMuestreoSeg, 10);
      expect(inversor.fechaRegistro, DateTime.utc(2026, 1, 1));
      expect(inversor.ultimaConexion, DateTime.utc(2026, 6, 17, 9, 59));
      expect(inversor.masterReferenciaId, 9);
    });

    test('las relaciones anidadas llegan como entidades', () {
      final inversor = InversorMapper.fromJson(fullInversorJson());

      expect(inversor.sitio?.id, 1);
      expect(inversor.sitio?.nombre, 'Planta Norte');
      expect(inversor.sitio?.ubicacion, 'Habana');
      expect(inversor.marca?.nombre, 'Felicity');
      expect(inversor.marca?.registroFin, 99);
      expect(inversor.modelo?.nombre, 'A1');
      expect(inversor.modelo?.capacidadVa, 5000);
      expect(inversor.modelo?.marca?.nombre, 'Felicity');
      expect(inversor.gateway?.nombre, 'GW-1');
      expect(inversor.gateway?.direccionIp, '192.168.1.10');
      expect(inversor.gateway?.puerto, 502);
      expect(inversor.gateway?.tiempoEsperaMs, 10000);
    });

    test('tipoConexion y estadoDispositivo quedan como String (nunca enum)',
        () {
      final inversor = InversorMapper.fromJson(fullInversorJson());
      expect(inversor.tipoConexion, isA<String>());
      expect(inversor.estadoDispositivo, isA<String>());
      expect(inversor.gateway?.estadoConexion, isA<String>());
    });

    test('fromJson y fromDto producen la misma entidad', () {
      final json = fullInversorJson();
      final fromJson = InversorMapper.fromJson(json);
      final fromDto = InversorMapper.fromDto(InversorDTO.fromJson(json));
      expect(fromJson, fromDto);
      expect(fromJson.hashCode, fromDto.hashCode);
    });

    test('dos parseos del mismo JSON dan entidades iguales', () {
      expect(
        InversorMapper.fromJson(fullInversorJson()),
        InversorMapper.fromJson(fullInversorJson()),
      );
    });
  });

  group('InversorMapper — nulos y campos ausentes', () {
    test('JSON minimo => relaciones y metadatos null, sin excepcion', () {
      final inversor = InversorMapper.fromJson(minimalInversorJson());
      expect(inversor.id, 3);
      expect(inversor.nombre, 'INV-003');
      expect(inversor.sitio, isNull);
      expect(inversor.marca, isNull);
      expect(inversor.modelo, isNull);
      expect(inversor.gateway, isNull);
      expect(inversor.masterReferenciaId, isNull);
      expect(inversor.esMaster, isNull);
      expect(inversor.estadoDispositivo, isNull);
      expect(inversor.ultimaLectura, isNull);
    });

    test('JSON vacio => entidad toda null, sin excepcion', () {
      final inversor = InversorMapper.fromJson(const {});
      expect(inversor.id, isNull);
      expect(inversor.nombre, isNull);
      expect(inversor.sitio, isNull);
    });

    test('relaciones con tipo equivocado se ignoran', () {
      final inversor = InversorMapper.fromJson({
        ...fullInversorJson(),
        'sitio': 'no-objeto',
        'gateway': 42,
        'masterReferencia': ['x'],
        'esMaster': 'si',
      });
      expect(inversor.sitio, isNull);
      expect(inversor.gateway, isNull);
      expect(inversor.masterReferenciaId, isNull);
      expect(inversor.esMaster, isNull);
      expect(inversor.nombre, 'INV-001');
    });

    test('enum como texto desconocido se conserva tal cual', () {
      final inversor = InversorMapper.fromJson({
        ...fullInversorJson(),
        'estadoDispositivo': 'EnCalibracion',
      });
      expect(inversor.estadoDispositivo, 'EnCalibracion');
    });
  });
}
