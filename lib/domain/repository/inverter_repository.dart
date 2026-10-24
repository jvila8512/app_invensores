// lib/domain/repository/inverter_repository.dart

import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';

/// Puerto que consume la capa de presentacion para el catalogo y la
/// telemetria de inversores (design D3).
///
/// Las implementaciones real y fake cumplen este mismo contrato, de modo
/// que `USE_FAKE_DATA=true` solo cambia el `Provider` que lo resuelve.
abstract class InverterRepository {
  Future<List<Inversor>> fetchAll();

  Future<List<LecturaInversor>> fetchLatestReadings();

  Future<List<LecturaInversor>> fetchHistory(int inversorId, {int size = 200});

  Stream<LecturaInversor> watchLive(int inversorId);
}
