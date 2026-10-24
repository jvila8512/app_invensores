// lib/infraestructure/datasource/inverter_remote_datasource.dart

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:etecsa_supervision/domain/datasources/inverter_datasource.dart';
import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/infraestructure/mapper/inversor_mapper.dart';
import 'package:etecsa_supervision/infraestructure/mapper/lectura_inversor_mapper.dart';
import 'package:etecsa_supervision/infraestructure/polling/periodic_poller.dart';

/// Implementacion real del contrato de datos contra el backend (design D3).
///
/// Solo transforma JSON => entidades; la autenticacion (interceptor de
/// `Authorization`) la conecta la capa de infraestructura de auth (WU5).
class InverterRemoteDatasource implements InverterDatasource {
  InverterRemoteDatasource(
    this._dio, {
    this.livePollInterval = const Duration(seconds: 5),
  });

  final Dio _dio;

  /// Cadencia del fallback REST de [watchLive] (design D1).
  final Duration livePollInterval;

  @override
  Future<List<Inversor>> fetchAll() async {
    final response = await _dio.get<List<dynamic>>('/api/inversores/all');
    return [
      for (final json in _jsonList(response)) InversorMapper.fromJson(json),
    ];
  }

  @override
  Future<List<LecturaInversor>> fetchLatestReadings() async {
    final response = await _dio.get<List<dynamic>>(
      '/api/dato-inversors/latest-readings',
    );
    return [
      for (final json in _jsonList(response))
        LecturaInversorMapper.fromJson(json),
    ];
  }

  @override
  Future<List<LecturaInversor>> fetchHistory(
    int inversorId, {
    int size = 200,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/api/dato-inversors',
      queryParameters: <String, dynamic>{
        'inversorId.equals': inversorId,
        'sort': 'tiempo,desc',
        'size': size,
      },
    );
    return [
      for (final json in _jsonList(response))
        LecturaInversorMapper.fromJson(json),
    ];
  }

  /// Fallback REST del detalle (design D1): sondea la ultima fila del
  /// historial cada [livePollInterval]. WU6 sustituye este camino por STOMP
  /// cuando el probe de transporte lo valide.
  @override
  Stream<LecturaInversor> watchLive(int inversorId) {
    final controller = StreamController<LecturaInversor>();
    late final PeriodicPoller poller;

    Future<void> tick() async {
      final rows = await fetchHistory(inversorId, size: 1);
      if (rows.isNotEmpty && !controller.isClosed) {
        controller.add(rows.first);
      }
    }

    poller = PeriodicPoller(
      interval: livePollInterval,
      onTick: tick,
      onError: (error, stackTrace) {
        if (!controller.isClosed) controller.addError(error, stackTrace);
      },
    );

    controller.onListen = poller.start;
    controller.onCancel = poller.dispose;
    return controller.stream;
  }

  List<Map<String, dynamic>> _jsonList(Response<List<dynamic>> response) {
    final data = response.data;
    if (data == null) return const [];
    return [
      for (final item in data)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }
}
