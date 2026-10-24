// lib/domain/repository/auth_repository.dart

import 'package:etecsa_supervision/domain/entities/account.dart';

/// Puerto de autenticacion para la capa de presentacion (design D3).
abstract class AuthRepository {
  Future<String> authenticate({
    required String username,
    required String password,
    bool rememberMe = false,
  });

  Future<Account> fetchAccount();
}
