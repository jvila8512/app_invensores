import 'package:etecsa_supervision/config/helper/solar_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SolarFormat — potencia y energia (T-2)', () {
    test('W => kW con 2 decimales (tarjeta y total de grupo)', () {
      expect(SolarFormat.kilowatts(12340), '12.34 kW');
      expect(SolarFormat.kilowatts(45000), '45.00 kW');
      expect(SolarFormat.kilowatts(0), '0.00 kW');
      expect(SolarFormat.kilowatts(-1000), '-1.00 kW');
    });

    test('W => kW con 1 decimal (KPI y detalle)', () {
      expect(SolarFormat.kilowatts(45000, decimals: 1), '45.0 kW');
      expect(SolarFormat.kilowatts(45400, decimals: 1), '45.4 kW');
      expect(SolarFormat.kilowatts(0, decimals: 1), '0.0 kW');
    });

    test('Wh => kWh con 1 decimal', () {
      expect(SolarFormat.kilowatthours(1500), '1.5 kWh');
      expect(SolarFormat.kilowatthours(0), '0.0 kWh');
    });

    test('VA => kVA con 0 decimales', () {
      expect(SolarFormat.kilovoltAmperes(5000), '5 kVA');
      expect(SolarFormat.kilovoltAmperes(5600), '6 kVA');
    });
  });

  group('SolarFormat — tension, corriente, frecuencia (T-2)', () {
    test('V DC (bateria/PV) con 1 decimal', () {
      expect(SolarFormat.volts(48.6), '48.6 V');
      expect(SolarFormat.volts(120.34), '120.3 V');
      expect(SolarFormat.volts(48), '48.0 V');
    });

    test('V AC (salida/red/bus) con 0 decimales', () {
      expect(SolarFormat.acVolts(220), '220 V');
      expect(SolarFormat.acVolts(220.6), '221 V');
      expect(SolarFormat.acVolts(400.2), '400 V');
    });

    test('A con 1 decimal', () {
      expect(SolarFormat.amperes(12.34), '12.3 A');
      expect(SolarFormat.amperes(0), '0.0 A');
    });

    test('Hz con 1 decimal', () {
      expect(SolarFormat.hertz(60), '60.0 Hz');
      expect(SolarFormat.hertz(59.94), '59.9 Hz');
    });
  });

  group('SolarFormat — porcentaje y latencia (T-2)', () {
    test('% con 0 decimales', () {
      expect(SolarFormat.percent(80), '80%');
      expect(SolarFormat.percent(80.6), '81%');
      expect(SolarFormat.percent(0), '0%');
    });

    test('ms con 0 decimales y sufijo', () {
      expect(SolarFormat.milliseconds(35), '35 ms');
      expect(SolarFormat.milliseconds(35.6), '36 ms');
      expect(SolarFormat.milliseconds(0), '0 ms');
    });

    test('acepta enteros y dobles indistintamente', () {
      expect(SolarFormat.kilowatts(45000), '45.00 kW');
      expect(SolarFormat.kilowatts(45000.0), '45.00 kW');
      expect(SolarFormat.percent(65), '65%');
      expect(SolarFormat.percent(65.0), '65%');
    });
  });

  group('SolarFormat — codigo de fallo (T-2)', () {
    test('E + 2 digitos con relleno de ceros', () {
      expect(SolarFormat.faultCode(7), 'E07');
      expect(SolarFormat.faultCode(0), 'E00');
      expect(SolarFormat.faultCode(42), 'E42');
      expect(SolarFormat.faultCode(123), 'E123');
    });

    test('codigo ausente => guion largo', () {
      expect(SolarFormat.faultCode(null), '—');
    });
  });

  group('SolarFormat — ausentes y valores invalidos', () {
    test('null => guion largo en TODAS las unidades, nunca 0', () {
      expect(SolarFormat.kilowatts(null), '—');
      expect(SolarFormat.kilowatthours(null), '—');
      expect(SolarFormat.kilovoltAmperes(null), '—');
      expect(SolarFormat.volts(null), '—');
      expect(SolarFormat.acVolts(null), '—');
      expect(SolarFormat.amperes(null), '—');
      expect(SolarFormat.hertz(null), '—');
      expect(SolarFormat.percent(null), '—');
      expect(SolarFormat.milliseconds(null), '—');
      expect(SolarFormat.faultCode(null), '—');
      expect(SolarFormat.emDash, '—');
    });

    test('NaN e infinito => guion largo, sin excepcion', () {
      expect(SolarFormat.kilowatts(double.nan), '—');
      expect(SolarFormat.kilowatts(double.infinity), '—');
      expect(SolarFormat.kilowatts(-double.infinity), '—');
      expect(SolarFormat.volts(double.nan), '—');
      expect(SolarFormat.percent(double.nan), '—');
      expect(SolarFormat.milliseconds(double.nan), '—');
    });

    test('el guion largo es exactamente un em dash (U+2014)', () {
      expect(SolarFormat.kilowatts(null).codeUnits, [0x2014]);
      expect('—'.codeUnits, [0x2014]);
    });
  });
}
