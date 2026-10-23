// lib/domain/entities/inversor.dart

import 'package:etecsa_supervision/domain/entities/gateway.dart';
import 'package:etecsa_supervision/domain/entities/marca.dart';
import 'package:etecsa_supervision/domain/entities/modelo.dart';
import 'package:etecsa_supervision/domain/entities/sitio.dart';

/// Inversor fisico: espejo Dart del `InversorDTO` del backend.
///
/// `tipoConexion` y `estadoDispositivo` son **strings libres**, nunca enums
/// en Dart: el backend los serializa como texto y pueden crecer sin tocar
/// el cliente. Igual que `LecturaInversor`, tiene igualdad de valores para
/// que la UI pueda comparar inversores sin reconstruir nada.
class Inversor {
  const Inversor({
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

  final int? id;

  /// Nombre visible en la tarjeta y orden del catalogo.
  final String? nombre;
  final String? numeroSerie;

  /// `true` en el master; los esclavos marcan `SLAVE n` con [slaveId]
  /// (spec §2).
  final bool? esMaster;

  /// `SerialRs485` | `TcpModbus` (string del backend, no enum).
  final String? tipoConexion;
  final String? puertoSerial;
  final int? slaveId;
  final bool? activo;

  /// `Conectado` | `Error` | `Desconectado` | `Inicializando` (string, no
  /// enum).
  final String? estadoDispositivo;
  final DateTime? ultimaLectura;
  final String? ultimoError;
  final int? periodoMuestreoSeg;
  final DateTime? fechaRegistro;
  final DateTime? ultimaConexion;

  /// Sitio/planta: clave de agrupacion del dashboard.
  final Sitio? sitio;
  final Marca? marca;
  final Modelo? modelo;
  final Gateway? gateway;

  /// Auto-relacion `masterReferencia`: solo el id. El objeto completo se
  /// descarta a proposito: agregaria igualdad profunda y riesgo de
  /// recursion sin aportar a la UI (las tarjetas usan `esMaster`/`slaveId`).
  final int? masterReferenciaId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Inversor &&
        other.id == id &&
        other.nombre == nombre &&
        other.numeroSerie == numeroSerie &&
        other.esMaster == esMaster &&
        other.tipoConexion == tipoConexion &&
        other.puertoSerial == puertoSerial &&
        other.slaveId == slaveId &&
        other.activo == activo &&
        other.estadoDispositivo == estadoDispositivo &&
        other.ultimaLectura == ultimaLectura &&
        other.ultimoError == ultimoError &&
        other.periodoMuestreoSeg == periodoMuestreoSeg &&
        other.fechaRegistro == fechaRegistro &&
        other.ultimaConexion == ultimaConexion &&
        other.sitio == sitio &&
        other.marca == marca &&
        other.modelo == modelo &&
        other.gateway == gateway &&
        other.masterReferenciaId == masterReferenciaId;
  }

  @override
  int get hashCode => Object.hash(
        id,
        nombre,
        numeroSerie,
        esMaster,
        tipoConexion,
        puertoSerial,
        slaveId,
        activo,
        estadoDispositivo,
        ultimaLectura,
        ultimoError,
        periodoMuestreoSeg,
        fechaRegistro,
        ultimaConexion,
        sitio,
        marca,
        modelo,
        gateway,
        masterReferenciaId,
      );

  @override
  String toString() =>
      'Inversor(id: $id, nombre: $nombre, sitio: $sitio, marca: $marca)';
}
