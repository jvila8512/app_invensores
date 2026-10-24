// test/support/manual_timer.dart

import 'dart:async';

/// `Timer` controlable a mano: [fire] ejecuta el callback pendiente y deja
/// el timer inactivo, igual que un `Timer` de un solo disparo real.
class ManualTimer implements Timer {
  ManualTimer(this._callback);

  final void Function() _callback;
  bool _active = true;
  int _tick = 0;

  @override
  int get tick => _tick;

  @override
  bool get isActive => _active;

  @override
  void cancel() => _active = false;

  /// Dispara el callback si el timer sigue activo. Devuelve `false` si ya
  /// fue cancelado o disparado.
  bool fire() {
    if (!_active) return false;
    _active = false;
    _tick++;
    _callback();
    return true;
  }
}

/// Fabrica de [ManualTimer] con la misma firma que `TimerFactory`.
class ManualTimerFactory {
  final List<ManualTimer> timers = <ManualTimer>[];

  Timer call(Duration duration, void Function() callback) {
    final timer = ManualTimer(callback);
    timers.add(timer);
    return timer;
  }

  /// Timers creados y todavia no disparados/cancelados.
  List<ManualTimer> get active =>
      timers.where((timer) => timer.isActive).toList();

  ManualTimer get latest => timers.last;

  /// Dispara el ultimo timer si sigue activo.
  bool fireLatest() {
    if (timers.isEmpty) return false;
    return timers.last.fire();
  }
}
