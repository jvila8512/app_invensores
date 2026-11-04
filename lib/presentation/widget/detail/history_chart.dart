// lib/presentation/widget/detail/history_chart.dart

import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Grafico de potencia PV en el tiempo, con filas REALES del backend
/// (spec §4: nunca datos fabricados, ningun `Random()`).
///
/// Descarta las filas sin `tiempo` o sin `pvPotenciaW`; si no queda ninguna,
/// muestra "Sin historial" en vez de un eje vacio.
class HistoryChart extends StatelessWidget {
  const HistoryChart({super.key, required this.rows});

  final List<LecturaInversor> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = rows
        .where((row) => row.tiempo != null && row.pvPotenciaW != null)
        .toList()
      ..sort((a, b) => a.tiempo!.compareTo(b.tiempo!));

    if (points.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Sin historial',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].pvPotenciaW! / 1000),
    ];
    final maxY = spots.fold<double>(0, (m, s) => s.y > m ? s.y : m);

    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY <= 0 ? 1 : maxY * 1.2,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toStringAsFixed(1)} kW',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                dotData: const FlDotData(show: false),
                barWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
