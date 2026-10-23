// test/support/fake_clock.dart

/// Reloj inyectable para tests deterministas.
///
/// El dominio NUNCA llama a `DateTime.now()`: el `now` entra por parametro
/// (design D5, `clockProvider`). Los tests crean un `FakeClock`, lo avanzan
/// a mano y lo pasan a las politicas.
class FakeClock {
  FakeClock(this.current);

  /// Instante actual del reloj.
  DateTime current;

  /// El `now` que ven las politicas.
  DateTime now() => current;

  /// Avanza (o retrocede, con duracion negativa) el reloj.
  void advance(Duration duration) => current = current.add(duration);
}
