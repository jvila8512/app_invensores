// lib/presentation/widget/dashboard/soc_ring.dart

import 'package:etecsa_supervision/config/helper/solar_format.dart';
import 'package:flutter/material.dart';

/// Anillo de estado de carga (SOC) de la bateria (spec §2, §3).
///
/// Sin `socPct` pinta `—` en el centro, nunca `0%` (telemetria ausente).
class SocRing extends StatelessWidget {
  const SocRing({super.key, required this.socPct, this.size = 52});

  /// Estado de carga [% 0-100]; `null` = sin dato.
  final int? socPct;

  /// Diametro del anillo.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = socPct;
    final label = value == null ? SolarFormat.emDash : '${value.clamp(0, 100)}%';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (value == null)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 4,
                ),
              ),
            )
          else
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: (value.clamp(0, 100)) / 100,
                strokeWidth: 4,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
