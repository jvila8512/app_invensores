import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/policy/site_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  final fleet = buildFleet();

  group('SiteGrouping.groupBySite (spec §2)', () {
    test('agrupa 300 inversores en 5 sitios con claves ordenadas', () {
      final groups = SiteGrouping.groupBySite(fleet);

      expect(groups.length, 5);
      expect(groups.keys, [
        'Planta Central',
        'Planta Este',
        'Planta Norte',
        'Planta Oeste',
        'Planta Sur',
      ]);
      for (final members in groups.values) {
        expect(members.length, 60);
      }
      final flat = groups.values.expand((m) => m).toList();
      expect(flat.length, 300);
      expect({for (final i in flat) i.id}.length, 300);
    });

    test('cada grupo esta ordenado por nombre de inversor', () {
      final groups = SiteGrouping.groupBySite(fleet);
      for (final members in groups.values) {
        final names = [for (final i in members) i.nombre!];
        final expected = [...names]..sort();
        expect(names, expected);
      }
    });

    test('el orden de entrada no afecta el resultado', () {
      final groups = SiteGrouping.groupBySite([
        buildInversor(id: 3, nombre: 'INV-003'),
        buildInversor(id: 1, nombre: 'INV-001'),
      ]);
      expect(
        [for (final i in groups.values.first) i.nombre],
        ['INV-001', 'INV-003'],
      );
    });

    test('empates de nombre se rompen por id', () {
      final groups = SiteGrouping.groupBySite([
        buildInversor(id: 9, nombre: 'DUP'),
        buildInversor(id: 2, nombre: 'DUP'),
      ]);
      expect(
        [for (final i in groups.values.first) i.id],
        [2, 9],
      );
    });

    test('un inversor sin sitio agrupa bajo el guion largo', () {
      final groups = SiteGrouping.groupBySite([
        const Inversor(id: 1, nombre: 'Huerfano'),
      ]);
      expect(groups.keys, ['—']);
      expect(SiteGrouping.sinSitioLabel, '—');
    });
  });

  group('SiteGrouping.filterBySite (spec §2)', () {
    test('la etiqueta por defecto es Todos', () {
      expect(SiteGrouping.todosLabel, 'Todos');
    });

    test('seleccion null (= Todos) devuelve todos los inversores', () {
      expect(SiteGrouping.filterBySite(fleet, null).length, 300);
    });

    test('filtra solo el sitio seleccionado', () {
      final filtered = SiteGrouping.filterBySite(fleet, 'Planta Norte');
      expect(filtered.length, 60);
      expect(
        filtered.every((i) => i.sitio?.nombre == 'Planta Norte'),
        isTrue,
      );
    });

    test('sitio sin inversores => lista vacia', () {
      expect(SiteGrouping.filterBySite(fleet, 'Planta Inexistente'), isEmpty);
    });

    test('siteNames devuelve los sitios ordenados', () {
      expect(SiteGrouping.siteNames(fleet), [
        'Planta Central',
        'Planta Este',
        'Planta Norte',
        'Planta Oeste',
        'Planta Sur',
      ]);
    });
  });
}
