// lib/config/constants/environment.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuracion leida desde `.env`.
///
/// El `.env` es gitignored, por lo que todos los valores tienen un fallback
/// sensato: la app debe arrancar aunque el archivo no exista (tests included).
class Environment {
  const Environment._();

  static const String defaultApiBaseUrl = 'http://localhost:8080';

  /// Base URL del backend ETECSA (`http://host:8080`, sin context-path).
  ///
  /// Se acepta tanto `API_BASE_URL` como `API_URL` para no romper un `.env`
  /// escrito con el nombre anterior.
  static String get apiBaseUrl {
    final value = _read('API_BASE_URL');
    if (value.isNotEmpty) return value;
    return switch (_read('API_URL')) {
      '' => defaultApiBaseUrl,
      final url => url.endsWith('/') ? url.substring(0, url.length - 1) : url,
    };
  }

  /// Cuando es `true` la app usa las datasources fake y no hace red.
  static bool get useFakeData => _read('USE_FAKE_DATA').toLowerCase() == 'true';

  static String _read(String key) {
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      // `dotenv` no fue cargado: no hay valor de entorno.
      return '';
    }
  }
}
