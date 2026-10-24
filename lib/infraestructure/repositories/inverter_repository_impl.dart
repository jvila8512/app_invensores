// lib/infraestructure/repositories/inverter_repository_impl.dart

import 'package:etecsa_supervision/domain/datasources/inverter_datasource.dart';
import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/domain/repository/inverter_repository.dart';

/// Implementacion del puerto que delega en el datasource configurado
/// (real o fake, design D3).
class InverterRepositoryImpl implements InverterRepository {
  const InverterRepositoryImpl(this._datasource);

  final InverterDatasource _datasource;

  @override
  Future<List<Inversor>> fetchAll() => _datasource.fetchAll();

  @override
  Future<List<LecturaInversor>> fetchLatestReadings() =>
      _datasource.fetchLatestReadings();

  @override
  Future<List<LecturaInversor>> fetchHistory(
    int inversorId, {
    int size = 200,
  }) => _datasource.fetchHistory(inversorId, size: size);

  @override
  Stream<LecturaInversor> watchLive(int inversorId) =>
      _datasource.watchLive(inversorId);
}
