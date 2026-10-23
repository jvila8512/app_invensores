// lib/domain/policy/modo_operacion.dart

/// Mapeo de `modoOperacion` por marca (spec T-6).
///
/// El backend define `modoOperacion` como **string libre dependiente de la
/// marca**: en Dart NUNCA se modela como enum. Los valores conocidos se
/// muestran legibles (`GRID_TIE` => `GRID TIE`); cualquier valor
/// desconocido — incluido `DESCONOCIDO_n` de Felicity — se muestra crudo,
/// sin lanzar excepcion.
class ModoOperacion {
  const ModoOperacion._();

  /// Valor ausente (nulo o vacio): el mismo guion largo que el resto de
  /// datos faltantes.
  static const String ausente = '—';

  /// Catalogo Felicity (spec T-6). `DESCONOCIDO_n` no esta aqui a proposito:
  /// el codigo se reporta literal.
  static const Map<String, String> felicity = {
    'SIN_RED': 'SIN RED',
    'RED': 'RED',
    'SOLAR': 'SOLAR',
    'HIBRIDO': 'HIBRIDO',
    'BATERIA': 'BATERIA',
  };

  /// Catalogo MUST (spec T-6).
  static const Map<String, String> must = {
    'POWER_ON': 'POWER ON',
    'SELF_TEST': 'SELF TEST',
    'OFF_GRID': 'OFF GRID',
    'GRID_TIE': 'GRID TIE',
    'BYPASS': 'BYPASS',
    'CHARGING': 'CHARGING',
    'FAULT': 'FAULT',
  };

  /// Etiqueta a mostrar para [raw].
  ///
  /// [marcaNombre] es `inversor.marca?.nombre` (sin distinguir mayusculas).
  /// Con marca conocida solo se aceptan sus valores; sin marca (o con una
  /// desconocida) se prueban ambos catalogos. Lo que no este mapeado se
  /// devuelve tal cual.
  static String display(String? raw, {String? marcaNombre}) {
    if (raw == null || raw.isEmpty) return ausente;
    final catalog = _catalogFor(marcaNombre);
    if (catalog != null) return catalog[raw] ?? raw;
    return felicity[raw] ?? must[raw] ?? raw;
  }

  static Map<String, String>? _catalogFor(String? marcaNombre) {
    if (marcaNombre == null) return null;
    final marca = marcaNombre.toLowerCase();
    if (marca.contains('felicity')) return felicity;
    if (marca.contains('must')) return must;
    return null;
  }
}
