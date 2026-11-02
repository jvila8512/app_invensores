// lib/presentation/widget/dashboard/inverter_card.dart

import 'package:etecsa_supervision/config/helper/solar_format.dart';
import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/policy/staleness_policy.dart';
import 'package:etecsa_supervision/presentation/provider/kpis_provider.dart';
import 'package:etecsa_supervision/presentation/provider/latest_readings_provider.dart';
import 'package:etecsa_supervision/presentation/widget/dashboard/soc_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tarjeta de un inversor en el dashboard (spec Â§2, Â§3).
///
/// Escucha SOLO su propia lectura con `select`: un sondeo que cambia una
/// unidad no reconstruye las otras ~299 tarjetas (depende de la igualdad de
/// valores de `LecturaInversor`).
///
/// - Valores ausentes => `â€”`, nunca `0`.
/// - OFFLINE cuando la lectura falta o supera el umbral de frescura; jamas
///   NORMAL para una unidad sin datos.
/// - `SLAVE n` para esclavos, `MASTER` para el maestro.
class InverterCard extends ConsumerWidget {
  const InverterCard({super.key, required this.inversor});

  final Inversor inversor;

  static const StalenessPolicy _policy = StalenessPolicy();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reading = ref.watch(
      latestReadingsProvider.select(
        (async) => async.value?[inversor.id],
      ),
    );
    final now = ref.watch(kpisClockProvider)();

    final stale = reading == null ||
        _policy.readingIsStale(
          now: now,
          lectura: reading,
          gateway: inversor.gateway,
        );
    final lastSeen = reading?.tiempo == null
        ? null
        : StalenessPolicy.lastSeen(now.difference(reading!.tiempo!));

    final marca = inversor.marca?.nombre ?? SolarFormat.emDash;
    final modelo = inversor.modelo?.nombre ?? SolarFormat.emDash;
    final gateway = inversor.gateway?.nombre ?? SolarFormat.emDash;
    final sitio = inversor.sitio?.nombre ?? SolarFormat.emDash;

    return Card(
      key: Key('inverter-card-${inversor.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          inversor.nombre ?? SolarFormat.emDash,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      _SlaveTag(inversor: inversor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$marca Â· $modelo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '$gateway Â· $sitio',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Metric(
                        label: 'PV',
                        value: SolarFormat.kilowatts(reading?.pvPotenciaW),
                      ),
                      const SizedBox(width: 16),
                      _Metric(
                        label: 'Efic.',
                        value: SolarFormat.percent(reading?.eficienciaPct),
                      ),
                      if (reading?.enAlarma ?? false) ...[
                        const SizedBox(width: 12),
                        _FaultChip(
                          code: SolarFormat.faultCode(reading!.codigoFallo),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: stale
                            ? theme.colorScheme.outline
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stale ? 'OFFLINE' : 'ONLINE',
                        key: Key('inverter-status-${inversor.id}'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: stale
                              ? theme.colorScheme.outline
                              : theme.colorScheme.primary,
                        ),
                      ),
                      if (lastSeen != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          'hace $lastSeen',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SocRing(socPct: reading?.socPct),
          ],
        ),
      ),
    );
  }
}

/// `MASTER` o `SLAVE n` segun el rol del inversor (spec Â§2).
class _SlaveTag extends StatelessWidget {
  const _SlaveTag({required this.inversor});

  final Inversor inversor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String label;
    if (inversor.esMaster == true) {
      label = 'MASTER';
    } else if (inversor.slaveId != null) {
      label = 'SLAVE ${inversor.slaveId}';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _FaultChip extends StatelessWidget {
  const _FaultChip({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('inverter-fault'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        code,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
