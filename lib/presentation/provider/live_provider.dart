// lib/presentation/provider/live_provider.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/presentation/provider/catalog_provider.dart';
import 'package:etecsa_supervision/presentation/provider/data_source_overrides_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado del canal en vivo del detalle (spec §3).
enum LiveStatus {
  /// Llegan lecturas en vivo (STOMP o el fallback REST con datos frescos).
  connected,

  /// El canal fallo y se reintenta.
  reconnecting,

  /// Todavia sin lecturas: sondeo en curso.
  polling,
}

/// Etiqueta del banner, en el idioma de la UI.
extension LiveStatusLabel on LiveStatus {
  String get label => switch (this) {
        LiveStatus.connected => 'CONECTADO',
        LiveStatus.reconnecting => 'RECONECTANDO',
        LiveStatus.polling => 'SONDEO',
      };
}

/// Lectura en vivo de un inversor: **una** suscripcion por pantalla
/// (spec §3). El repositorio decide el transporte (STOMP si hay cliente
/// conectado, si no sondeo REST) sin que la UI lo sepa.
final liveReadingProvider =
    StreamProvider.family<LecturaInversor, int>((ref, inversorId) {
  return ref.watch(inverterRepositoryProvider).watchLive(inversorId);
}, isAutoDispose: true);

/// Estado derivado del canal en vivo, para el banner del detalle.
final liveStatusProvider = Provider.family<LiveStatus, int>((ref, inversorId) {
  final reading = ref.watch(liveReadingProvider(inversorId));
  if (reading.hasError) return LiveStatus.reconnecting;
  if (reading.hasValue) return LiveStatus.connected;
  return LiveStatus.polling;
}, isAutoDispose: true);

/// Historial real del inversor para el grafico (spec §4: nunca `Random()`).
final historyProvider =
    FutureProvider.family<List<LecturaInversor>, int>((ref, inversorId) {
  return ref.watch(inverterRepositoryProvider).fetchHistory(inversorId);
}, isAutoDispose: true);

/// Inversor del catalogo por id. El catalogo ya esta cargado cuando se
/// navega desde el dashboard; `null` mientras carga o si no existe.
final inversorByIdProvider = Provider.family<Inversor?, int>((ref, id) {
  final catalog = ref.watch(inverterCatalogProvider).value;
  if (catalog == null) return null;
  for (final inversor in catalog) {
    if (inversor.id == id) return inversor;
  }
  return null;
}, isAutoDispose: true);
