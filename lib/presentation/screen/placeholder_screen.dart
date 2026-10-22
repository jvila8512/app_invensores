import 'package:flutter/material.dart';

/// Pantalla placeholder mientras se construyen el login y el dashboard.
///
/// Se reemplaza por las pantallas reales en las fases de auth (WU5) y
/// dashboard (WU7).
class PlaceholderScreen extends StatelessWidget {
  static const String name = 'placeholder-screen';

  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.solar_power_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'ETECSA Supervisión',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Módulo de supervisión de inversores en vivo'),
          ],
        ),
      ),
    );
  }
}
