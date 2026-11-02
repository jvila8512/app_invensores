// lib/presentation/widget/dashboard/fleet_kpis.dart

import 'package:etecsa_supervision/config/helper/solar_format.dart';
import 'package:etecsa_supervision/presentation/provider/kpis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tarjetas KPI de la flota (spec §2): PV total, en linea, en alarma y
/// eficiencia media. Se actualizan solas con cada sondeo.
class FleetKpis extends ConsumerWidget {
  const FleetKpis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(fleetKpisProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _KpiTile(
            key: const Key('kpi-pv'),
            label: 'Potencia PV',
            value: SolarFormat.kilowatts(kpis.totalPvW, decimals: 1),
          ),
          _KpiTile(
            key: const Key('kpi-online'),
            label: 'En linea',
            value: '${kpis.online}/${kpis.total}',
          ),
          _KpiTile(
            key: const Key('kpi-alarm'),
            label: 'En alarma',
            value: '${kpis.inAlarm}',
          ),
          _KpiTile(
            key: const Key('kpi-efficiency'),
            label: 'Eficiencia media',
            value: SolarFormat.percent(kpis.avgEfficiencyPct),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 156,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
