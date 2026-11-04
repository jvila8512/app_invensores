// lib/presentation/screen/inversor_detail_screen.dart

import 'package:etecsa_supervision/config/helper/solar_format.dart';
import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/domain/policy/site_grouping.dart';
import 'package:etecsa_supervision/presentation/provider/catalog_provider.dart';
import 'package:etecsa_supervision/presentation/provider/live_provider.dart';
import 'package:etecsa_supervision/presentation/provider/selected_site_provider.dart';
import 'package:etecsa_supervision/presentation/screen/dashboard_screen.dart';
import 'package:etecsa_supervision/presentation/widget/detail/history_chart.dart';
import 'package:etecsa_supervision/presentation/widget/detail/live_banner.dart';
import 'package:etecsa_supervision/presentation/widget/detail/metric_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Detalle de un inversor (spec §4).
///
/// Seis secciones (PV, Bateria, Red, Carga, Eficiencia, Estado) con las
/// lecturas reales del DTO — los ausentes se pintan `—`. El breadcrumb
/// `Planta › Inversor` fija el filtro de sitio del dashboard y vuelve a `/`.
class InversorDetailScreen extends ConsumerWidget {
  static const String name = 'inversor-detail-screen';
  static const String path = '/inversor/:id';

  static String pathFor(int id) => '/inversor/$id';

  const InversorDetailScreen({super.key, required this.inversorId});

  final int inversorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inversor = ref.watch(inversorByIdProvider(inversorId));

