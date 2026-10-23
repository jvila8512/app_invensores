// lib/domain/policy/staleness_policy.dart

import 'package:etecsa_supervision/domain/entities/gateway.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';

/// Politica de frescura de las lecturas (spec T-5, design D2).
///
/// `offline <=> now - lectura.tiempo > 2.5 * max(cadencia, 5 s)`
///
/// Con la cadencia por defecto de 10 s (usada cuando el gateway no expone
/// `tiempoEsperaMs`) el corte queda en 25 s.
///
/// El reloj se inyecta como parametro (`now`): la politica NUNCA llama a
/// `DateTime.now()`, asi los tests son deterministas (design D5, `Clock`
/// inyectable). El umbral tambien es inyectable via constructor.
class StalenessPolicy {
  const StalenessPolicy({
    this.defaultCadence = const Duration(seconds: 10),
    this.multiplier = 2.5,
  });

  /// Cadencia usada cuando el gateway no expone `tiempoEsperaMs` (10 s =>
  /// corte de 25 s, "documented 10 s default fallback").
  final Duration defaultCadence;

  /// Multiplicador del umbral (2.5 en la referencia).
  final double multiplier;

  /// Umbral de OFFLINE para el gateway dado.
  ///
  /// La cadencia efectiva es `max(gateway.tiempoEsperaMs / 1000, 5) s`
  /// (el backend no sondea mas rapido que 5 s), acotada ademas a 3600 s.
  Duration thresholdFor(Gateway? gateway) {
    final cadenceMs = gateway?.tiempoEsperaMs ?? defaultCadence.inMilliseconds;
    final cadenceSeconds = (cadenceMs / 1000).clamp(5.0, 3600.0);
    return Duration(milliseconds: (multiplier * cadenceSeconds * 1000).round());
  }

  /// Edad de la lectura en `now`, o `null` si la lectura no tiene
  /// `tiempo` (frescura desconocida).
  Duration? ageFor({required DateTime now, DateTime? lecturaTiempo}) =>
      lecturaTiempo == null ? null : now.difference(lecturaTiempo);

  /// `true` si la lectura esta vencida (badge OFFLINE).
  ///
  /// - Sin `tiempo` => `true` (frescura desconocida: jamas se muestra
  ///   NORMAL para una unidad sin datos, spec §3).
  /// - Frontera: la igualdad exacta NO es vencida (la regla es `>`).
  /// - Fecha futura (desfase de reloj entre cliente y backend) => no
  ///   vencida.
  bool isStale({
    required DateTime now,
    DateTime? lecturaTiempo,
    Gateway? gateway,
  }) {
    if (lecturaTiempo == null) return true;
    final age = now.difference(lecturaTiempo);
    if (age.isNegative) return false;
    return age > thresholdFor(gateway);
  }

  /// Misma comprobacion recibiendo la entidad completa (la usa la UI).
  bool readingIsStale({
    required DateTime now,
    required LecturaInversor lectura,
    Gateway? gateway,
  }) =>
      isStale(now: now, lecturaTiempo: lectura.tiempo, gateway: gateway);

  /// `last seen Xs` de la spec: segundos enteros con sufijo `s`.
  static String lastSeen(Duration age) {
    final seconds = age.isNegative ? 0 : age.inSeconds;
    return '${seconds}s';
  }
}
