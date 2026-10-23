// lib/domain/entities/gateway.dart

import 'package:etecsa_supervision/domain/entities/sitio.dart';

/// Gateway Modbus TCP del inversor (`GatewayTcpDTO` del backend).
class Gateway {
  const Gateway({
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

  final int? id;
  final String? nombre;
  final String? descripcion;
  final String? ubicacion;
  final String? direccionIp;
  final int? puerto;
  final bool? activo;

  /// `Conectado` | `Error` | `Desconectado` | `Inicializando` (string, no
  /// enum).
  final String? estadoConexion;
  final DateTime? ultimaLectura;
  final String? ultimoError;

  /// Cadencia de sondeo del gateway [ms]. Puede no venir (`int?`): la
  /// politica de frescura cae a 10 s por defecto (design D2, spec T-5).
  final int? tiempoEsperaMs;
  final int? reintentos;
  final Sitio? sitio;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gateway &&
        other.id == id &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.ubicacion == ubicacion &&
        other.direccionIp == direccionIp &&
        other.puerto == puerto &&
        other.activo == activo &&
        other.estadoConexion == estadoConexion &&
        other.ultimaLectura == ultimaLectura &&
        other.ultimoError == ultimoError &&
        other.tiempoEsperaMs == tiempoEsperaMs &&
        other.reintentos == reintentos &&
        other.sitio == sitio;
  }

  @override
  int get hashCode => Object.hash(
        id,
        nombre,
        descripcion,
        ubicacion,
        direccionIp,
        puerto,
        activo,
        estadoConexion,
        ultimaLectura,
        ultimoError,
        tiempoEsperaMs,
        reintentos,
        sitio,
      );

  @override
  String toString() =>
      'Gateway(id: $id, nombre: $nombre, tiempoEsperaMs: $tiempoEsperaMs)';
}
