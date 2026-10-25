// lib/infraestructure/auth/unauthorized_signal.dart

/// Senal de "sesion expirada" emitida por [AuthInterceptor] ante un 401.
///
/// Existe en la capa de infraestructura para que el interceptor no dependa
/// de la presentacion: la sesion se suscribe a esta senal en su `build`.
class UnauthorizedSignal {
  final List<void Function()> _listeners = <void Function()>[];

  void addListener(void Function() listener) => _listeners.add(listener);

  void removeListener(void Function() listener) => _listeners.remove(listener);

  /// Notifica a los suscriptores. Se copia la lista porque un listener puede
  /// darse de baja a si mismo durante la notificacion.
  void notify() {
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }
}
