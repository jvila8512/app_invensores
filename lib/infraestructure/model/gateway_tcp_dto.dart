// lib/infraestructure/model/gateway_tcp_dto.dart

import 'package:etecsa_supervision/infraestructure/model/json_read.dart';
import 'package:etecsa_supervision/infraestructure/model/sitio_dto.dart';

/// `GatewayTcpDTO` del backend.
///
/// `tiempoEsperaMs` (cadencia de sondeo [ms]) SI esta en el DTO del
/// gateway; se modela como `int?` porque la politica de frescura debe
/// sobrevivir igualmente a un backend que no lo mande (design D2: fallback
/// de 10 s).
class GatewayTcpDTO {
  const GatewayTcpDTO({
    this.id,
    this.nombre,
    this.descripcion,
    this.ubicacion,
    this.direccionIp,
    this.puerto,
    this.activo,
    this.estadoConexion,
    this.ultimaLectura,
    this.ultimoError,
    this.tiempoEsperaMs,
    this.reintentos,
    this.sitio,
  });

  factory GatewayTcpDTO.fromJson(Map<String, dynamic> json) {
    final sitioJson = readObject(json, 'sitio');
    return GatewayTcpDTO(
      id: readInt(json, 'id'),
      nombre: readString(json, 'nombre'),
      descripcion: readString(json, 'descripcion'),
      ubicacion: readString(json, 'ubicacion'),
      direccionIp: readString(json, 'direccionIp'),
      puerto: readInt(json, 'puerto'),
      activo: readBool(json, 'activo'),
      estadoConexion: readString(json, 'estadoConexion'),
      ultimaLectura: readInstant(json, 'ultimaLectura'),
      ultimoError: readString(json, 'ultimoError'),
      tiempoEsperaMs: readInt(json, 'tiempoEsperaMs'),
      reintentos: readInt(json, 'reintentos'),
      sitio: sitioJson == null ? null : SitioDTO.fromJson(sitioJson),
    );
  }

  final int? id;
  final String? nombre;
  final String? descripcion;
  final String? ubicacion;
  final String? direccionIp;
  final int? puerto;
  final bool? activo;
  final String? estadoConexion;
  final DateTime? ultimaLectura;
  final String? ultimoError;
  final int? tiempoEsperaMs;
  final int? reintentos;
  final SitioDTO? sitio;
}
