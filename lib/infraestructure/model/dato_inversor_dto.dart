// lib/infraestructure/model/dato_inversor_dto.dart

import 'package:etecsa_supervision/infraestructure/model/json_read.dart';

/// `DatoInversorDTO` del backend: la lectura cruda de
/// `GET /api/dato-inversors/latest-readings`, del historial y del frame
/// STOMP `/topic/inversor/{id}/live`.
///
/// Los 26 campos de telemetria replican el camelCase exacto del DTO Java y
/// todos son opcionales (sin gateway no hay datos). El `fromJson` es a mano,
/// sin codegen (design D4).
class DatoInversorDTO {
  const DatoInversorDTO({
    this.id,
    this.tiempo,
    this.inversorId,
    this.inversorNombre,
    this.bateriaVoltajeV,
    this.bateriaCorrienteA,
    this.bateriaPotenciaW,
    this.pvVoltajeV,
    this.pvPotenciaW,
    this.pvCorrienteA,
    this.salidaVoltajeV,
    this.salidaPotenciaW,
    this.salidaCorrienteA,
    this.salidaAparenteVa,
    this.salidaFrecuenciaHz,
    this.cargaPorcentaje,
    this.socPct,
    this.redVoltajeV,
    this.redFrecuenciaHz,
    this.busVoltajeV,
    this.temperaturaC,
    this.eficienciaPct,
    this.consumoRedW,
    this.modoOperacion,
    this.codigoFallo,
    this.bateriaCargando,
    this.pvActivo,
    this.redActiva,
    this.crcValido,
    this.latenciaMs,
  });

  factory DatoInversorDTO.fromJson(Map<String, dynamic> json) {
    final inversor = readObject(json, 'inversor');
    return DatoInversorDTO(
      id: readInt(json, 'id'),
      tiempo: readInstant(json, 'tiempo'),
      inversorId: readInt(inversor, 'id'),
      inversorNombre: readString(inversor, 'nombre'),
      bateriaVoltajeV: readDouble(json, 'bateriaVoltajeV'),
      bateriaCorrienteA: readDouble(json, 'bateriaCorrienteA'),
      bateriaPotenciaW: readDouble(json, 'bateriaPotenciaW'),
      pvVoltajeV: readDouble(json, 'pvVoltajeV'),
      pvPotenciaW: readDouble(json, 'pvPotenciaW'),
      pvCorrienteA: readDouble(json, 'pvCorrienteA'),
      salidaVoltajeV: readDouble(json, 'salidaVoltajeV'),
      salidaPotenciaW: readDouble(json, 'salidaPotenciaW'),
      salidaCorrienteA: readDouble(json, 'salidaCorrienteA'),
      salidaAparenteVa: readDouble(json, 'salidaAparenteVa'),
      salidaFrecuenciaHz: readDouble(json, 'salidaFrecuenciaHz'),
      cargaPorcentaje: readInt(json, 'cargaPorcentaje'),
      socPct: readInt(json, 'socPct'),
      redVoltajeV: readDouble(json, 'redVoltajeV'),
      redFrecuenciaHz: readDouble(json, 'redFrecuenciaHz'),
      busVoltajeV: readDouble(json, 'busVoltajeV'),
      temperaturaC: readDouble(json, 'temperaturaC'),
      eficienciaPct: readDouble(json, 'eficienciaPct'),
      consumoRedW: readDouble(json, 'consumoRedW'),
      modoOperacion: readString(json, 'modoOperacion'),
      codigoFallo: readInt(json, 'codigoFallo'),
      bateriaCargando: readBool(json, 'bateriaCargando'),
      pvActivo: readBool(json, 'pvActivo'),
      redActiva: readBool(json, 'redActiva'),
      crcValido: readBool(json, 'crcValido'),
      latenciaMs: readInt(json, 'latenciaMs'),
    );
  }

  final int? id;
  final DateTime? tiempo;
  final int? inversorId;
  final String? inversorNombre;
  final double? bateriaVoltajeV;
  final double? bateriaCorrienteA;
  final double? bateriaPotenciaW;
  final double? pvVoltajeV;
  final double? pvPotenciaW;
  final double? pvCorrienteA;
  final double? salidaVoltajeV;
  final double? salidaPotenciaW;
  final double? salidaCorrienteA;
  final double? salidaAparenteVa;
  final double? salidaFrecuenciaHz;
  final int? cargaPorcentaje;
  final int? socPct;
  final double? redVoltajeV;
  final double? redFrecuenciaHz;
  final double? busVoltajeV;
  final double? temperaturaC;
  final double? eficienciaPct;
  final double? consumoRedW;
  final String? modoOperacion;
  final int? codigoFallo;
  final bool? bateriaCargando;
  final bool? pvActivo;
  final bool? redActiva;
  final bool? crcValido;
  final int? latenciaMs;
}
