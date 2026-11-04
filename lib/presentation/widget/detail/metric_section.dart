// lib/presentation/widget/detail/metric_section.dart

import 'package:flutter/material.dart';

/// Una fila etiqueta/valor dentro de una seccion de metricas.
class MetricEntry {
  const MetricEntry(this.label, this.value);

  final String label;
  final String value;
}

/// Seccion de metricas del detalle (spec §4).
///
/// Cada seccion agrupa las lecturas reales del DTO; los valores ausentes ya
/// llegan formateados con `—` desde `SolarFormat`.
class MetricSection extends StatelessWidget {
  const MetricSection({
    super.key,
    required this.title,
    required this.icon,
    required this.metrics,
  });

  final String title;
  final IconData icon;
  final List<MetricEntry> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final metric in metrics)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        metric.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(metric.value, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
