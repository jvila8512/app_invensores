// lib/domain/entities/lectura_inversor.dart

/// Lectura de telemetria de un inversor: espejo Dart del `DatoInversorDTO`
/// del backend (nombres camelCase identicos).
///
/// Los 26 campos de telemetria son opcionales: mientras el gateway no
/// responda el backend manda `null` y la UI debe pintar `—`, nunca un `0`
/// inventado ni una excepcion (spec §3 "Null telemetry renders as an em
/// dash").
///
/// La igualdad de valores (`==`/`hashCode`) es OBLIGATORIA: el dashboard
/// observa cada tarjeta con `select((m) => m[id])` y solo debe reconstruir
/// la tarjeta cuyo valor cambio. Sin igualdad, los 300 cards se
/// reconstruyen en cada sondeo de 5 s (spec §3 "300 inverters without
/// jank").
///
/// Nota: `DateTime` compara tambien la zona horaria; el mapper normaliza
/// `tiempo` a UTC para que dos lecturas del mismo instante sean iguales.
class LecturaInversor {
  const LecturaInversor({
    this.id,
    this.tiempo,
    this.inversorId,
    this.inversorNombre,
    this.bateriaVoltajeV,
    this.bateriaCorrienteA,
    this.bateriaPotenciaW,
    this.pvVoltajeV,
    this.pvPotenciaW,
    this.pvCorrienteA,
    this.salidaVoltajeV,
    this.salidaPotenciaW,
    this.salidaCorrienteA,
    this.salidaAparenteVa,
    this.salidaFrecuenciaHz,
    this.cargaPorcentaje,
    this.socPct,
    this.redVoltajeV,
    this.redFrecuenciaHz,
    this.busVoltajeV,
    this.temperaturaC,
    this.eficienciaPct,
    this.consumoRedW,
    this.modoOperacion,
    this.codigoFallo,
    this.bateriaCargando,
    this.pvActivo,
    this.redActiva,
    this.crcValido,
    this.latenciaMs,
  });

  /// id de la fila `dato_inversor`.
  final int? id;

  /// Instante de la lectura (UTC, normalizado por el mapper).
  final DateTime? tiempo;

  /// Id del inversor al que pertenece la lectura (`inversor.id` del DTO).
  final int? inversorId;

  /// Nombre del inversor (`inversor.nombre` del DTO, recortado).
  final String? inversorNombre;

  /// Voltaje de baterias [V].
  final double? bateriaVoltajeV;

  /// Corriente de baterias [A] (negativa descargando).
  final double? bateriaCorrienteA;

  /// Potencia de baterias [W].
  final double? bateriaPotenciaW;

  /// Voltaje del array PV [V].
  final double? pvVoltajeV;

  /// Potencia PV [W] (la que alimenta el KPI y las tarjetas).
  final double? pvPotenciaW;

  /// Corriente PV [A].
  final double? pvCorrienteA;

  /// Voltaje de salida AC [V].
  final double? salidaVoltajeV;

  /// Potencia de salida AC [W].
  final double? salidaPotenciaW;

  /// Corriente de salida AC [A].
  final double? salidaCorrienteA;

  /// Potencia aparente de salida [VA].
  final double? salidaAparenteVa;

  /// Frecuencia de salida [Hz].
  final double? salidaFrecuenciaHz;

  /// Carga (uso) [% 0-100]. Distinta de [socPct]: la carga mide consumo,
  /// el SOC mide la bateria (spec §3 "cargaPorcentaje y socPct son
  /// distintos").
  final int? cargaPorcentaje;

  /// Estado de carga de la bateria [% 0-100] — el que usa el anillo SOC.
  final int? socPct;

  /// Voltaje de la red [V].
  final double? redVoltajeV;

  /// Frecuencia de la red [Hz].
  final double? redFrecuenciaHz;

  /// Voltaje del bus DC [V].
  final double? busVoltajeV;

