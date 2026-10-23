// lib/infraestructure/model/marca_dto.dart

import 'package:etecsa_supervision/infraestructure/model/json_read.dart';

/// `MarcaDTO` del backend.
class MarcaDTO {
  const MarcaDTO({
    this.id,
    this.nombre,
    this.fabricante,
    this.registroInicio,
    this.registroFin,
    this.registroInfoInicio,
    this.registroInfoFin,
    this.baudRateDefault,
    this.descripcion,
    this.activaMarcaDefault,
  });

  factory MarcaDTO.fromJson(Map<String, dynamic> json) => MarcaDTO(
        id: readInt(json, 'id'),
        nombre: readString(json, 'nombre'),
        fabricante: readString(json, 'fabricante'),
        registroInicio: readInt(json, 'registroInicio'),
        registroFin: readInt(json, 'registroFin'),
        registroInfoInicio: readInt(json, 'registroInfoInicio'),
        registroInfoFin: readInt(json, 'registroInfoFin'),
        baudRateDefault: readInt(json, 'baudRateDefault'),
        descripcion: readString(json, 'descripcion'),
        activaMarcaDefault: readBool(json, 'activaMarcaDefault'),
      );

  final int? id;
  final String? nombre;
  final String? fabricante;
  final int? registroInicio;
  final int? registroFin;
  final int? registroInfoInicio;
  final int? registroInfoFin;
  final int? baudRateDefault;
  final String? descripcion;
  final bool? activaMarcaDefault;
}
