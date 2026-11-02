// lib/config/router/app_router.dart

import 'package:etecsa_supervision/presentation/provider/auth_session_provider.dart';
import 'package:etecsa_supervision/presentation/screen/screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Reglas de redireccion por sesión (spec §1).
///
/// Esta funcion es pura a proposito: las rutas de auth se prueban sin
/// construir [GoRouter] ni un contexto de widget.
///
/// - Mientras la sesión restaura el token guardado no se redirige nada.
/// - Sin sesión sólo se permiten login y registro; cualquier otra ruta cae al login.
/// - Con sesión, el login o el registro redirigen al inicio (el dashboard de WU7).
String? authRedirect({
  required bool isRestoring,
  required bool isAuthenticated,
  required String location,
}) {
  if (isRestoring) return null;

  final onAuth = location == LoginScreen.path || location == RegisterScreen.path;
  if (!isAuthenticated && !onAuth) return LoginScreen.path;
  if (isAuthenticated && onAuth) return PlaceholderScreen.path;
  return null;
}

/// Router de la app: se reconstruye cuando cambia la sesión, de modo que
/// [GoRouter.redirect] corra con el estado actualizado.
final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authSessionProvider);

  return GoRouter(
    initialLocation: PlaceholderScreen.path,
    routes: [
      GoRoute(
        path: PlaceholderScreen.path,
        name: PlaceholderScreen.name,
        builder: (context, state) => const PlaceholderScreen(),
      ),
      GoRoute(
        path: LoginScreen.path,
        name: LoginScreen.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.path,
        name: RegisterScreen.name,
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
    redirect: (context, state) => authRedirect(
      isRestoring:
          session.isLoading ||
          (session.hasValue && session.value!.isRestoring),
      isAuthenticated: session.hasValue && session.value!.isAuthenticated,
      location: state.matchedLocation,
    ),
  );
});
