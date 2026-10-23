// lib/config/helper/solar_format.dart

/// Formateo de unidades del dominio solar (spec T-2, verbatim del
/// dashboard web de referencia).
///
/// Reglas:
/// - W => kW: 2 decimales en tarjeta y total de grupo, 1 decimal en KPI y
///   detalle.
/// - Wh => kWh: 1 decimal.
/// - V bateria/PV: 1 decimal. V AC (salida/red/bus): 0 decimales.
/// - A: 1 decimal. Hz: 1 decimal. %: 0 decimales.
/// - ms: 0 decimales + sufijo `ms`.
/// - kVA: `capacidadVa/1000`, 0 decimales.
/// - Codigo de fallo: `E` + 2 digitos con relleno de ceros => `E07`.
/// - Ausente (null / NaN / infinito): guion largo `—`, NUNCA `0` y nunca
///   una excepcion.
///
/// El sufijo de unidad va en el resultado (`45.0 kW`, `80%`, `35 ms`); el
/// codigo de fallo no lleva sufijo (`E07`). Un valor numerico REAL `0` si
/// se imprime (`0.00 kW`): solo lo ausente se vuelve `—`.
///
/// Los parametros usan `num?` porque el backend mezcla enteros
/// (`cargaPorcentaje`, `latenciaMs`) y dobles (`pvPotenciaW`).
///
/// Pure Dart (sin Flutter) para que el dominio sea unit-testable.
class SolarFormat {
  const SolarFormat._();

  /// Valor ausente.
  static const String emDash = '—';

  /// Potencia W => kW. [decimals]: 2 en tarjeta/total, 1 en KPI/detalle.
  static String kilowatts(num? watts, {int decimals = 2}) =>
      _scaled(watts, 1000, decimals, ' kW');

  /// Energia Wh => kWh (1 decimal).
  static String kilowatthours(num? wattHours, {int decimals = 1}) =>
      _scaled(wattHours, 1000, decimals, ' kWh');

  /// Potencia aparente VA => kVA (0 decimales).
  static String kilovoltAmperes(num? voltAmperes, {int decimals = 0}) =>
      _scaled(voltAmperes, 1000, decimals, ' kVA');

  /// Voltaje DC (bateria/PV): 1 decimal.
  static String volts(num? volts, {int decimals = 1}) =>
      _fixed(volts, decimals, ' V');

  /// Voltaje AC (salida/red/bus): 0 decimales.
  static String acVolts(num? volts) => _fixed(volts, 0, ' V');

  /// Corriente: 1 decimal.
  static String amperes(num? amperes) => _fixed(amperes, 1, ' A');

  /// Frecuencia: 1 decimal.
  static String hertz(num? hertz) => _fixed(hertz, 1, ' Hz');

  /// Porcentaje (SOC/carga/eficiencia): 0 decimales.
  static String percent(num? value) => _fixed(value, 0, '%');

  /// Latencia: 0 decimales + sufijo `ms`.
  static String milliseconds(num? ms) => _fixed(ms, 0, ' ms');

  /// Codigo de fallo: `E` + relleno a 2 digitos (`7` => `E07`, `0` =>
  /// `E00`, `123` => `E123`); ausente => `—`.
  static String faultCode(int? codigo) =>
      codigo == null ? emDash : 'E${codigo.toString().padLeft(2, '0')}';

  static String _scaled(num? value, num divisor, int decimals, String suffix) =>
      _fixed(value == null ? null : value / divisor, decimals, suffix);

  static String _fixed(num? value, int decimals, String suffix) {
    if (value == null || value.isNaN || value.isInfinite) return emDash;
    return '${value.toStringAsFixed(decimals)}$suffix';
  }
}
