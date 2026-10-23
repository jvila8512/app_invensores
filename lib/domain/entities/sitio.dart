// lib/domain/entities/sitio.dart

/// Sitio (planta) donde esta fisicamente el inversor.
class Sitio {
  const Sitio({
    this.id,
    this.nombre,
    this.descripcion,
    this.ubicacion,
    this.contacto,
    this.telefono,
    this.activo,
    this.fechaInstalacion,
  });

  final int? id;

  /// Nombre del sitio: es la clave de agrupacion del dashboard (spec §2).
  final String? nombre;
  final String? descripcion;
  final String? ubicacion;
  final String? contacto;
  final String? telefono;
  final bool? activo;

  /// Fecha de instalacion (`LocalDate` del backend, solo fecha).
  final DateTime? fechaInstalacion;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sitio &&
        other.id == id &&
        other.nombre == nombre &&
        other.descripcion == descripcion &&
        other.ubicacion == ubicacion &&
        other.contacto == contacto &&
        other.telefono == telefono &&
        other.activo == activo &&
        other.fechaInstalacion == fechaInstalacion;
  }

  @override
  int get hashCode => Object.hash(
        id,
        nombre,
        descripcion,
        ubicacion,
        contacto,
        telefono,
        activo,
        fechaInstalacion,
      );

  @override
  String toString() => 'Sitio(id: $id, nombre: $nombre)';
}
