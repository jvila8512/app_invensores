// lib/presentation/provider/kpis_provider.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/domain/policy/staleness_policy.dart';
import 'package:etecsa_supervision/presentation/provider/catalog_provider.dart';
import 'package:etecsa_supervision/presentation/provider/latest_readings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indicadores agregados de la flota (spec Â§2).
///
/// Clase pura e inmutable: los tests la construyen sin Riverpod ni widgets.
class FleetKpis {
  const FleetKpis({
    required this.totalPvW,
    required this.online,
    required this.total,
    required this.inAlarm,
    required this.avgEfficiencyPct,
  });

  /// Suma de `pvPotenciaW` de las lecturas con dato; `null` si ninguna lo
  /// tiene (se pinta `â€”`, nunca `0`).
  final double? totalPvW;

  /// Inversores con lectura fresca.
  final int online;

  /// Inversores del catalogo.
  final int total;

  /// Inversores con `codigoFallo > 0`.
  final int inAlarm;

  /// Promedio de `eficienciaPct`; `null` si ninguna lectura lo trae.
  final double? avgEfficiencyPct;

  static const FleetKpis empty = FleetKpis(
    totalPvW: null,
    online: 0,
    total: 0,
    inAlarm: 0,
    avgEfficiencyPct: null,
  );

  /// Calcula los KPI a partir del catalogo y de las lecturas indexadas.
  factory FleetKpis.from({
    required List<Inversor> inverters,
    required Map<int, LecturaInversor> readings,
    required DateTime now,
    StalenessPolicy policy = const StalenessPolicy(),
  }) {
    var totalPvW = 0.0;
    var hasPv = false;
    var online = 0;
    var inAlarm = 0;
    var efficiencySum = 0.0;
    var efficiencyCount = 0;

    for (final inversor in inverters) {
      final id = inversor.id;
      final reading = id == null ? null : readings[id];
      if (reading != null) {
        final pv = reading.pvPotenciaW;
        if (pv != null) {
          totalPvW += pv;
          hasPv = true;
        }
        if (!policy.readingIsStale(
          now: now,
          lectura: reading,
          gateway: inversor.gateway,
        )) {
          online++;
        }
        if (reading.enAlarma) inAlarm++;
        final efficiency = reading.eficienciaPct;
        if (efficiency != null) {
          efficiencySum += efficiency;
          efficiencyCount++;
        }
      }
    }

    return FleetKpis(
      totalPvW: hasPv ? totalPvW : null,
      online: online,
      total: inverters.length,
      inAlarm: inAlarm,
      avgEfficiencyPct:
          efficiencyCount == 0 ? null : efficiencySum / efficiencyCount,
    );
  }
}

/// Timestamp del calculo de KPI; inyectable para tests deterministas.
final kpisClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// KPI derivados de catalogo + lecturas. Cambia con cada sondeo, igual que
/// los valores que muestra.
final fleetKpisProvider = Provider<FleetKpis>((ref) {
  final catalog = ref.watch(inverterCatalogProvider).value;
  final readings = ref.watch(latestReadingsProvider).value;
  if (catalog == null || readings == null) return FleetKpis.empty;
  return FleetKpis.from(
    inverters: catalog,
    readings: readings,
    now: ref.watch(kpisClockProvider)(),
  );
}, isAutoDispose: true);
