// lib/presentation/widget/detail/live_banner.dart

import 'package:etecsa_supervision/presentation/provider/live_provider.dart';
import 'package:flutter/material.dart';

/// Banner del canal en vivo del detalle (spec §3).
///
/// `CONECTADO` (verde), `RECONECTANDO` (ambar) o `SONDEO` (neutro).
class LiveBanner extends StatelessWidget {
  const LiveBanner({super.key, required this.status});

  final LiveStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground, icon) = switch (status) {
      LiveStatus.connected => (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          Icons.wifi,
        ),
      LiveStatus.reconnecting => (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
          Icons.wifi_off,
        ),
      LiveStatus.polling => (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
          Icons.sync,
        ),
    };

    return Container(
      key: const Key('live-banner'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
