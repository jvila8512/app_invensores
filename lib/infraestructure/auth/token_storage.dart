// lib/infraestructure/auth/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistencia del JWT (spec §1).
///
/// La app arranca sin sesión y debe restaurarla desde el almacenamiento
/// seguro; el backend no ofrece refresh token (TTL de 24 h), por lo que un
/// token perdido o vencido obliga a volver a [login].
abstract class TokenStorage {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> delete();
}

/// Almacenamiento en memoria para tests y para la demo offline.
class InMemoryTokenStorage implements TokenStorage {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String token) async => _value = token;

  @override
  Future<void> delete() async => _value = null;
}

/// Almacenamiento real sobre el Keychain de iOS / Keystore de Android
/// (requiere minSdk 23 y el entitlemente de Keychain: WU2).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'etecsa_access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      // Sin Keychain (o permisos denegados): tratamos la sesión como ausente.
      return null;
    }
  }

  @override
  Future<void> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (_) {
      // Preferimos seguir en memoria (via [TokenHolder]) antes que romper el
      // login por un fallo del almacenamiento seguro.
    }
  }

  @override
  Future<void> delete() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      // Idem: el holder en memoria ya quedó limpio.
    }
  }
}
