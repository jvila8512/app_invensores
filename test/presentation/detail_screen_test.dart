// test/presentation/detail_screen_test.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/domain/repository/inverter_repository.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:etecsa_supervision/presentation/provider/selected_site_provider.dart';
import 'package:etecsa_supervision/presentation/screen/dashboard_screen.dart';
import 'package:etecsa_supervision/presentation/screen/inversor_detail_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/fixtures.dart';

class _FakeInverterRepository implements InverterRepository {
  _FakeInverterRepository({
    required this.catalog,
    this.liveReading,
    this.history = const [],
  });

  final List<Inversor> catalog;
  final LecturaInversor? liveReading;
  final List<LecturaInversor> history;

  @override
  Future<List<Inversor>> fetchAll() async => catalog;

  @override
  Future<List<LecturaInversor>> fetchLatestReadings() async =>
      liveReading == null ? const [] : [liveReading!];

  @override
  Future<List<LecturaInversor>> fetchHistory(
    int inversorId, {
    int size = 200,
  }) async =>
      history;

  @override
  Stream<LecturaInversor> watchLive(int inversorId) async* {
    final reading = liveReading;
    if (reading != null) yield reading;
  }
}

class _DashboardStub extends ConsumerWidget {
  const _DashboardStub();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final site = ref.watch(selectedSiteProvider) ?? 'Todos';
    return Scaffold(body: Text('dashboard-stub:$site'));
  }
}

Widget _app(_FakeInverterRepository repository) {
  final router = GoRouter(
    initialLocation: InversorDetailScreen.pathFor(1),
    routes: [
      GoRoute(
        path: DashboardScreen.path,
        builder: (context, state) => const _DashboardStub(),
      ),
      GoRoute(
        path: InversorDetailScreen.path,
        builder: (context, state) => InversorDetailScreen(
          inversorId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      inverterRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

LecturaInversor _reading() => LecturaInversor(
      id: 10,
      inversorId: 1,
      tiempo: DateTime.utc(2026, 6, 17, 12),
      pvVoltajeV: 120.3,
      pvPotenciaW: 4500,
      pvCorrienteA: 37.4,
      pvActivo: true,
      bateriaVoltajeV: 48.6,
      bateriaCorrienteA: -12.5,
      bateriaPotenciaW: -607.5,
      socPct: 82,
      cargaPorcentaje: 65,
      bateriaCargando: true,
      redVoltajeV: 221,
      redFrecuenciaHz: 59.9,
      redActiva: true,
      salidaVoltajeV: 220,
      salidaPotenciaW: 4300,
      salidaCorrienteA: 19.5,
      salidaFrecuenciaHz: 60,
      salidaAparenteVa: 4400,
      consumoRedW: 1500,
      eficienciaPct: 92.5,
      temperaturaC: 41.5,
      latenciaMs: 35,
      modoOperacion: 'GRID_TIE',
      codigoFallo: 7,
      crcValido: true,
    );

List<LecturaInversor> _history() => [
      LecturaInversor(
        id: 1,
        inversorId: 1,
        tiempo: DateTime.utc(2026, 6, 17, 10),
        pvPotenciaW: 3000,
      ),
      LecturaInversor(
        id: 2,
        inversorId: 1,
        tiempo: DateTime.utc(2026, 6, 17, 11),
        pvPotenciaW: 4000,
      ),
      LecturaInversor(
        id: 3,
        inversorId: 1,
        tiempo: DateTime.utc(2026, 6, 17, 12),
        pvPotenciaW: 4500,
      ),
    ];

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pumpAndSettle();
}

/// El detalle es una lista perezosa: en una superficie alta entran las seis
/// secciones y el grafico sin tener que scrollear en cada test.
void _largeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('muestra las seis secciones y el banner de conexion', (
    tester,
  ) async {
    _largeSurface(tester);
    final repository = _FakeInverterRepository(
      catalog: [buildInversor(id: 1)],
      liveReading: _reading(),
      history: _history(),
    );

    await tester.pumpWidget(_app(repository));
    await _pump(tester);

    for (final title in ['PV', 'Batería', 'Red', 'Carga', 'Eficiencia', 'Estado']) {
      expect(
        find.text(title),
        findsAtLeastNWidgets(1),
        reason: 'falta la sección $title',
      );
    }
    expect(find.byKey(const Key('live-banner')), findsOneWidget);
    expect(find.text('CONECTADO'), findsOneWidget);
    expect(find.text('E07'), findsOneWidget);
  });

  testWidgets('el breadcrumb fija el filtro de sitio y vuelve al dashboard', (
    tester,
  ) async {
    _largeSurface(tester);
    final repository = _FakeInverterRepository(
      catalog: [buildInversor(id: 1)],
      liveReading: _reading(),
    );

    await tester.pumpWidget(_app(repository));
    await _pump(tester);

    expect(find.byKey(const Key('breadcrumb-site')), findsOneWidget);

    await tester.tap(find.byKey(const Key('breadcrumb-site')));
    await tester.pumpAndSettle();

    expect(find.text('dashboard-stub:Planta Norte'), findsOneWidget);
  });

  testWidgets('el grafico dibuja exactamente las filas del historial', (
    tester,
  ) async {
    _largeSurface(tester);
    final history = _history();
    final repository = _FakeInverterRepository(
      catalog: [buildInversor(id: 1)],
      liveReading: _reading(),
      history: history,
    );

    await tester.pumpWidget(_app(repository));
    await _pump(tester);

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.lineBarsData, hasLength(1));
    expect(
      chart.data.lineBarsData.first.spots,
      hasLength(history.length),
      reason: 'un punto por fila devuelta, sin series inventadas',
    );
  });
}
