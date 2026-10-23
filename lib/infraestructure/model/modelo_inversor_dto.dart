// lib/infraestructure/model/modelo_inversor_dto.dart

import 'package:etecsa_supervision/infraestructure/model/json_read.dart';
import 'package:etecsa_supervision/infraestructure/model/marca_dto.dart';

/// `ModeloInversorDTO` del backend.
class ModeloInversorDTO {
  const ModeloInversorDTO({
    this.id,
    this.nombre,
    this.capacidadVa,
    this.voltajeSistemaNom,
    this.descripcion,
    this.marca,
  });

  factory ModeloInversorDTO.fromJson(Map<String, dynamic> json) {
    final marcaJson = readObject(json, 'marca');
    return ModeloInversorDTO(
      id: readInt(json, 'id'),
      nombre: readString(json, 'nombre'),
      capacidadVa: readInt(json, 'capacidadVa'),
      voltajeSistemaNom: readInt(json, 'voltajeSistemaNom'),
      descripcion: readString(json, 'descripcion'),
      marca: marcaJson == null ? null : MarcaDTO.fromJson(marcaJson),
    );
  }

  final int? id;
  final String? nombre;
  final int? capacidadVa;
  final int? voltajeSistemaNom;
  final String? descripcion;
  final MarcaDTO? marca;
}
