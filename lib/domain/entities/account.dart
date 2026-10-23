// lib/domain/entities/account.dart

/// Cuenta resuelta desde `GET /api/account` (spec §1).
class Account {
  const Account({
    this.id,
    this.login,
    this.activated,
    this.authorities,
  });

  final int? id;

  /// Login visible en la app bar.
  final String? login;
  final bool? activated;

  /// `ROLE_ADMIN` | `ROLE_USER` (el backend no define roles por entidad).
  final List<String>? authorities;

  /// `true` si la cuenta tiene el rol indicado.
  bool hasRole(String role) => authorities?.contains(role) ?? false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.login == login &&
        other.activated == activated &&
        _listEquals(other.authorities, authorities);
  }

  @override
  int get hashCode => Object.hash(
        id,
        login,
        activated,
        authorities == null ? null : Object.hashAll(authorities!),
      );

  @override
  String toString() => 'Account(id: $id, login: $login)';

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
