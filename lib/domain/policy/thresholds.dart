// lib/domain/policy/thresholds.dart

/// Color semantico de un umbral: la presentacion lo traduce a los tokens
/// T-4 (`#22c55e` / `#f59e0b` / `#ef4444`). Pure Dart, sin `dart:ui`.
enum ThresholdColor { green, amber, red }

/// Umbrales de color copiados verbatim del dashboard web de referencia
/// (spec T-3).
///
/// Todos devuelven `null` cuando el dato no existe: la UI pinta `—` sin
/// color de alarma en lugar de asumir rojo o verde. Los parametros usan
/// `num?` porque los DTO mandan enteros (`socPct`, `cargaPorcentaje`) y
/// dobles (`eficienciaPct`) indistintamente.
class Thresholds {
  const Thresholds._();

  /// SOC: `>60` verde, `>30` ambar, resto rojo. En alarma manda el rojo
  /// siempre, aunque el SOC este alto.
  static ThresholdColor? soc(num? socPct, {required bool enAlarma}) {
    if (enAlarma) return ThresholdColor.red;
    if (socPct == null) return null;
    if (socPct > 60) return ThresholdColor.green;
    if (socPct > 30) return ThresholdColor.amber;
    return ThresholdColor.red;
  }

  /// Eficiencia: `>80` verde, `>70` ambar, resto rojo.
  static ThresholdColor? eficiencia(num? eficienciaPct) {
    if (eficienciaPct == null) return null;
    if (eficienciaPct > 80) return ThresholdColor.green;
    if (eficienciaPct > 70) return ThresholdColor.amber;
    return ThresholdColor.red;
  }

  /// Voltaje de baterias: `<47.5 V` rojo, si no verde.
  static ThresholdColor? bateriaVoltaje(num? voltios) {
    if (voltios == null) return null;
    return voltios < 47.5 ? ThresholdColor.red : ThresholdColor.green;
  }

  /// Carga (uso %, NO el SOC): `>95%` rojo, `>80%` ambar, si no verde.
  static ThresholdColor? carga(num? cargaPorcentaje) {
    if (cargaPorcentaje == null) return null;
    if (cargaPorcentaje > 95) return ThresholdColor.red;
    if (cargaPorcentaje > 80) return ThresholdColor.amber;
    return ThresholdColor.green;
  }

  /// Latencia del gateway: `>30 ms` ambar, si no verde.
  static ThresholdColor? latencia(num? latenciaMs) {
    if (latenciaMs == null) return null;
    return latenciaMs > 30 ? ThresholdColor.amber : ThresholdColor.green;
  }

  /// Codigo de fallo: `>0` rojo, si no verde.
  static ThresholdColor? codigoFallo(int? codigoFallo) {
    if (codigoFallo == null) return null;
    return codigoFallo > 0 ? ThresholdColor.red : ThresholdColor.green;
  }

  /// Corriente de baterias: `>=0` verde, si no rojo.
  static ThresholdColor? corrienteBateria(num? corrienteA) {
    if (corrienteA == null) return null;
    return corrienteA >= 0 ? ThresholdColor.green : ThresholdColor.red;
  }

  /// Severidad de alerta por substring, sin distinguir mayusculas:
  /// `crit`/`alta` rojo, `adv`/`med`/`warn` ambar, resto verde.
  static ThresholdColor? severidadAlerta(String? severidad) {
    if (severidad == null) return null;
    final s = severidad.toLowerCase();
    if (s.contains('crit') || s.contains('alta')) return ThresholdColor.red;
    if (s.contains('adv') || s.contains('med') || s.contains('warn')) {
      return ThresholdColor.amber;
    }
    return ThresholdColor.green;
  }
}
