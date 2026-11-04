// lib/presentation/provider/data_source_overrides_provider.dart

import 'dart:async';

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
import 'package:etecsa_supervision/infraestructure/telemetry/live_telemetry_client.dart';
import 'package:etecsa_supervision/presentation/provider/auth_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

export 'package:etecsa_supervision/infraestructure/auth/auth_providers.dart';

/// Cliente STOMP de telemetría (WU6).
///
/// `null` en modo demo (sin red) y mientras no haya JWT. Se reconstruye al
/// cambiar la sesión: al iniciar sesión se crea con el token nuevo y se
/// conecta; al cerrarla se destruye.
final liveTelemetryClientProvider = Provider<LiveTelemetryClient?>((ref) {
  if (Environment.useFakeData) return null;
  final token = ref.watch(
    authSessionProvider.select((session) => session.value?.token),
  );
  if (token == null || token.isEmpty) return null;

  final client = LiveTelemetryClient(
    accessToken: token,
    webSocketUrl: Environment.wsBaseUrl,
  );
  ref.onDispose(client.dispose);
  unawaited(client.connect());
  return client;
});

/// Repositorios de datos (design D3). Por defecto hablan con el backend.
///
/// Cada `Dio` comparte el interceptor de `Authorization`: adjunta el JWT a
/// las peticiones y, ante un 401, limpia la sesión y avisa a los suscriptores
/// de [unauthorizedSignalProvider] (spec §1).
final inverterRepositoryProvider = Provider<InverterRepository>((ref) {
  final datasource = InverterRemoteDatasource(ref.watch(_dioProvider));
  final client = ref.watch(liveTelemetryClientProvider);
  if (client != null) datasource.setTelemetryClient(client);
  return InverterRepositoryImpl(datasource);
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
