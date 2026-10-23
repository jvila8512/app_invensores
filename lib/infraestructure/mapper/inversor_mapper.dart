// lib/infraestructure/mapper/inversor_mapper.dart

import 'package:etecsa_supervision/domain/entities/gateway.dart';
import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/marca.dart';
import 'package:etecsa_supervision/domain/entities/modelo.dart';
import 'package:etecsa_supervision/domain/entities/sitio.dart';
import 'package:etecsa_supervision/infraestructure/model/gateway_tcp_dto.dart';
import 'package:etecsa_supervision/infraestructure/model/inversor_dto.dart';
import 'package:etecsa_supervision/infraestructure/model/marca_dto.dart';
import 'package:etecsa_supervision/infraestructure/model/modelo_inversor_dto.dart';
import 'package:etecsa_supervision/infraestructure/model/sitio_dto.dart';

/// Mapeo `InversorDTO` => `Inversor` con sus relaciones anidadas
/// (design D4: mappers a mano, sin codegen). Transformacion pura, sin red
/// ni Flutter.
class InversorMapper {
  const InversorMapper._();

  static Inversor fromDto(InversorDTO dto) => Inversor(
        id: dto.id,
        nombre: dto.nombre,
        numeroSerie: dto.numeroSerie,
        esMaster: dto.esMaster,
        tipoConexion: dto.tipoConexion,
        puertoSerial: dto.puertoSerial,
        slaveId: dto.slaveId,
        activo: dto.activo,
        estadoDispositivo: dto.estadoDispositivo,
        ultimaLectura: dto.ultimaLectura,
        ultimoError: dto.ultimoError,
        periodoMuestreoSeg: dto.periodoMuestreoSeg,
        fechaRegistro: dto.fechaRegistro,
        ultimaConexion: dto.ultimaConexion,
        sitio: dto.sitio == null ? null : _sitio(dto.sitio!),
        marca: dto.marca == null ? null : _marca(dto.marca!),
        modelo: dto.modelo == null ? null : _modelo(dto.modelo!),
        gateway: dto.gateway == null ? null : _gateway(dto.gateway!),
        masterReferenciaId: dto.masterReferenciaId,
      );

  /// Atajo JSON => entidad (lo usan los datasources).
  static Inversor fromJson(Map<String, dynamic> json) =>
      fromDto(InversorDTO.fromJson(json));

  static Sitio _sitio(SitioDTO dto) => Sitio(
        id: dto.id,
        nombre: dto.nombre,
        descripcion: dto.descripcion,
        ubicacion: dto.ubicacion,
        contacto: dto.contacto,
        telefono: dto.telefono,
        activo: dto.activo,
        fechaInstalacion: dto.fechaInstalacion,
      );

  static Marca _marca(MarcaDTO dto) => Marca(
        id: dto.id,
        nombre: dto.nombre,
        fabricante: dto.fabricante,
        registroInicio: dto.registroInicio,
        registroFin: dto.registroFin,
        registroInfoInicio: dto.registroInfoInicio,
        registroInfoFin: dto.registroInfoFin,
        baudRateDefault: dto.baudRateDefault,
        descripcion: dto.descripcion,
        activaMarcaDefault: dto.activaMarcaDefault,
      );

  static Modelo _modelo(ModeloInversorDTO dto) => Modelo(
        id: dto.id,
        nombre: dto.nombre,
        capacidadVa: dto.capacidadVa,
        voltajeSistemaNom: dto.voltajeSistemaNom,
        descripcion: dto.descripcion,
        marca: dto.marca == null ? null : _marca(dto.marca!),
      );

  static Gateway _gateway(GatewayTcpDTO dto) => Gateway(
        id: dto.id,
        nombre: dto.nombre,
        descripcion: dto.descripcion,
        ubicacion: dto.ubicacion,
        direccionIp: dto.direccionIp,
        puerto: dto.puerto,
        activo: dto.activo,
        estadoConexion: dto.estadoConexion,
        ultimaLectura: dto.ultimaLectura,
        ultimoError: dto.ultimoError,
        tiempoEsperaMs: dto.tiempoEsperaMs,
        reintentos: dto.reintentos,
        sitio: dto.sitio == null ? null : _sitio(dto.sitio!),
      );
}