  /// Temperatura interna [°C].
  final double? temperaturaC;

  /// Eficiencia del inversor [% 0-100].
  final double? eficienciaPct;

  /// Consumo desde la red [W].
  final double? consumoRedW;

  /// Modo de operacion: string libre dependiente de la marca (spec T-6).
  /// NUNCA es enum en Dart; ver `ModoOperacion` para el mapeo por marca.
  final String? modoOperacion;

  /// Codigo de fallo (0 = sin fallo; se muestra como `E07`, etc.).
  final int? codigoFallo;

  /// La bateria se esta cargando.
  final bool? bateriaCargando;

  /// Array PV activo.
  final bool? pvActivo;

  /// Red AC activa.
  final bool? redActiva;

  /// CRC Modbus valido en la ultima trama.
  final bool? crcValido;

  /// Latencia del gateway [ms].
  final int? latenciaMs;

  /// `true` cuando hay alarma (`codigoFallo > 0`); un `null` no cuenta.
  bool get enAlarma => (codigoFallo ?? 0) > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LecturaInversor &&
        other.id == id &&
        other.tiempo == tiempo &&
        other.inversorId == inversorId &&
        other.inversorNombre == inversorNombre &&
        other.bateriaVoltajeV == bateriaVoltajeV &&
        other.bateriaCorrienteA == bateriaCorrienteA &&
        other.bateriaPotenciaW == bateriaPotenciaW &&
        other.pvVoltajeV == pvVoltajeV &&
        other.pvPotenciaW == pvPotenciaW &&
        other.pvCorrienteA == pvCorrienteA &&
        other.salidaVoltajeV == salidaVoltajeV &&
        other.salidaPotenciaW == salidaPotenciaW &&
        other.salidaCorrienteA == salidaCorrienteA &&
        other.salidaAparenteVa == salidaAparenteVa &&
        other.salidaFrecuenciaHz == salidaFrecuenciaHz &&
        other.cargaPorcentaje == cargaPorcentaje &&
        other.socPct == socPct &&
        other.redVoltajeV == redVoltajeV &&
        other.redFrecuenciaHz == redFrecuenciaHz &&
        other.busVoltajeV == busVoltajeV &&
        other.temperaturaC == temperaturaC &&
        other.eficienciaPct == eficienciaPct &&
        other.consumoRedW == consumoRedW &&
        other.modoOperacion == modoOperacion &&
        other.codigoFallo == codigoFallo &&
        other.bateriaCargando == bateriaCargando &&
        other.pvActivo == pvActivo &&
        other.redActiva == redActiva &&
        other.crcValido == crcValido &&
        other.latenciaMs == latenciaMs;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tiempo,
        inversorId,
        inversorNombre,
        bateriaVoltajeV,
        bateriaCorrienteA,
        bateriaPotenciaW,
        pvVoltajeV,
        pvPotenciaW,
        pvCorrienteA,
        salidaVoltajeV,
        salidaPotenciaW,
        salidaCorrienteA,
        salidaAparenteVa,
        salidaFrecuenciaHz,
        cargaPorcentaje,
        socPct,
        redVoltajeV,
        redFrecuenciaHz,
        busVoltajeV,
        temperaturaC,
        eficienciaPct,
        consumoRedW,
        modoOperacion,
        codigoFallo,
        bateriaCargando,
        pvActivo,
        redActiva,
        crcValido,
        latenciaMs,
      ]);

  @override
  String toString() =>
      'LecturaInversor(id: $id, tiempo: $tiempo, inversorId: $inversorId, '
      'pvPotenciaW: $pvPotenciaW, socPct: $socPct, '
      'cargaPorcentaje: $cargaPorcentaje, eficienciaPct: $eficienciaPct, '
      'codigoFallo: $codigoFallo, modoOperacion: $modoOperacion, '
      'latenciaMs: $latenciaMs)';
}
