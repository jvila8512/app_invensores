/// Formateo de numeros para presentacion.
///
/// Implementacion propia (sin `intl`) para no depender de una libreria
/// externa que el dominio de supervision no necesita.
class HumanFormat {
  const HumanFormat._();

  /// Numero compacto: `1234` -> `1.2K`, `2500000` -> `2.5M`.
  static String number(double number) {
    if (number.isNaN) return '—';
    if (number.abs() >= 1000000) {
      return '${_trim(number / 1000000)}M';
    }
    if (number.abs() >= 1000) {
      return '${_trim(number / 1000)}K';
    }
    return _trim(number);
  }

  /// Decimal simple con separador de miles (es-ES).
  static String decimal(double number, {int decimals = 2}) {
    if (number.isNaN) return '—';
    final fixed = number.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integer = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) buffer.write('.');
      buffer.write(integer[i]);
    }
    return parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
  }

  static String _trim(double value) {
    final rounded = value.toStringAsFixed(1);
    return rounded.endsWith('.0') ? rounded.substring(0, rounded.length - 2) : rounded;
  }
}
