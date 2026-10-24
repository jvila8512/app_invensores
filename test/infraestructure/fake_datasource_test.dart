// test/infraestructure/fake_datasource_test.dart

import 'dart:io';

import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/domain/policy/jwt_decoder.dart';
import 'package:etecsa_supervision/domain/policy/site_grouping.dart';
import 'package:etecsa_supervision/infraestructure/datasource/auth_fake_datasource.dart';
import 'package:etecsa_supervision/infraestructure/datasource/inverter_fake_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeInverterDatasource — determinismo (spec §5)', () {
    test(
      'dos fakes con la misma semilla producen el mismo catalogo y lecturas',
      () async {
        final first = FakeInverterDatasource(seed: 42);
        final second = FakeInverterDatasource(seed: 42);

        expect(await first.fetchAll(), await second.fetchAll());
        expect(
          await first.fetchLatestReadings(),
          await second.fetchLatestReadings(),
        );
        expect(
          await first.fetchLatestReadings(),
          await second.fetchLatestReadings(),
        );
      },
    );

    test('el catalogo es estable entre llamadas', () async {
      final fake = FakeInverterDatasource(seed: 42);
      expect(await fake.fetchAll(), await fake.fetchAll());
    });
  });

  group('FakeInverterDatasource — catalogo agrupado', () {
    test('hay al menos dos sitios, masters y esclavos', () async {
      final fake = FakeInverterDatasource(seed: 42);
      final inversores = await fake.fetchAll();

      expect(inversores.length, greaterThanOrEqualTo(2));
      expect(
        SiteGrouping.groupBySite(inversores).length,
        greaterThanOrEqualTo(2),
      );
      expect(inversores.where((i) => i.esMaster == true), isNotEmpty);
      expect(inversores.where((i) => i.esMaster == false), isNotEmpty);
      expect(inversores.where((i) => i.masterReferenciaId != null), isNotEmpty);
    });
  });

  group('FakeInverterDatasource — telemetria plausible', () {
    test(
      'todas las lecturas traen inversor, tiempo y valores en rango',
      () async {
        final fake = FakeInverterDatasource(seed: 42);
        final readings = await fake.fetchLatestReadings();

        expect(readings, isNotEmpty);
        for (final lectura in readings) {
          expect(lectura.inversorId, isNotNull);
          expect(lectura.inversorNombre, isNotNull);
          expect(lectura.tiempo, isNotNull);
        }

        final conDatos = readings
            .where((lectura) => lectura.pvPotenciaW != null)
            .toList();
        expect(conDatos, isNotEmpty);
        for (final lectura in conDatos) {
          expect(lectura.pvPotenciaW, greaterThanOrEqualTo(0));
          expect(lectura.socPct, inInclusiveRange(0, 100));
          expect(lectura.cargaPorcentaje, inInclusiveRange(0, 100));
          expect(lectura.eficienciaPct, inInclusiveRange(0, 100));
          expect(lectura.codigoFallo, greaterThanOrEqualTo(0));
          expect(lectura.latenciaMs, greaterThanOrEqualTo(0));
        }

        expect(readings.any((lectura) => lectura.pvPotenciaW! > 0), isTrue);
        expect(readings.any((lectura) => lectura.enAlarma), isTrue);
        expect(
          readings.any(
            (lectura) => lectura.pvPotenciaW == null && lectura.socPct == null,
          ),
          isTrue,
        );
      },
    );

    test('las lecturas avanzan entre sondeos', () async {
      final fake = FakeInverterDatasource(seed: 42);
      final first = await fake.fetchLatestReadings();
      final second = await fake.fetchLatestReadings();

      expect(second.first.tiempo!.isAfter(first.first.tiempo!), isTrue);
      expect(second, isNot(equals(first)));
    });
  });

  group('FakeInverterDatasource — historial y live', () {
    test(
      'fetchHistory devuelve size filas del inversor, mas nuevas primero',
      () async {
        final fake = FakeInverterDatasource(seed: 42);
        final rows = await fake.fetchHistory(7, size: 5);

        expect(rows, hasLength(5));
        expect(rows.every((row) => row.inversorId == 7), isTrue);
        expect(rows.first.tiempo!.isAfter(rows.last.tiempo!), isTrue);
      },
    );

    test('fetchHistory de un id inexistente devuelve vacio', () async {
      final fake = FakeInverterDatasource(seed: 42);
      expect(await fake.fetchHistory(999, size: 5), isEmpty);
    });

    test('watchLive emite lecturas del inversor pedido', () async {
      final fake = FakeInverterDatasource(seed: 42, cadence: Duration.zero);
      final readings = await fake.watchLive(1).take(2).toList();

      expect(readings, hasLength(2));
      expect(readings.every((lectura) => lectura.inversorId == 1), isTrue);
      expect(readings.last.tiempo!.isAfter(readings.first.tiempo!), isTrue);
    });
  });

  group('FakeAuthDatasource — demo offline', () {
    test('acepta credenciales no vacias y devuelve un JWT vigente', () async {
      final auth = FakeAuthDatasource();
      final token = await auth.authenticate(
        username: 'admin',
        password: 'admin',
      );

      expect(JwtDecoder.expirationDate(token), isNotNull);
      expect(
        JwtDecoder.isExpired(token, now: DateTime.utc(2026, 6, 17)),
        isFalse,
      );

      final account = await auth.fetchAccount();
      expect(account.login, 'admin');
      expect(account.activated, isTrue);
      expect(account.hasRole('ROLE_ADMIN'), isTrue);
    });

    test('rechaza credenciales vacias', () async {
      final auth = FakeAuthDatasource();
      await expectLater(
        auth.authenticate(username: '', password: ''),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('fake sin red (WU4)', () {
    test('las datasources fake no importan ni instancian Dio', () {
      for (final path in <String>[
        'lib/infraestructure/datasource/inverter_fake_datasource.dart',
        'lib/infraestructure/datasource/auth_fake_datasource.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(
          RegExp(r'package:dio|Dio\(').hasMatch(source),
          isFalse,
          reason: '$path no debe depender de Dio',
        );
      }
    });
  });
}
