import 'package:etecsa_supervision/domain/policy/thresholds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Thresholds.soc (T-3)', () {
    test('>60 verde, >30 ambar, resto rojo', () {
      expect(Thresholds.soc(61, enAlarma: false), ThresholdColor.green);
      expect(Thresholds.soc(60, enAlarma: false), ThresholdColor.amber);
      expect(Thresholds.soc(31, enAlarma: false), ThresholdColor.amber);
      expect(Thresholds.soc(30, enAlarma: false), ThresholdColor.red);
      expect(Thresholds.soc(0, enAlarma: false), ThresholdColor.red);
    });

    test('en alarma el SOC queda rojo aunque este alto', () {
      expect(Thresholds.soc(90, enAlarma: true), ThresholdColor.red);
      expect(Thresholds.soc(null, enAlarma: true), ThresholdColor.red);
    });

    test('SOC ausente sin alarma => sin color', () {
      expect(Thresholds.soc(null, enAlarma: false), isNull);
    });
  });

  group('Thresholds.eficiencia (T-3)', () {
    test('>80 verde, >70 ambar, resto rojo', () {
      expect(Thresholds.eficiencia(81), ThresholdColor.green);
      expect(Thresholds.eficiencia(80), ThresholdColor.amber);
      expect(Thresholds.eficiencia(71), ThresholdColor.amber);
      expect(Thresholds.eficiencia(70), ThresholdColor.red);
      expect(Thresholds.eficiencia(0), ThresholdColor.red);
      expect(Thresholds.eficiencia(null), isNull);
    });
  });

  group('Thresholds.bateriaVoltaje (T-3)', () {
    test('<47.5 V rojo, si no verde', () {
      expect(Thresholds.bateriaVoltaje(47.4), ThresholdColor.red);
      expect(Thresholds.bateriaVoltaje(47.5), ThresholdColor.green);
      expect(Thresholds.bateriaVoltaje(51.2), ThresholdColor.green);
      expect(Thresholds.bateriaVoltaje(null), isNull);
    });
  });

  group('Thresholds.carga (T-3)', () {
    test('>95% rojo, >80% ambar, resto verde', () {
      expect(Thresholds.carga(96), ThresholdColor.red);
      expect(Thresholds.carga(95), ThresholdColor.amber);
      expect(Thresholds.carga(81), ThresholdColor.amber);
      expect(Thresholds.carga(80), ThresholdColor.green);
      expect(Thresholds.carga(0), ThresholdColor.green);
      expect(Thresholds.carga(null), isNull);
    });
  });

  group('Thresholds.latencia (T-3)', () {
    test('>30 ms ambar, si no verde', () {
      expect(Thresholds.latencia(31), ThresholdColor.amber);
      expect(Thresholds.latencia(30), ThresholdColor.green);
      expect(Thresholds.latencia(0), ThresholdColor.green);
      expect(Thresholds.latencia(null), isNull);
    });
  });

  group('Thresholds.codigoFallo (T-3)', () {
    test('>0 rojo, 0 verde, ausente sin color', () {
      expect(Thresholds.codigoFallo(7), ThresholdColor.red);
      expect(Thresholds.codigoFallo(1), ThresholdColor.red);
      expect(Thresholds.codigoFallo(0), ThresholdColor.green);
      expect(Thresholds.codigoFallo(null), isNull);
    });
  });

  group('Thresholds.corrienteBateria (T-3)', () {
    test('>=0 verde, negativa roja, ausente sin color', () {
      expect(Thresholds.corrienteBateria(0), ThresholdColor.green);
      expect(Thresholds.corrienteBateria(12.5), ThresholdColor.green);
      expect(Thresholds.corrienteBateria(-0.5), ThresholdColor.red);
      expect(Thresholds.corrienteBateria(null), isNull);
    });
  });

  group('Thresholds.severidadAlerta (T-3)', () {
    test('crit/alta => rojo (sin distinguir mayusculas)', () {
      expect(Thresholds.severidadAlerta('CRITICA'), ThresholdColor.red);
      expect(Thresholds.severidadAlerta('crit'), ThresholdColor.red);
      expect(Thresholds.severidadAlerta('ALTA'), ThresholdColor.red);
    });

    test('adv/med/warn => ambar', () {
      expect(Thresholds.severidadAlerta('MEDIA'), ThresholdColor.amber);
      expect(Thresholds.severidadAlerta('ADVERTENCIA'), ThresholdColor.amber);
      expect(Thresholds.severidadAlerta('warning'), ThresholdColor.amber);
    });

    test('cualquier otra severidad => verde', () {
      expect(Thresholds.severidadAlerta('BAJA'), ThresholdColor.green);
      expect(Thresholds.severidadAlerta('info'), ThresholdColor.green);
      expect(Thresholds.severidadAlerta(''), ThresholdColor.green);
      expect(Thresholds.severidadAlerta(null), isNull);
    });
  });

  group('Thresholds — entradas mixtas enteros/dobles', () {
    test('los umbrales aceptan int y double por igual', () {
      expect(Thresholds.soc(82, enAlarma: false), ThresholdColor.green);
      expect(Thresholds.soc(82.0, enAlarma: false), ThresholdColor.green);
      expect(Thresholds.eficiencia(92), ThresholdColor.green);
      expect(Thresholds.eficiencia(92.0), ThresholdColor.green);
    });
  });
}
