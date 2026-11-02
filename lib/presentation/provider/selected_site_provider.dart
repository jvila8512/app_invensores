// lib/presentation/provider/selected_site_provider.dart

import 'package:etecsa_supervision/domain/policy/site_grouping.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sitio seleccionado en el filtro pegajoso del dashboard (spec §2).
///
/// `null` es el chip [SiteGrouping.todosLabel] (comportamiento por defecto).
/// Vive a nivel de app (sin autoDispose) para que la seleccion sobreviva al
/// scroll y al ida-y-vuelta al detalle del inversor (spec §4: el breadcrumb
/// fija este filtro).
class SelectedSiteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Selecciona un sitio o [SiteGrouping.todosLabel] para "todos".
  void select(String? site) => state = site;

  /// Vuelve al chip "Todos".
  void clear() => state = null;
}

final selectedSiteProvider =
    NotifierProvider<SelectedSiteNotifier, String?>(SelectedSiteNotifier.new);
