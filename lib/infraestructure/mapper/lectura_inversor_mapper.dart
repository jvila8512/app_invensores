// lib/infraestructure/mapper/lectura_inversor_mapper.dart

import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/infraestructure/model/dato_inversor_dto.dart';

/// Mapeo `DatoInversorDTO` => `LecturaInversor` (design D4: mappers a
/// mano, sin codegen).
///
/// Es una transformacion pura: sin red, sin Flutter. Los `null` pasan tal
/// cual — nunca se convierten en `0`.
class LecturaInversorMapper {
  const LecturaInversorMapper._();

  static LecturaInversor fromDto(DatoInversorDTO dto) => LecturaInversor(
        id: dto.id,
        tiempo: dto.tiempo,
        inversorId: dto.inversorId,
        inversorNombre: dto.inversorNombre,
        bateriaVoltajeV: dto.bateriaVoltajeV,
        bateriaCorrienteA: dto.bateriaCorrienteA,
        bateriaPotenciaW: dto.bateriaPotenciaW,
        pvVoltajeV: dto.pvVoltajeV,
        pvPotenciaW: dto.pvPotenciaW,
        pvCorrienteA: dto.pvCorrienteA,
        salidaVoltajeV: dto.salidaVoltajeV,
        salidaPotenciaW: dto.salidaPotenciaW,
        salidaCorrienteA: dto.salidaCorrienteA,
        salidaAparenteVa: dto.salidaAparenteVa,
        salidaFrecuenciaHz: dto.salidaFrecuenciaHz,
        cargaPorcentaje: dto.cargaPorcentaje,
        socPct: dto.socPct,
        redVoltajeV: dto.redVoltajeV,
        redFrecuenciaHz: dto.redFrecuenciaHz,
        busVoltajeV: dto.busVoltajeV,
        temperaturaC: dto.temperaturaC,
        eficienciaPct: dto.eficienciaPct,
        consumoRedW: dto.consumoRedW,
        modoOperacion: dto.modoOperacion,
        codigoFallo: dto.codigoFallo,
        bateriaCargando: dto.bateriaCargando,
        pvActivo: dto.pvActivo,
        redActiva: dto.redActiva,
        crcValido: dto.crcValido,
        latenciaMs: dto.latenciaMs,
      );

  /// Atajo JSON => entidad (lo usan los datasources).
  static LecturaInversor fromJson(Map<String, dynamic> json) =>
      fromDto(DatoInversorDTO.fromJson(json));
}
