// lib/infraestructure/auth/token_holder.dart

/// JWT en memoria: es la fuente que lee el interceptor de `Authorization`.
///
/// Se mantiene aparte del almacenamiento seguro porque debe estar disponible
/// de forma síncrona en `onRequest`, y porque [logout] / un 401 deben poder
/// invalidar la sesión de inmediato sin esperar al Keychain.
class TokenHolder {
  String? _token;

  /// Token actual, o `null` si la sesión está cerrada.
  String? get token => _token;

  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Actualiza el token. Cadena vacía equivale a sin sesión.
  void set(String? value) {
    _token = (value == null || value.isEmpty) ? null : value;
  }

  void clear() => _token = null;
}