    if (inversor == null) {
      final catalog = ref.watch(inverterCatalogProvider);
      return Scaffold(
        appBar: AppBar(title: const Text('Inversor')),
        body: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              const Center(child: Text('No se pudo cargar el inversor.')),
          data: (_) => const Center(child: Text('Inversor no encontrado.')),
        ),
      );
    }

    final reading = ref.watch(liveReadingProvider(inversorId)).value;
    final status = ref.watch(liveStatusProvider(inversorId));
    final history = ref.watch(historyProvider(inversorId));

    return Scaffold(
      appBar: AppBar(title: Text(inversor.nombre ?? SolarFormat.emDash)),
      body: ListView(
        children: [
          DetailBreadcrumb(
            site: inversor.sitio?.nombre ?? SiteGrouping.sinSitioLabel,
            inversor: inversor.nombre ?? SolarFormat.emDash,
            onSiteTap: () {
              ref
                  .read(selectedSiteProvider.notifier)
                  .select(inversor.sitio?.nombre);
              context.go(DashboardScreen.path);
            },
          ),
          LiveBanner(status: status),
          _pvSection(reading),
          _batterySection(reading),
          _gridSection(reading),
          _loadSection(reading),
          _efficiencySection(reading),
          _statusSection(inversor, reading),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historial PV',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  history.when(
                    loading: () => const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => const SizedBox(
                      height: 60,
                      child: Center(child: Text('Sin historial')),
                    ),
                    data: (rows) => HistoryChart(rows: rows),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  MetricSection _pvSection(LecturaInversor? r) => MetricSection(
        title: 'PV',
        icon: Icons.solar_power,
        metrics: [
          MetricEntry('Voltaje', SolarFormat.volts(r?.pvVoltajeV)),
          MetricEntry('Potencia', SolarFormat.kilowatts(r?.pvPotenciaW)),
          MetricEntry('Corriente', SolarFormat.amperes(r?.pvCorrienteA)),
          MetricEntry('Activo', _bool(r?.pvActivo)),
        ],
      );

  MetricSection _batterySection(LecturaInversor? r) => MetricSection(
        title: 'Batería',
        icon: Icons.battery_charging_full,
        metrics: [
          MetricEntry('Voltaje', SolarFormat.volts(r?.bateriaVoltajeV)),
          MetricEntry('Corriente', SolarFormat.amperes(r?.bateriaCorrienteA)),
          MetricEntry('Potencia', SolarFormat.kilowatts(r?.bateriaPotenciaW)),
          MetricEntry('SOC', SolarFormat.percent(r?.socPct)),
          MetricEntry('Carga', SolarFormat.percent(r?.cargaPorcentaje)),
          MetricEntry('Cargando', _bool(r?.bateriaCargando)),
        ],
      );

  MetricSection _gridSection(LecturaInversor? r) => MetricSection(
        title: 'Red',
        icon: Icons.electrical_services,
        metrics: [
          MetricEntry('Voltaje', SolarFormat.acVolts(r?.redVoltajeV)),
          MetricEntry('Frecuencia', SolarFormat.hertz(r?.redFrecuenciaHz)),
          MetricEntry('Activa', _bool(r?.redActiva)),
        ],
      );

  MetricSection _loadSection(LecturaInversor? r) => MetricSection(
        title: 'Carga',
        icon: Icons.output,
        metrics: [
          MetricEntry('Voltaje salida', SolarFormat.acVolts(r?.salidaVoltajeV)),
          MetricEntry('Potencia', SolarFormat.kilowatts(r?.salidaPotenciaW)),
          MetricEntry('Corriente', SolarFormat.amperes(r?.salidaCorrienteA)),
          MetricEntry(
            'Frecuencia',
            SolarFormat.hertz(r?.salidaFrecuenciaHz),
          ),
          MetricEntry(
            'Aparente',
            SolarFormat.kilovoltAmperes(r?.salidaAparenteVa),
          ),
          MetricEntry('Consumo red', SolarFormat.kilowatts(r?.consumoRedW)),
        ],
      );

  MetricSection _efficiencySection(LecturaInversor? r) => MetricSection(
        title: 'Eficiencia',
        icon: Icons.speed,
        metrics: [
          MetricEntry('Eficiencia', SolarFormat.percent(r?.eficienciaPct)),
          MetricEntry('Temperatura', _celsius(r?.temperaturaC)),
          MetricEntry('Latencia', SolarFormat.milliseconds(r?.latenciaMs)),
        ],
      );

  MetricSection _statusSection(Inversor inversor, LecturaInversor? r) =>
      MetricSection(
        title: 'Estado',
        icon: Icons.info_outline,
        metrics: [
          MetricEntry(
            'Dispositivo',
            inversor.estadoDispositivo ?? SolarFormat.emDash,
          ),
          MetricEntry('Modo', r?.modoOperacion ?? SolarFormat.emDash),
          MetricEntry('Fallo', SolarFormat.faultCode(r?.codigoFallo)),
          MetricEntry('CRC', _bool(r?.crcValido)),
          MetricEntry('Rol', _rol(inversor)),
          MetricEntry('Última lectura', _clock(r?.tiempo)),
        ],
      );

  static String _bool(bool? value) => switch (value) {
        null => SolarFormat.emDash,
        true => 'Sí',
        false => 'No',
      };

  static String _celsius(double? value) => value == null
      ? SolarFormat.emDash
      : '${value.toStringAsFixed(1)} °C';

  static String _rol(Inversor inversor) {
    if (inversor.esMaster == true) return 'MASTER';
    final slave = inversor.slaveId;
    return slave == null ? SolarFormat.emDash : 'SLAVE $slave';
  }

  static String _clock(DateTime? time) {
    if (time == null) return SolarFormat.emDash;
    final local = time.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}

/// Breadcrumb `Planta › Inversor` (spec §4).
///
/// El nombre de la planta es un enlace: fija el filtro de sitio y vuelve al
/// dashboard con ese chip seleccionado (el filtro sobrevive al ida y vuelta
/// porque el provider es de alcance app).
class DetailBreadcrumb extends StatelessWidget {
  const DetailBreadcrumb({
    super.key,
    required this.site,
    required this.inversor,
    required this.onSiteTap,
  });

  final String site;
  final String inversor;
  final VoidCallback onSiteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          InkWell(
            key: const Key('breadcrumb-site'),
            onTap: onSiteTap,
            borderRadius: BorderRadius.circular(4),
            child: Text(
              site,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            ' › ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              inversor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
