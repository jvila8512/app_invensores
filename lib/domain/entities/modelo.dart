// lib/domain/entities/modelo.dart

import 'package:etecsa_supervision/domain/entities/marca.dart';

/// Modelo del inversor (`ModeloInversorDTO` del backend).
class Modelo {
  const Modelo({
    this.id,
    this.nombre,
    this.capacidadVa,
    this.voltajeSistemaNom,
    this.descripcion,
    this.marca,
  });

  final int? id;
  final String? nombre;

  /// Capacidad nominal [VA] — la fuente de `kVA` del formateo T-2.
  final int? capacidadVa;

  /// Voltaje nominal del sistema [V].
  final int? voltajeSistemaNom;
  final String? descripcion;
  final Marca? marca;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Modelo &&
        other.id == id &&
        other.nombre == nombre &&
        other.capacidadVa == capacidadVa &&
        other.voltajeSistemaNom == voltajeSistemaNom &&
        other.descripcion == descripcion &&
        other.marca == marca;
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, capacidadVa, voltajeSistemaNom, descripcion, marca);

  @override
  String toString() => 'Modelo(id: $id, nombre: $nombre)';
}
