// test/presentation/auth_redirect_test.dart

import 'package:etecsa_supervision/config/router/app_router.dart';
import 'package:etecsa_supervision/presentation/screen/screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const login = LoginScreen.path;
  const home = PlaceholderScreen.path;

  group('authRedirect', () {
    test('durante la restauración no redirige nada', () {
      expect(
        authRedirect(isRestoring: true, isAuthenticated: false, location: home),
        isNull,
      );
      expect(
        authRedirect(isRestoring: true, isAuthenticated: true, location: login),
        isNull,
      );
    });

    test('sin sesión, cualquier ruta distinta del login cae al login', () {
      expect(
        authRedirect(isRestoring: false, isAuthenticated: false, location: home),
        login,
      );
      expect(
        authRedirect(
          isRestoring: false,
          isAuthenticated: false,
          location: '/inversor/7',
        ),
        login,
      );
    });

    test('sin sesión, el login permanece en el login', () {
      expect(
        authRedirect(
          isRestoring: false,
          isAuthenticated: false,
          location: login,
        ),
        isNull,
      );
    });

    test('con sesión, el login redirige al inicio', () {
      expect(
        authRedirect(isRestoring: false, isAuthenticated: true, location: login),
        home,
      );
    });

    test('con sesión, el inicio no redirige', () {
      expect(
        authRedirect(isRestoring: false, isAuthenticated: true, location: home),
        isNull,
      );
    });
  });
}
