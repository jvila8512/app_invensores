// lib/infraestructure/auth/auth_providers.dart

import 'package:etecsa_supervision/infraestructure/auth/token_holder.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_storage.dart';
import 'package:etecsa_supervision/infraestructure/auth/unauthorized_signal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// JWT en memoria que el interceptor adjunta a cada peticion.
final tokenHolderProvider = Provider<TokenHolder>((ref) => TokenHolder());

/// Persistencia segura del JWT (Keychain / Keystore).
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

/// Senal de sesion expirada que emite el interceptor ante un 401.
final unauthorizedSignalProvider = Provider<UnauthorizedSignal>(
  (ref) => UnauthorizedSignal(),
);
