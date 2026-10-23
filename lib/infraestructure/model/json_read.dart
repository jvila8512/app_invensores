// lib/infraestructure/model/json_read.dart

/// Lectura defensiva de los campos de los DTO JHipster.
///
/// El backend puede mandar `null`, un entero donde el DTO Java declara
/// `Double`, o una fecha mal formada. Estas funciones NUNCA lanzan: lo que
/// no se pueda interpretar queda `null` y la UI lo pinta como `—`.
library;

int? readInt(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

double? readDouble(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is num) return value.toDouble();
  return null;
}

bool? readBool(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  return value is bool ? value : null;
}

String? readString(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  return value is String ? value : null;
}

/// Instant/LocalDate ISO-8601 normalizado a **UTC** (`DateTime` compara
/// tambien la zona; sin normalizar dos lecturas del mismo instante no
/// serian iguales).
DateTime? readInstant(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is! String) return null;
  return DateTime.tryParse(value)?.toUtc();
}

Map<String, dynamic>? readObject(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<String>? readStringList(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is! List) return null;
  return [for (final item in value) if (item is String) item];
}
