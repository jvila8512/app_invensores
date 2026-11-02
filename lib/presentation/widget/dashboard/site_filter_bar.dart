// lib/presentation/widget/dashboard/site_filter_bar.dart

import 'package:etecsa_supervision/domain/policy/site_grouping.dart';
import 'package:etecsa_supervision/presentation/provider/selected_site_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filtro pegajoso por sitio (spec §2).
///
/// Primer chip siempre [SiteGrouping.todosLabel] (seleccion `null`, el
/// default); luego un chip por sitio presente en el catalogo, en orden
/// alfabetico.
class SiteFilterBar extends ConsumerWidget {
  const SiteFilterBar({super.key, required this.sites});

  /// Nombres de sitio ordenados.
  final List<String> sites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedSiteProvider);

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _chip(
            ref,
            label: SiteGrouping.todosLabel,
            value: null,
            selected: selected == null,
          ),
          for (final site in sites)
            _chip(
              ref,
              label: site,
              value: site,
              selected: selected == site,
            ),
        ],
      ),
    );
  }

  Widget _chip(
    WidgetRef ref, {
    required String label,
    required String? value,
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        key: Key('site-chip-$label'),
        label: Text(label),
        selected: selected,
        onSelected: (_) =>
            ref.read(selectedSiteProvider.notifier).select(value),
      ),
    );
  }
}
