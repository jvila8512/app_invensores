// lib/domain/policy/site_grouping.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';

/// Agrupacion de inversores por sitio (spec §2).
///
/// El dashboard web original agrupaba por gateway y sin filtro de sitio;
/// esta es la mejora del cambio: claves ordenadas por nombre de sitio,
/// miembros ordenados por nombre de inversor, y el filtro por defecto
/// `Todos` (= seleccion `null`).
class SiteGrouping {
  const SiteGrouping._();

  /// Etiqueta del filtro por defecto. La seleccion `null` equivale a esto.
  static const String todosLabel = 'Todos';

  /// Clave de grupo para un inversor sin sitio: el mismo guion largo que
  /// cualquier valor ausente (nunca se inventa un nombre).
  static const String sinSitioLabel = '—';

  /// Clave de agrupacion de un inversor (nombre de su sitio).
  static String siteKey(Inversor inversor) =>
      inversor.sitio?.nombre ?? sinSitioLabel;

  /// Inversores agrupados por nombre de sitio con dos ordenes
  /// deterministas: claves por nombre de sitio y miembros por nombre de
  /// inversor (empates resueltos por id).
  static Map<String, List<Inversor>> groupBySite(Iterable<Inversor> inverters) {
    final grouped = <String, List<Inversor>>{};
    for (final inversor in inverters) {
      grouped.putIfAbsent(siteKey(inversor), () => <Inversor>[]).add(inversor);
    }
    for (final members in grouped.values) {
      members.sort(_byNameThenId);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {
      for (final key in sortedKeys) key: grouped[key]!,
    };
  }

  /// Filtro por sitio. `null` (chip `Todos`, el default) devuelve todo.
  static List<Inversor> filterBySite(
    Iterable<Inversor> inverters,
    String? selectedSite,
  ) {
    if (selectedSite == null) return inverters.toList();
    return inverters.where((i) => siteKey(i) == selectedSite).toList();
  }

  /// Nombres de sitio presentes, ordenados (chips del filtro).
  static List<String> siteNames(Iterable<Inversor> inverters) =>
      groupBySite(inverters).keys.toList();

  static int _byNameThenId(Inversor a, Inversor b) {
    final byName = (a.nombre ?? '').compareTo(b.nombre ?? '');
    if (byName != 0) return byName;
    return (a.id ?? 0).compareTo(b.id ?? 0);
  }
}
