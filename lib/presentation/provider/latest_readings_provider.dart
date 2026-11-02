// lib/presentation/provider/latest_readings_provider.dart

import 'dart:async';

import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/infraestructure/polling/periodic_poller.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cadencia del sondeo masivo del dashboard (spec §3).
///
/// Se expone como provider para que los tests la acorten sin esperar
/// segundos reales.
final latestReadingsPollIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 5),
);

/// Ultima lectura de cada inversor, refrescada por sondeo masivo.
///
/// `GET /api/dato-inversors/latest-readings` devuelve una lectura por
/// inversor; se indexa por `inversorId` para que cada tarjeta escuche solo
/// su propia entrada con `select`.
///
/// Reglas:
/// - Una peticion por ciclo, sin solapamiento (`PeriodicPoller`).
/// - Se hace una lectura inmediata al montar para no esperar 5 s en vacio.
/// - Si un ciclo falla se conserva el ultimo mapa conocido (datos viejos,
///   marcados como OFFLINE por la politica de frescura) en vez de vaciar la
///   pantalla.
/// - `isAutoDispose`: al salir del dashboard el sondeo se detiene.
final latestReadingsProvider =
    StreamProvider<Map<int, LecturaInversor>>((ref) {
  final repository = ref.watch(inverterRepositoryProvider);
  final interval = ref.watch(latestReadingsPollIntervalProvider);

  final controller = StreamController<Map<int, LecturaInversor>>();
  final latest = <int, LecturaInversor>{};
  var closed = false;

  Future<void> tick() async {
    try {
      final readings = await repository.fetchLatestReadings();
      for (final reading in readings) {
        final id = reading.inversorId;
        if (id != null) latest[id] = reading;
      }
      if (!closed) controller.add(Map.unmodifiable(latest));
    } catch (_) {
      // Se conserva el snapshot anterior; la frescura lo marca como viejo.
    }
  }

  final poller = PeriodicPoller(interval: interval, onTick: tick);

  ref.onDispose(() {
    closed = true;
    poller.dispose();
    controller.close();
  });

  unawaited(tick());
  poller.start();

  return controller.stream;
}, isAutoDispose: true);
