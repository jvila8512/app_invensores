// lib/infraestructure/repositories/auth_repository_impl.dart

import 'package:etecsa_supervision/domain/datasources/auth_datasource.dart';
import 'package:etecsa_supervision/domain/entities/account.dart';
import 'package:etecsa_supervision/domain/repository/auth_repository.dart';

/// Implementacion del puerto de auth que delega en el datasource
/// configurado (real o fake, design D3).
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);

  final AuthDatasource _datasource;

  @override
  Future<String> authenticate({
    required String username,
    required String password,
    bool rememberMe = false,
  }) => _datasource.authenticate(
    username: username,
    password: password,
    rememberMe: rememberMe,
  );

  @override
  Future<Account> fetchAccount() => _datasource.fetchAccount();
}
