// lib/presentation/screen/login_screen.dart

import 'package:etecsa_supervision/config/constants/environment.dart';
import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/presentation/provider/auth_session_provider.dart';
import 'package:etecsa_supervision/presentation/screen/register_screen.dart';
import 'package:etecsa_supervision/presentation/widget/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de acceso (spec §1 `auth-session`).
///
/// El éxito no navega a mano: al cambiar la sesión el router redirige a la
/// ruta inicial. El error del backend se muestra bajo el formulario.
class LoginScreen extends ConsumerStatefulWidget {
  static const String name = 'login-screen';
  static const String path = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authSessionProvider.notifier)
          .login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );
      // La sesión cambió: el router redirige al inicio. No navegamos a mano
      // para que este widget pueda desmontarse sin un context pendiente.
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo iniciar sesión. Revisa la conexión.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthPage(
      icon: Icons.solar_power_outlined,
      title: 'ETECSA Supervisión',
      subtitle: 'Monitoreo de inversores en vivo',
      footer: Environment.useFakeData
          ? Text(
              'Modo demo: cualquier usuario y contraseña no vacíos '
              'abren la sesión sin backend.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            )
          : null,
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                enabled: !_loading,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Ingresá el usuario'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                enabled: !_loading,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty)
                        ? 'Ingresá la contraseña'
                        : null,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _rememberMe,
                onChanged: _loading
                    ? null
                    : (value) =>
                          setState(() => _rememberMe = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Mantener sesión iniciada'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  key: const Key('login-error'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('login-submit'),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ingresar'),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('login-go-register'),
                onPressed: _loading
                    ? null
                    : () => context.go(RegisterScreen.path),
                child: const Text('¿No tenés cuenta? Registrate'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
