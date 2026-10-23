// lib/domain/entities/marca.dart

/// Marca del inversor. Define el mapa de registros Modbus; en el cliente
/// solo importa su nombre (identidad de tarjeta y mapeo de
/// `modoOperacion`).
class Marca {
  const Marca({
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

  final int? id;

  /// Nombre de la marca (`Felicity`, `MUST`, ...): determina el catalogo de
  /// `modoOperacion` (spec T-6).
  final String? nombre;
  final String? fabricante;
  final int? registroInicio;
  final int? registroFin;
  final int? registroInfoInicio;
  final int? registroInfoFin;
  final int? baudRateDefault;
  final String? descripcion;
  final bool? activaMarcaDefault;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Marca &&
        other.id == id &&
        other.nombre == nombre &&
        other.fabricante == fabricante &&
        other.registroInicio == registroInicio &&
        other.registroFin == registroFin &&
        other.registroInfoInicio == registroInfoInicio &&
        other.registroInfoFin == registroInfoFin &&
        other.baudRateDefault == baudRateDefault &&
        other.descripcion == descripcion &&
        other.activaMarcaDefault == activaMarcaDefault;
  }

  @override
  int get hashCode => Object.hash(
        id,
        nombre,
        fabricante,
        registroInicio,
        registroFin,
        registroInfoInicio,
        registroInfoFin,
        baudRateDefault,
        descripcion,
        activaMarcaDefault,
      );

  @override
  String toString() => 'Marca(id: $id, nombre: $nombre)';
}
