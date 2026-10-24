// test/infraestructure/periodic_poller_test.dart

import 'dart:async';

import 'package:etecsa_supervision/infraestructure/polling/periodic_poller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';
import '../support/manual_timer.dart';

/// Deja correr las microtareas que reprograman el siguiente tick.
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('PeriodicPoller — ciclo basico', () {
    test(
      'programa el primer tick tras el intervalo y ejecuta uno por ciclo',
      () async {
        final factory = ManualTimerFactory();
        var calls = 0;
        final poller = PeriodicPoller(
          interval: const Duration(seconds: 5),
          onTick: () async => calls++,
          timerFactory: factory.call,
        );

        poller.start();
        expect(poller.isRunning, isTrue);
        expect(factory.active, hasLength(1));
        expect(calls, 0);

        factory.fireLatest();
        await _flush();
        expect(calls, 1);
        expect(factory.active, hasLength(1));

        factory.fireLatest();
        await _flush();
        expect(calls, 2);

        poller.dispose();
      },
    );

    test(
      'no solapa: no hay nuevo timer hasta que termina el tick en vuelo',
      () async {
        final factory = ManualTimerFactory();
        final gate = Completer<void>();
        var calls = 0;
        final poller = PeriodicPoller(
          interval: const Duration(seconds: 5),
          onTick: () async {
            calls++;
            await gate.future;
          },
          timerFactory: factory.call,
        );

        poller.start();
        factory.fireLatest();
        expect(calls, 1);
        expect(factory.active, isEmpty);
        expect(factory.fireLatest(), isFalse);

        gate.complete();
        await _flush();
        expect(factory.active, hasLength(1));

        factory.fireLatest();
        await _flush();
        expect(calls, 2);

        poller.dispose();
      },
    );
  });

  group('PeriodicPoller — pausa y disposicion', () {
    test('pause detiene los ticks y resume los reanuda', () async {
      final factory = ManualTimerFactory();
      var calls = 0;
      final poller = PeriodicPoller(
        interval: const Duration(seconds: 5),
        onTick: () async => calls++,
        timerFactory: factory.call,
      );

      poller.start();
      poller.pause();
      expect(poller.isRunning, isFalse);
      expect(factory.active, isEmpty);
      expect(factory.fireLatest(), isFalse);
      expect(calls, 0);

      poller.resume();
      expect(poller.isRunning, isTrue);
      expect(factory.active, hasLength(1));
      factory.fireLatest();
      await _flush();
      expect(calls, 1);

      poller.dispose();
    });

    test('dispose cancela el timer y no vuelve a programar', () async {
      final factory = ManualTimerFactory();
      var calls = 0;
      final poller = PeriodicPoller(
        interval: const Duration(seconds: 5),
        onTick: () async => calls++,
        timerFactory: factory.call,
      );

      poller.start();
      poller.dispose();
      expect(poller.isDisposed, isTrue);
      expect(factory.active, isEmpty);
      expect(factory.fireLatest(), isFalse);

      await _flush();
      expect(calls, 0);
    });

    test('dispose durante un tick no encadena otro', () async {
      final factory = ManualTimerFactory();
      final gate = Completer<void>();
      final poller = PeriodicPoller(
        interval: const Duration(seconds: 5),
        onTick: () => gate.future,
        timerFactory: factory.call,
      );

      poller.start();
      factory.fireLatest();
      poller.dispose();
      gate.complete();
      await _flush();
      expect(factory.active, isEmpty);
    });
  });

  group('PeriodicPoller — errores y reloj', () {
    test('un error del tick no corta el ciclo y llega a onError', () async {
      final factory = ManualTimerFactory();
      final errors = <Object>[];
      var calls = 0;
      final poller = PeriodicPoller(
        interval: const Duration(seconds: 5),
        onTick: () async {
          calls++;
          throw StateError('fallo de red');
        },
        onError: (error, stackTrace) => errors.add(error),
        timerFactory: factory.call,
      );

      poller.start();
      factory.fireLatest();
      await _flush();

      expect(calls, 1);
      expect(errors, hasLength(1));
      expect(errors.single, isA<StateError>());
      expect(factory.active, hasLength(1));

      poller.dispose();
    });

    test('lastTickAt usa el reloj inyectado', () async {
      final factory = ManualTimerFactory();
      final clock = FakeClock(DateTime.utc(2026, 6, 17, 12));
      final poller = PeriodicPoller(
        interval: const Duration(seconds: 5),
        onTick: () async {},
        clock: clock.now,
        timerFactory: factory.call,
      );

      poller.start();
      factory.fireLatest();
      await _flush();

      expect(poller.lastTickAt, DateTime.utc(2026, 6, 17, 12));

      poller.dispose();
    });
  });
}
