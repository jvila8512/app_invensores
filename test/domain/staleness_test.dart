import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/domain/policy/staleness_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/fixtures.dart';

void main() {
  const policy = StalenessPolicy();
  final clock = FakeClock(DateTime.utc(2026, 6, 17, 12));

  group('StalenessPolicy — umbral (T-5 / design D2)', () {
    test('gateway sin tiempoEsperaMs cae al default de 10 s => 25 s', () {
      expect(policy.thresholdFor(null), const Duration(seconds: 25));
      expect(
        policy.thresholdFor(buildGateway(tiempoEsperaMs: null)),
        const Duration(seconds: 25),
      );
    });

    test('usa la cadencia del gateway cuando expone tiempoEsperaMs', () {
      expect(
        policy.thresholdFor(buildGateway(tiempoEsperaMs: 10000)),
        const Duration(seconds: 25),
      );
      expect(
        policy.thresholdFor(buildGateway(tiempoEsperaMs: 60000)),
        const Duration(seconds: 150),
      );
    });

    test('la cadencia se acota al minimo de 5 s que usa el backend', () {
      expect(
        policy.thresholdFor(buildGateway(tiempoEsperaMs: 4000)),
        const Duration(milliseconds: 12500),
      );
    });

    test('el umbral es inyectable por constructor', () {
      const custom = StalenessPolicy(
        defaultCadence: Duration(seconds: 6),
        multiplier: 3,
      );
      expect(custom.thresholdFor(null), const Duration(seconds: 18));
      // Un default por debajo del piso de 5 s tambien se acota.
      const clampedDefault = StalenessPolicy(
        defaultCadence: Duration(seconds: 4),
      );
      expect(
        clampedDefault.thresholdFor(null),
        const Duration(milliseconds: 12500),
      );
    });
  });

  group('StalenessPolicy — calculo con reloj inyectado', () {
    test('lectura fresca (6 s con umbral de 25 s) esta ONLINE', () {
      final lecturaTiempo = clock.now().subtract(const Duration(seconds: 6));
      expect(
        policy.isStale(
          now: clock.now(),
          lecturaTiempo: lecturaTiempo,
          gateway: buildGateway(),
        ),
        isFalse,
      );
      expect(
        policy.ageFor(now: clock.now(), lecturaTiempo: lecturaTiempo),
        const Duration(seconds: 6),
      );
    });

    test('lectura vieja (40 s) esta OFFLINE', () {
      expect(
        policy.isStale(
          now: clock.now(),
          lecturaTiempo:
              clock.now().subtract(const Duration(seconds: 40)),
          gateway: buildGateway(),
        ),
        isTrue,
      );
    });

    test('frontera: exactamente 25 s sigue ONLINE, 1 ms mas OFFLINE', () {
      final gateway = buildGateway();
      expect(
        policy.isStale(
          now: clock.now(),
          lecturaTiempo: clock.now().subtract(const Duration(seconds: 25)),
          gateway: gateway,
        ),
        isFalse,
      );
      expect(
        policy.isStale(
          now: clock.now(),
          lecturaTiempo:
              clock.now().subtract(const Duration(milliseconds: 25001)),
          gateway: gateway,
        ),
        isTrue,
      );
    });

    test('lectura sin tiempo se considera OFFLINE (nunca NORMAL)', () {
      expect(
        policy.isStale(now: clock.now(), lecturaTiempo: null),
        isTrue,
      );
      expect(
        policy.ageFor(now: clock.now(), lecturaTiempo: null),
        isNull,
      );
    });

    test('fecha futura por desfase de reloj no marca OFFLINE', () {
      expect(
        policy.isStale(
          now: clock.now(),
          lecturaTiempo: clock.now().add(const Duration(seconds: 5)),
          gateway: buildGateway(),
        ),
        isFalse,
      );
    });

    test('readingIsStale trabaja sobre la entidad LecturaInversor', () {
      expect(
        policy.readingIsStale(
          now: clock.now(),
          lectura: buildLectura(
            tiempo: clock.now().subtract(const Duration(seconds: 40)),
          ),
          gateway: buildGateway(),
        ),
        isTrue,
      );
      expect(
        policy.readingIsStale(
          now: clock.now(),
          lectura: buildLectura(tiempo: clock.now()),
          gateway: buildGateway(),
        ),
        isFalse,
      );
      expect(
        policy.readingIsStale(
          now: clock.now(),
          lectura: const LecturaInversor(),
        ),
        isTrue,
      );
    });

    test('lastSeen formatea "last seen Xs" en segundos', () {
      expect(StalenessPolicy.lastSeen(const Duration(seconds: 40)), '40s');
      expect(StalenessPolicy.lastSeen(const Duration(seconds: 6)), '6s');
      expect(
        StalenessPolicy.lastSeen(const Duration(milliseconds: 6500)),
        '6s',
      );
      expect(StalenessPolicy.lastSeen(const Duration(seconds: -3)), '0s');
    });
  });
}
