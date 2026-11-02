// test/presentation/dashboard_screen_test.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/domain/repository/inverter_repository.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:etecsa_supervision/presentation/provider/kpis_provider.dart';
import 'package:etecsa_supervision/presentation/provider/latest_readings_provider.dart';
import 'package:etecsa_supervision/presentation/screen/dashboard_screen.dart';
import 'package:etecsa_supervision/presentation/widget/dashboard/inverter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

final DateTime _now = DateTime.utc(2026, 6, 17, 12);

class _FakeInverterRepository implements InverterRepository {
  _FakeInverterRepository({
    required this.catalog,
    required this.readings,
  });

  final List<Inversor> catalog;
  final List<LecturaInversor> readings;

  int latestCalls = 0;

  @override
  Future<List<Inversor>> fetchAll() async => catalog;

  @override
  Future<List<LecturaInversor>> fetchLatestReadings() async {
    latestCalls++;
    return readings;
  }

  @override
  Future<List<LecturaInversor>> fetchHistory(
    int inversorId, {
    int size = 200,
  }) async =>
      const [];

  @override
  Stream<LecturaInversor> watchLive(int inversorId) => const Stream.empty();
}

Widget _app(_FakeInverterRepository repository) {
  return ProviderScope(
    overrides: [
      inverterRepositoryProvider.overrideWithValue(repository),
      latestReadingsPollIntervalProvider.overrideWithValue(
        const Duration(hours: 1),
      ),
      kpisClockProvider.overrideWithValue(() => _now),
    ],
    child: const MaterialApp(home: DashboardScreen()),
  );
}

/// Lectura fresca (1 s de antiguedad) con los valores indicados.
LecturaInversor _fresh({
  required int inversorId,
  double? pvPotenciaW,
  int? socPct,
  int? codigoFallo,
  double? eficienciaPct,
}) =>
    LecturaInversor(
      id: inversorId,
      inversorId: inversorId,
      tiempo: _now.subtract(const Duration(seconds: 1)),
      pvPotenciaW: pvPotenciaW,
      socPct: socPct,
      codigoFallo: codigoFallo,
      eficienciaPct: eficienciaPct,
    );

Future<void> _pumpDashboard(
  WidgetTester tester,
  _FakeInverterRepository repository,
) async {
  await tester.pumpWidget(_app(repository));
  // Deja correr el primer sondeo (lectura inmediata del provider).
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('muestra los KPI de la flota y el chip Todos', (tester) async {
    final catalog = buildFleet(count: 3, siteCount: 2);
    final repository = _FakeInverterRepository(
      catalog: catalog,
      readings: [
        _fresh(inversorId: 1, pvPotenciaW: 1000, socPct: 80),
        _fresh(inversorId: 2, pvPotenciaW: 2000, socPct: 50),
        _fresh(inversorId: 3, eficienciaPct: 90),
      ],
    );

    await _pumpDashboard(tester, repository);

    expect(find.byKey(const Key('site-chip-Todos')), findsOneWidget);
    expect(find.text('3.0 kW'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('0'), findsOneWidget, reason: 'sin alarmas');
  });

  testWidgets('el chip de sitio filtra la lista y es pegajoso', (tester) async {
    final catalog = buildFleet(count: 2, siteCount: 2);
    final repository = _FakeInverterRepository(
      catalog: catalog,
      readings: [for (final i in catalog) _fresh(inversorId: i.id!)],
    );

    await _pumpDashboard(tester, repository);

    // Antes del filtro hay una tarjeta por sitio.
    expect(find.byKey(const Key('inverter-card-1')), findsOneWidget);
    expect(find.byKey(const Key('inverter-card-2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('site-chip-Planta Sur')));
    await tester.pump();

    // Solo queda la del sitio elegido (Planta Sur = id 2).
    expect(find.byKey(const Key('inverter-card-2')), findsOneWidget);
    expect(find.byKey(const Key('inverter-card-1')), findsNothing);

    // Volver a Todos restaura la lista completa.
    await tester.tap(find.byKey(const Key('site-chip-Todos')));
    await tester.pump();
    expect(find.byKey(const Key('inverter-card-1')), findsOneWidget);
  });

  testWidgets('la telemetria ausente se pinta con —, nunca con 0', (
    tester,
  ) async {
    final catalog = [buildInversor(id: 1)];
    final repository = _FakeInverterRepository(
      catalog: catalog,
      readings: [_fresh(inversorId: 1)],
    );

    await _pumpDashboard(tester, repository);

    expect(find.text('0.00 kW'), findsNothing);
    expect(find.text('—'), findsWidgets);
  });

  testWidgets('una lectura vieja marca OFFLINE', (tester) async {
    final catalog = [buildInversor(id: 1)];
    final repository = _FakeInverterRepository(
      catalog: catalog,
      readings: [
        LecturaInversor(
          id: 1,
          inversorId: 1,
          tiempo: _now.subtract(const Duration(minutes: 5)),
          pvPotenciaW: 500,
        ),
      ],
    );

    await _pumpDashboard(tester, repository);

    final status = tester.widget<Text>(
      find.byKey(const Key('inverter-status-1')),
    );
    expect(status.data, 'OFFLINE');
    expect(find.text('0/1'), findsOneWidget);
  });

  testWidgets('300 inversores construyen muchas menos de 300 tarjetas', (
    tester,
  ) async {
    final catalog = buildFleet();
    final repository = _FakeInverterRepository(
      catalog: catalog,
      readings: [for (final i in catalog) _fresh(inversorId: i.id!)],
    );

    await _pumpDashboard(tester, repository);

    final built = find.byType(InverterCard).evaluate().length;
    expect(built, lessThan(50));
    expect(built, greaterThan(0));
  });

  test('FleetKpis ignora lecturas vencidas y promedia solo datos presentes', () {
    final catalog = [
      buildInversor(id: 1),
      buildInversor(id: 2),
      buildInversor(id: 3),
    ];
    final readings = <int, LecturaInversor>{
      1: _fresh(inversorId: 1, pvPotenciaW: 1000, eficienciaPct: 90),
      2: LecturaInversor(
        id: 2,
        inversorId: 2,
        tiempo: _now.subtract(const Duration(minutes: 10)),
        pvPotenciaW: 3000,
        eficienciaPct: 80,
        codigoFallo: 7,
      ),
    };

    final kpis = FleetKpis.from(
      inverters: catalog,
      readings: readings,
      now: _now,
    );

    expect(kpis.total, 3);
    expect(kpis.online, 1, reason: 'solo la lectura fresca cuenta');
    expect(kpis.totalPvW, 4000);
    expect(kpis.avgEfficiencyPct, 85);
    expect(kpis.inAlarm, 1);
  });
}
