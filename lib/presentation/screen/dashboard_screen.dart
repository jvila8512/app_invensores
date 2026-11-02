// lib/presentation/screen/dashboard_screen.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/policy/site_grouping.dart';
import 'package:etecsa_supervision/presentation/provider/auth_session_provider.dart';
import 'package:etecsa_supervision/presentation/provider/catalog_provider.dart';
import 'package:etecsa_supervision/presentation/provider/selected_site_provider.dart';
import 'package:etecsa_supervision/presentation/widget/dashboard/fleet_kpis.dart';
import 'package:etecsa_supervision/presentation/widget/dashboard/inverter_card.dart';
import 'package:etecsa_supervision/presentation/widget/dashboard/site_filter_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard: lista plana de TODOS los inversores agrupados visualmente por
/// sitio, con filtro pegajoso (spec §2, §3).
///
/// El grupo `SiteGrouping` es solo visual: la lista sigue siendo plana y
/// perezosa (`SliverFixedExtentList`), de modo que 300 inversores no
/// construyen 300 tarjetas a la vez.
class DashboardScreen extends ConsumerWidget {
  static const String name = 'dashboard-screen';
  static const String path = '/';

  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(inverterCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inversores'),
        actions: [
          IconButton(
            key: const Key('dashboard-logout'),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authSessionProvider.notifier).logout(),
          ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _CatalogError(
          onRetry: () => ref.invalidate(inverterCatalogProvider),
        ),
        data: (inverters) => _DashboardBody(inverters: inverters),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.inverters});

  final List<Inversor> inverters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSite = ref.watch(selectedSiteProvider);
    final sites = SiteGrouping.siteNames(inverters);
    final filtered = SiteGrouping.filterBySite(inverters, selectedSite);
    final grouped = SiteGrouping.groupBySite(filtered);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: FleetKpis()),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyFilterHeader(sites: sites),
        ),
        if (grouped.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No hay inversores en este sitio')),
          )
        else
          for (final entry in grouped.entries)
            SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: _SiteHeader(name: entry.key, count: entry.value.length),
                ),
                SliverFixedExtentList(
                  itemExtent: 168,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        InverterCard(inversor: entry.value[index]),
                    childCount: entry.value.length,
                  ),
                ),
              ],
            ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

/// Encabezado de cada grupo de sitio (solo visual).
class _SiteHeader extends StatelessWidget {
  const _SiteHeader({required this.name, required this.count});

  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count inversores',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mantiene el filtro de sitios fijo arriba mientras se hace scroll.
class _StickyFilterHeader extends SliverPersistentHeaderDelegate {
  _StickyFilterHeader({required this.sites});

  final List<String> sites;

  static const double _height = 56;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SiteFilterBar(sites: sites),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterHeader oldDelegate) =>
      !listEquals(oldDelegate.sites, sites);
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No se pudo cargar el catálogo de inversores.'),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('dashboard-retry'),
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
