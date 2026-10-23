import 'package:etecsa_supervision/domain/policy/modo_operacion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModoOperacion — Felicity (T-6)', () {
    test('mapea los valores conocidos', () {
      expect(
        ModoOperacion.display('SIN_RED', marcaNombre: 'Felicity'),
        'SIN RED',
      );
      expect(ModoOperacion.display('RED', marcaNombre: 'Felicity'), 'RED');
      expect(ModoOperacion.display('SOLAR', marcaNombre: 'Felicity'), 'SOLAR');
      expect(
        ModoOperacion.display('HIBRIDO', marcaNombre: 'Felicity'),
        'HIBRIDO',
      );
      expect(
        ModoOperacion.display('BATERIA', marcaNombre: 'Felicity'),
        'BATERIA',
      );
    });

    test('DESCONOCIDO_n se muestra crudo, sin lanzar', () {
      expect(
        ModoOperacion.display('DESCONOCIDO_3', marcaNombre: 'Felicity'),
        'DESCONOCIDO_3',
      );
      expect(ModoOperacion.display('DESCONOCIDO_0'), 'DESCONOCIDO_0');
    });

    test('un valor de otra marca no se pretende mapear', () {
      expect(
        ModoOperacion.display('GRID_TIE', marcaNombre: 'Felicity'),
        'GRID_TIE',
      );
    });
  });

  group('ModoOperacion — MUST (T-6)', () {
    test('mapea los valores conocidos', () {
      expect(ModoOperacion.display('GRID_TIE', marcaNombre: 'MUST'), 'GRID TIE');
      expect(
        ModoOperacion.display('OFF_GRID', marcaNombre: 'MUST'),
        'OFF GRID',
      );
      expect(
        ModoOperacion.display('POWER_ON', marcaNombre: 'MUST'),
        'POWER ON',
      );
      expect(
        ModoOperacion.display('SELF_TEST', marcaNombre: 'MUST'),
        'SELF TEST',
      );
      expect(ModoOperacion.display('BYPASS', marcaNombre: 'MUST'), 'BYPASS');
      expect(
        ModoOperacion.display('CHARGING', marcaNombre: 'MUST'),
        'CHARGING',
      );
      expect(ModoOperacion.display('FAULT', marcaNombre: 'MUST'), 'FAULT');
    });

    test('la marca se compara sin distinguir mayusculas', () {
      expect(ModoOperacion.display('GRID_TIE', marcaNombre: 'must'), 'GRID TIE');
      expect(
        ModoOperacion.display('GRID_TIE', marcaNombre: 'MUST S.R.L.'),
        'GRID TIE',
      );
    });
  });

  group('ModoOperacion — casos borde', () {
    test('sin marca se prueban ambos catalogos', () {
      expect(ModoOperacion.display('GRID_TIE'), 'GRID TIE');
      expect(ModoOperacion.display('SIN_RED'), 'SIN RED');
      expect(ModoOperacion.display('DESCONOCIDO_3'), 'DESCONOCIDO_3');
    });

    test('marca desconocida con valor de catalogo se mapea', () {
      expect(
        ModoOperacion.display('GRID_TIE', marcaNombre: 'Sunta'),
        'GRID TIE',
      );
    });

    test('nulo o vacio => guion largo', () {
      expect(ModoOperacion.display(null), '—');
      expect(ModoOperacion.display(''), '—');
      expect(ModoOperacion.ausente, '—');
    });

    test('valor basura se muestra tal cual, sin excepcion', () {
      expect(ModoOperacion.display('WAT', marcaNombre: 'Felicity'), 'WAT');
      expect(ModoOperacion.display('wat'), 'wat');
    });
  });
}
