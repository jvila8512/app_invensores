// lib/presentation/provider/data_source_overrides_provider.dart

import 'package:dio/dio.dart';
import 'package:etecsa_supervision/config/constants/environment.dart';
import 'package:etecsa_supervision/domain/repository/auth_repository.dart';
import 'package:etecsa_supervision/domain/repository/inverter_repository.dart';
import 'package:etecsa_supervision/infraestructure/auth/auth_interceptor.dart';
import 'package:etecsa_supervision/infraestructure/auth/auth_providers.dart';
import 'package:etecsa_supervision/infraestructure/datasource/auth_fake_datasource.dart';
import 'package:etecsa_supervision/infraestructure/datasource/auth_remote_datasource.dart';
import 'package:etecsa_supervision/infraestructure/datasource/inverter_fake_datasource.dart';
import 'package:etecsa_supervision/infraestructure/datasource/inverter_remote_datasource.dart';
import 'package:etecsa_supervision/infraestructure/repositories/auth_repository_impl.dart';
import 'package:etecsa_supervision/infraestructure/repositories/inverter_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

export 'package:etecsa_supervision/infraestructure/auth/auth_providers.dart';

/// Repositorios de datos (design D3). Por defecto hablan con el backend.
///
/// Cada `Dio` comparte el interceptor de `Authorization`: adjunta el JWT a
/// las peticiones y, ante un 401, limpia la sesión y avisa a los suscriptores
/// de [unauthorizedSignalProvider] (spec §1).
final inverterRepositoryProvider = Provider<InverterRepository>((ref) {
  return InverterRepositoryImpl(
    InverterRemoteDatasource(ref.watch(_dioProvider)),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDatasource(ref.watch(_dioProvider)));
});

final _dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiBaseUrl));
  dio.interceptors.add(
    AuthInterceptor(
      holder: ref.watch(tokenHolderProvider),
      storage: ref.watch(tokenStorageProvider),
      onUnauthorized: ref.watch(unauthorizedSignalProvider).notify,
    ),
  );
  return dio;
});

/// Overrides de `ProviderScope` para la demo offline (spec §5 "Offline
/// demo"): con `USE_FAKE_DATA=true` el grafo entero usa las datasources
/// sembradas y no hace ninguna peticion.
List<Override> dataSourceOverrides() {
  if (!Environment.useFakeData) return const [];
  return <Override>[
    inverterRepositoryProvider.overrideWithValue(
      InverterRepositoryImpl(FakeInverterDatasource()),
    ),
    authRepositoryProvider.overrideWithValue(
      AuthRepositoryImpl(FakeAuthDatasource()),
    ),
  ];
}
