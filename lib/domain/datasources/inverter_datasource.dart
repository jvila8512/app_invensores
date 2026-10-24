// lib/domain/datasources/inverter_datasource.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';

/// Contrato de acceso a datos del catalogo y la telemetria (design D3
/// "Interfaces / Contracts").
///
/// La implementacion real (`InverterRemoteDatasource`) habla con el backend;
/// la fake sirve la demo sin red. Ambas devuelven entidades de dominio:
/// ningun DTO cruza esta frontera.
abstract class InverterDatasource {
  /// `GET /api/inversores/all` (sin paginar).
  Future<List<Inversor>> fetchAll();

  /// `GET /api/dato-inversors/latest-readings`: una lectura por inversor.
  Future<List<LecturaInversor>> fetchLatestReadings();

  /// `GET /api/dato-inversors?inversorId.equals=N&sort=tiempo,desc&size=N`.
  Future<List<LecturaInversor>> fetchHistory(int inversorId, {int size = 200});

  /// Lectura en vivo del inversor. La implementacion real usa el transporte
  /// configurado (STOMP o el fallback REST); la fake emite valores sembrados.
  Stream<LecturaInversor> watchLive(int inversorId);
}
