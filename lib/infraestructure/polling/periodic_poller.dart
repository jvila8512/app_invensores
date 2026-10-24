// lib/infraestructure/polling/periodic_poller.dart

import 'dart:async';

/// Fabrica de temporizadores inyectable. Los tests la sustituyen por una
/// version manual para disparar los ticks sin esperar tiempo real.
typedef TimerFactory =
    Timer Function(Duration duration, void Function() callback);

/// Reloj inyectable; por defecto `DateTime.now` (design D5).
typedef Clock = DateTime Function();

/// Sondeo periodico **sin solapamiento** (spec §3: exactamente una peticion
/// por ciclo).
///
/// El siguiente tick se programa recien cuando el anterior termino. Si una
/// peticion tarda mas que [interval], el ciclo siguiente espera: nunca hay
/// dos peticiones en vuelo a la vez.
class PeriodicPoller {
  PeriodicPoller({
    required this.interval,
    required this.onTick,
    TimerFactory? timerFactory,
    Clock? clock,
    this.onError,
  }) : _timerFactory = timerFactory ?? _defaultTimerFactory,
       _clock = clock ?? DateTime.now;

  /// Cadencia entre el fin de un tick y el inicio del siguiente.
  final Duration interval;

  /// Trabajo de cada ciclo (una peticion por ciclo).
  final Future<void> Function() onTick;

  /// Recibe los errores de [onTick] sin romper la cadena de sondeo.
  final void Function(Object error, StackTrace stackTrace)? onError;

  final TimerFactory _timerFactory;
  final Clock _clock;

  Timer? _timer;
  bool _running = false;
  bool _paused = false;
  bool _disposed = false;
  bool _ticking = false;

  /// Instante en que empezo el ultimo tick, segun el reloj inyectado.
  DateTime? lastTickAt;

  /// Hay un ciclo activo (arrancado y no pausado).
  bool get isRunning => _running && !_paused;

  /// El poller fue detenido definitivamente.
  bool get isDisposed => _disposed;

  /// Arranca el sondeo. El primer tick ocurre despues de [interval].
  void start() {
    if (_disposed || _running) return;
    _running = true;
    _paused = false;
    _scheduleNext();
  }

  /// Detiene los ticks sin destruir el poller: [resume] los reanuda. Si hay
  /// un tick en vuelo, se deja terminar pero no se reprograma.
  void pause() {
    if (_disposed || _paused) return;
    _paused = true;
    _timer?.cancel();
    _timer = null;
  }

  /// Reanuda el sondeo pausado.
  void resume() {
    if (_disposed || !_running || !_paused) return;
    _paused = false;
    _scheduleNext();
  }

  /// Cancela el temporizador y no vuelve a programar ticks. Un tick en
  /// vuelo termina, pero ya no encadena otro.
  void dispose() {
    _disposed = true;
    _running = false;
    _paused = false;
    _timer?.cancel();
    _timer = null;
  }

  void _scheduleNext() {
    if (_disposed || !_running || _paused || _ticking) return;
    _timer?.cancel();
    _timer = _timerFactory(interval, () => unawaited(_handleTick()));
  }

  Future<void> _handleTick() async {
    if (_disposed || !_running || _paused || _ticking) return;
    _ticking = true;
    lastTickAt = _clock();
    try {
      await onTick();
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
    } finally {
      _ticking = false;
      _scheduleNext();
    }
  }
}

Timer _defaultTimerFactory(Duration duration, void Function() callback) =>
    Timer(duration, callback);
