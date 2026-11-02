// lib/presentation/widget/auth/auth_page.dart

import 'package:flutter/material.dart';

/// Layout común de pantallas de auth (login y registro).
///
/// Garantiza que todas las pantallas de autenticación compartan el mismo
/// tema, colores, icono, espaciado y ancho máximo (spec §1 "auth screens
/// share the same theme").
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.footer,
    required this.children,
  });

  /// Icono mostrado arriba del título.
  final IconData icon;

  /// Título principal de la pantalla.
  final String title;

  /// Subtítulo descriptivo.
  final String subtitle;

  /// Texto opcional mostrado al final (ej. modo demo).
  final Widget? footer;

  /// Campos del formulario, botón y textos de error.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  icon,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                ...children,
                if (footer != null) ...[
                  const SizedBox(height: 16),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
