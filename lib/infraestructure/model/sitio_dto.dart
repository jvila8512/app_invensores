// lib/infraestructure/model/sitio_dto.dart

import 'package:etecsa_supervision/infraestructure/model/json_read.dart';

/// `SitioDTO` del backend.
class SitioDTO {
  const SitioDTO({
    this.id,
    this.nombre,
    this.descripcion,
    this.ubicacion,
    this.contacto,
    this.telefono,
    this.activo,
    this.fechaInstalacion,
  });

  factory SitioDTO.fromJson(Map<String, dynamic> json) => SitioDTO(
        id: readInt(json, 'id'),
        nombre: readString(json, 'nombre'),
        descripcion: readString(json, 'descripcion'),
        ubicacion: readString(json, 'ubicacion'),
        contacto: readString(json, 'contacto'),
        telefono: readString(json, 'telefono'),
        activo: readBool(json, 'activo'),
        fechaInstalacion: readInstant(json, 'fechaInstalacion'),
      );

  final int? id;
  final String? nombre;
  final String? descripcion;
  final String? ubicacion;
  final String? contacto;
  final String? telefono;
  final bool? activo;
  final DateTime? fechaInstalacion;
}
