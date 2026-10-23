// lib/infraestructure/model/inversor_dto.dart

import 'package:etecsa_supervision/infraestructure/model/gateway_tcp_dto.dart';
import 'package:etecsa_supervision/infraestructure/model/json_read.dart';
import 'package:etecsa_supervision/infraestructure/model/marca_dto.dart';
import 'package:etecsa_supervision/infraestructure/model/modelo_inversor_dto.dart';
import 'package:etecsa_supervision/infraestructure/model/sitio_dto.dart';

/// `InversorDTO` del backend (`GET /api/inversores/all`, sin paginar).
///
/// `tipoConexion` y `estadoDispositivo` llegan como texto (nombres de los
/// enums Java) y se guardan como `String?`: en Dart no hay enum.
///
/// `masterReferencia` es la auto-relacion MASTER/SLAVE; solo se conserva su
/// `id` porque el objeto anidado puede traer la referencia de vuelta y no
/// aporta a la UI.
class InversorDTO {
  const InversorDTO({
    this.id,
    this.nombre,
    this.numeroSerie,
    this.esMaster,
    this.tipoConexion,
    this.puertoSerial,
    this.slaveId,
    this.activo,
    this.estadoDispositivo,
    this.ultimaLectura,
    this.ultimoError,
    this.periodoMuestreoSeg,
    this.fechaRegistro,
    this.ultimaConexion,
    this.sitio,
    this.marca,
    this.modelo,
    this.gateway,
    this.masterReferenciaId,
  });

  factory InversorDTO.fromJson(Map<String, dynamic> json) {
    final sitioJson = readObject(json, 'sitio');
    final marcaJson = readObject(json, 'marca');
    final modeloJson = readObject(json, 'modelo');
    final gatewayJson = readObject(json, 'gateway');
    final masterJson = readObject(json, 'masterReferencia');
    return InversorDTO(
      id: readInt(json, 'id'),
      nombre: readString(json, 'nombre'),
      numeroSerie: readString(json, 'numeroSerie'),
      esMaster: readBool(json, 'esMaster'),
      tipoConexion: readString(json, 'tipoConexion'),
      puertoSerial: readString(json, 'puertoSerial'),
      slaveId: readInt(json, 'slaveId'),
      activo: readBool(json, 'activo'),
      estadoDispositivo: readString(json, 'estadoDispositivo'),
      ultimaLectura: readInstant(json, 'ultimaLectura'),
      ultimoError: readString(json, 'ultimoError'),
      periodoMuestreoSeg: readInt(json, 'periodoMuestreoSeg'),
      fechaRegistro: readInstant(json, 'fechaRegistro'),
      ultimaConexion: readInstant(json, 'ultimaConexion'),
      sitio: sitioJson == null ? null : SitioDTO.fromJson(sitioJson),
      marca: marcaJson == null ? null : MarcaDTO.fromJson(marcaJson),
      modelo:
          modeloJson == null ? null : ModeloInversorDTO.fromJson(modeloJson),
      gateway:
          gatewayJson == null ? null : GatewayTcpDTO.fromJson(gatewayJson),
      masterReferenciaId: readInt(masterJson, 'id'),
    );
  }

  final int? id;
  final String? nombre;
  final String? numeroSerie;
  final bool? esMaster;
  final String? tipoConexion;
  final String? puertoSerial;
  final int? slaveId;
  final bool? activo;
  final String? estadoDispositivo;
  final DateTime? ultimaLectura;
  final String? ultimoError;
  final int? periodoMuestreoSeg;
  final DateTime? fechaRegistro;
  final DateTime? ultimaConexion;
  final SitioDTO? sitio;
  final MarcaDTO? marca;
  final ModeloInversorDTO? modelo;
  final GatewayTcpDTO? gateway;
  final int? masterReferenciaId;
}
