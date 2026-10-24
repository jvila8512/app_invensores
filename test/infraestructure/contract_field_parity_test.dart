// test/infraestructure/contract_field_parity_test.dart

import 'package:etecsa_supervision/infraestructure/datasource/inverter_fake_datasource.dart';
import 'package:etecsa_supervision/infraestructure/mapper/inversor_mapper.dart';
import 'package:etecsa_supervision/infraestructure/mapper/lectura_inversor_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  group('Paridad de contrato — telemetria', () {
    test(
      'la lectura fake expone exactamente los 26 campos de DatoInversorDTO',
      () {
        final fleet = SeededInverterFleet(seed: 42);
        final json = fleet.nextLatestReadingsJson().first;

        expect(json.keys.toSet(), <String>{
          'id',
          'tiempo',
          'inversor',
          ...datoInversorTelemetryKeys,
        });
        expect((json['inversor'] as Map).keys.toSet(), <String>{
          'id',
          'nombre',
        });
      },
    );

    test('el JSON fake lo entiende el mapper real', () {
      final fleet = SeededInverterFleet(seed: 42);
      final json = fleet.nextLatestReadingsJson().first;
      final lectura = LecturaInversorMapper.fromJson(json);

      expect(lectura.inversorId, isNotNull);
      expect(lectura.tiempo, isNotNull);
      expect(lectura.inversorNombre, isNotNull);
    });

    test('la fake de telemetria declara la misma lista que el fixture', () {
      expect(fakeTelemetryKeys, datoInversorTelemetryKeys);
    });
  });

  group('Paridad de contrato — catalogo', () {
    test('el inversor fake expone las mismas claves que InversorDTO', () {
      final fleet = SeededInverterFleet(seed: 42);
      final json = fleet.catalogJson.first;
      final fixture = fullInversorJson();

      expect(json.keys.toSet(), fixture.keys.toSet());
      for (final relation in <String>['sitio', 'marca', 'modelo', 'gateway']) {
        expect(
          (json[relation] as Map).keys.toSet(),
          (fixture[relation] as Map).keys.toSet(),
          reason: 'la relacion $relation debe tener las mismas claves',
        );
      }
    });

    test('los esclavos traen masterReferencia con id y nombre', () {
      final fleet = SeededInverterFleet(seed: 42);
      final slave = fleet.catalogJson.firstWhere(
        (json) => json['masterReferencia'] != null,
      );

      expect((slave['masterReferencia'] as Map).keys.toSet(), <String>{
        'id',
        'nombre',
      });

      final inversor = InversorMapper.fromJson(slave);
      expect(inversor.masterReferenciaId, isNotNull);
    });

    test('el catalogo fake lo entiende el mapper real', () {
      final fleet = SeededInverterFleet(seed: 42);
      final inversor = InversorMapper.fromJson(fleet.catalogJson.first);

      expect(inversor.id, isNotNull);
      expect(inversor.nombre, isNotNull);
      expect(inversor.sitio, isNotNull);
      expect(inversor.marca, isNotNull);
      expect(inversor.modelo, isNotNull);
      expect(inversor.gateway, isNotNull);
    });
  });
}
