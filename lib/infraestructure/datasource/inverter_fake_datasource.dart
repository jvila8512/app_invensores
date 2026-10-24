// lib/infraestructure/datasource/inverter_fake_datasource.dart

import 'dart:math';

import 'package:etecsa_supervision/domain/datasources/inverter_datasource.dart';
import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/infraestructure/mapper/inversor_mapper.dart';
import 'package:etecsa_supervision/infraestructure/mapper/lectura_inversor_mapper.dart';

/// Nombres de los sitios sembrados (al menos dos, spec §5).
const List<String> fakeSiteNames = <String>[
  'Planta Norte',
  'Planta Sur',
  'Planta Centro',
];

/// Columnas de telemetria exactas de `DatoInversorDTO` (26), en el orden del
/// DTO Java. El test de paridad de contrato las compara con el fixture del
/// backend: si el DTO real cambia, la fake deja de cumplir el contrato.
const List<String> fakeTelemetryKeys = <String>[
  'bateriaVoltajeV',
  'bateriaCorrienteA',
  'bateriaPotenciaW',
  'pvVoltajeV',
  'pvPotenciaW',
  'pvCorrienteA',
  'salidaVoltajeV',
  'salidaPotenciaW',
  'salidaCorrienteA',
  'salidaAparenteVa',
  'salidaFrecuenciaHz',
  'cargaPorcentaje',
  'socPct',
  'redVoltajeV',
  'redFrecuenciaHz',
  'busVoltajeV',
  'temperaturaC',
  'eficienciaPct',
  'consumoRedW',
  'modoOperacion',
  'codigoFallo',
  'bateriaCargando',
  'pvActivo',
  'redActiva',
  'crcValido',
  'latenciaMs',
];

const List<String> _felicityModes = <String>[
  'SIN_RED',
  'RED',
  'SOLAR',
  'HIBRIDO',
  'BATERIA',
];

const List<String> _mustModes = <String>[
  'POWER_ON',
  'SELF_TEST',
  'OFF_GRID',
  'GRID_TIE',
  'BYPASS',
  'CHARGING',
];

/// Generador determinista del mundo fake: catalogo estable + telemetria
/// solar plausible que avanza con un reloj virtual.
///
/// Se siembra con `Random(seed)` y un instante fijo (`2026-06-17T10:00Z` por
/// defecto) para que dos ejecuciones con la misma semilla produzcan
/// exactamente las mismas lecturas (spec §5 "Deterministic seed").
///
/// El JSON generado replica los nombres camelCase del backend y se mapea con
/// los mappers reales, de modo que la fake ejercita el mismo contrato que la
/// implementacion HTTP.
class SeededInverterFleet {
  SeededInverterFleet({
    int seed = 42,
    DateTime? start,
    this.cadence = const Duration(seconds: 5),
    this.inverterCount = 12,
    this.siteCount = 3,
  }) : _random = Random(seed),
       _now = (start ?? defaultStart).toUtc() {
    _catalogJson = _buildCatalog();
  }

  /// Reloj virtual por defecto: fijo para que la semilla sea reproducible.
  static final DateTime defaultStart = DateTime.utc(2026, 6, 17, 10);

  final Random _random;
  final Duration cadence;
  final int inverterCount;
  final int siteCount;

  DateTime _now;
  late final List<Map<String, dynamic>> _catalogJson;

  /// Instante virtual actual (avanza [cadence] en cada sondeo).
  DateTime get now => _now;

  /// Paso mínimo del reloj virtual.
  ///
  /// El backend real entrega tiempos estrictamente crecientes. Con
  /// `cadence: Duration.zero` (útil para tests rápidos) el reloj no avanzaría
  /// y dos lecturas sucesivas compartirían `tiempo`, rompiendo el invariante
  /// que la UI usa para staleness y para el gráfico en vivo.
  static const Duration _minTick = Duration(milliseconds: 1);

  Duration get _tick => cadence < _minTick ? _minTick : cadence;

  /// Catalogo JSON estable (mismas filas en cada llamada).
  List<Map<String, dynamic>> get catalogJson =>
      List<Map<String, dynamic>>.unmodifiable(_catalogJson);

  /// Una lectura por inversor con el mismo instante de sondeo.
  ///
  /// El ultimo inversor se entrega OFFLINE (lectura de hace 40 s y todas las
  /// columnas en `null`) para que la UI demuestre el guion largo `—`.
  List<Map<String, dynamic>> nextLatestReadingsJson() {
    final timestamp = _now;
    _now = _now.add(_tick);
    return [
      for (var index = 0; index < _catalogJson.length; index++)
        _readingJson(
          index: index,
          timestamp: index == _offlineIndex
              ? timestamp.subtract(const Duration(seconds: 40))
              : timestamp,
          nullTelemetry: index == _offlineIndex,
        ),
    ];
  }

  /// Lectura del instante virtual actual, sin avanzar el reloj.
  Map<String, dynamic> readingJsonFor(int inversorId) {
    if (!_isValidId(inversorId)) {
      throw RangeError.range(inversorId, 1, inverterCount, 'inversorId');
    }
    return _readingJson(index: inversorId - 1, timestamp: _now);
  }

  /// Siguiente lectura del inversor y avance del reloj virtual (live fake).
  Map<String, dynamic> nextReadingJson(int inversorId) {
    if (!_isValidId(inversorId)) {
      throw RangeError.range(inversorId, 1, inverterCount, 'inversorId');
    }
    final timestamp = _now;
    _now = _now.add(_tick);
    return _readingJson(index: inversorId - 1, timestamp: timestamp);
  }

  /// Historial del inversor, de la fila mas nueva a la mas vieja
  /// (`sort=tiempo,desc` del backend).
  List<Map<String, dynamic>> historyJson(int inversorId, {int size = 200}) {
    if (!_isValidId(inversorId) || size <= 0) return const [];
    return [
      for (var i = 0; i < size; i++)
        _readingJson(
          index: inversorId - 1,
            timestamp: _now.subtract(_tick * i),
        ),
    ];
  }

  int get _offlineIndex => inverterCount - 1;

  int get _alarmIndex => inverterCount - 2;

  bool _isValidId(int id) => id >= 1 && id <= inverterCount;

  List<Map<String, dynamic>> _buildCatalog() {
    final catalog = <Map<String, dynamic>>[];
    final perSite = (inverterCount / siteCount).ceil();
    for (var siteIndex = 0; siteIndex < siteCount; siteIndex++) {
      final siteName = fakeSiteNames[siteIndex % fakeSiteNames.length];
      final siteCode = String.fromCharCode(65 + siteIndex);
      final brand = siteIndex.isEven ? 'Felicity' : 'MUST';
      final model = siteIndex.isEven ? 'A1' : 'MUST-5K';
      final masterId = siteIndex * perSite + 1;
      for (var slot = 0; slot < perSite; slot++) {
        final id = siteIndex * perSite + slot + 1;
        if (id > inverterCount) break;
        final nombre = '$brand-$siteCode${slot + 1}';
        final isMaster = slot == 0;
        catalog.add(<String, dynamic>{
          'id': id,
          'nombre': nombre,
          'numeroSerie': 'SN-$siteCode${slot + 1}',
          'esMaster': isMaster,
          'tipoConexion': 'TcpModbus',
          'puertoSerial': null,
          'slaveId': slot + 1,
          'activo': true,
          'estadoDispositivo': id == inverterCount
              ? 'Desconectado'
              : 'Conectado',
          'ultimaLectura': _iso(
            id == inverterCount
                ? _now.subtract(const Duration(seconds: 40))
                : _now,
          ),
          'ultimoError': id == inverterCount
              ? 'Sin respuesta del gateway'
              : null,
          'periodoMuestreoSeg': 10,
          'fechaRegistro': '2026-01-01T00:00:00.000Z',
          'ultimaConexion': _iso(_now),
          'sitio': <String, dynamic>{
            'id': siteIndex + 1,
            'nombre': siteName,
            'descripcion': 'Planta solar $siteName',
            'ubicacion': 'La Habana',
            'contacto': 'operaciones',
            'telefono': '5555-000$siteIndex',
            'activo': true,
            'fechaInstalacion': '2026-01-01',
          },
          'marca': <String, dynamic>{
            'id': siteIndex.isEven ? 1 : 2,
            'nombre': brand,
            'fabricante': siteIndex.isEven ? 'Felicity Power' : 'MUST Energy',
            'registroInicio': 0,
            'registroFin': 99,
            'registroInfoInicio': 0,
            'registroInfoFin': 10,
            'baudRateDefault': 9600,
            'descripcion': null,
            'activaMarcaDefault': true,
          },
          'modelo': <String, dynamic>{
            'id': siteIndex.isEven ? 1 : 2,
            'nombre': model,
            'capacidadVa': 5000,
            'voltajeSistemaNom': 48,
            'descripcion': null,
            'marca': <String, dynamic>{
              'id': siteIndex.isEven ? 1 : 2,
              'nombre': brand,
            },
          },
          'gateway': <String, dynamic>{
            'id': siteIndex + 1,
            'nombre': 'GW-$siteCode',
            'descripcion': 'Gateway de $siteName',
            'ubicacion': null,
            'direccionIp': '192.168.1.${10 + siteIndex}',
            'puerto': 502,
            'activo': true,
            'estadoConexion': 'Conectado',
            'ultimaLectura': _iso(_now),
            'ultimoError': null,
            'tiempoEsperaMs': 10000,
            'reintentos': 0,
            'sitio': null,
          },
          'masterReferencia': isMaster
              ? null
              : <String, dynamic>{
                  'id': masterId,
                  'nombre': '$brand-${siteCode}1',
                },
        });
      }
    }
    return catalog;
  }

  Map<String, dynamic> _readingJson({
    required int index,
    required DateTime timestamp,
    bool nullTelemetry = false,
  }) {
    final inversor = _catalogJson[index];
    final inversorId = inversor['id'] as int;
    final inversorNombre = inversor['nombre'] as String;
    final marca = inversor['marca'] as Map<String, dynamic>;
    final brand = marca['nombre'] as String;

    final values = <String, dynamic>{
      for (final key in fakeTelemetryKeys) key: null,
    };

    if (!nullTelemetry) {
      final pvVoltaje = 300 + _random.nextDouble() * 120;
      final pvCorriente = 8 + _random.nextDouble() * 14;
      final pvPotencia = pvVoltaje * pvCorriente;
      final bateriaVoltaje = 48 + _random.nextDouble() * 5.4;
      final cargando = _random.nextBool();
      final bateriaCorriente =
          (cargando ? 1.0 : -1.0) * (5 + _random.nextDouble() * 15);
      final bateriaPotencia = bateriaVoltaje * bateriaCorriente;
      final eficiencia = 85 + _random.nextDouble() * 12;
      final salidaVoltaje = 218 + _random.nextDouble() * 4;
      final salidaPotencia = max(0.0, pvPotencia - bateriaPotencia);
      final modos = brand == 'MUST' ? _mustModes : _felicityModes;

      values
        ..['bateriaVoltajeV'] = _round(bateriaVoltaje, 1)
        ..['bateriaCorrienteA'] = _round(bateriaCorriente, 1)
        ..['bateriaPotenciaW'] = _round(bateriaPotencia, 1)
        ..['pvVoltajeV'] = _round(pvVoltaje, 1)
        ..['pvPotenciaW'] = _round(pvPotencia, 1)
        ..['pvCorrienteA'] = _round(pvCorriente, 1)
        ..['salidaVoltajeV'] = _round(salidaVoltaje, 1)
        ..['salidaPotenciaW'] = _round(salidaPotencia, 1)
        ..['salidaCorrienteA'] = _round(salidaPotencia / salidaVoltaje, 1)
        ..['salidaAparenteVa'] = _round(salidaPotencia / (eficiencia / 100), 1)
        ..['salidaFrecuenciaHz'] = _round(59.8 + _random.nextDouble() * 0.4, 1)
        ..['cargaPorcentaje'] = 20 + _random.nextInt(71)
        ..['socPct'] = 40 + _random.nextInt(56)
        ..['redVoltajeV'] = _round(218 + _random.nextDouble() * 6, 1)
        ..['redFrecuenciaHz'] = _round(59.8 + _random.nextDouble() * 0.4, 1)
        ..['busVoltajeV'] = _round(390 + _random.nextDouble() * 20, 1)
        ..['temperaturaC'] = _round(28 + _random.nextDouble() * 18, 1)
        ..['eficienciaPct'] = _round(eficiencia, 1)
        ..['consumoRedW'] = _round(_random.nextDouble() * 1500, 1)
        ..['modoOperacion'] = modos[_random.nextInt(modos.length)]
        ..['codigoFallo'] = index == _alarmIndex ? 7 : 0
        ..['bateriaCargando'] = cargando
        ..['pvActivo'] = pvPotencia > 0
        ..['redActiva'] = true
        ..['crcValido'] = true
        ..['latenciaMs'] = 10 + _random.nextInt(51);
    }

    return <String, dynamic>{
      'id': _readingId(inversorId, timestamp),
      'tiempo': _iso(timestamp),
      'inversor': <String, dynamic>{'id': inversorId, 'nombre': inversorNombre},
      ...values,
    };
  }

  int _readingId(int inversorId, DateTime timestamp) =>
      inversorId * 1000000 +
      (timestamp.millisecondsSinceEpoch ~/ 1000) % 1000000;

  double _round(double value, int decimals) {
    final factor = pow(10, decimals).toDouble();
    return (value * factor).round() / factor;
  }

  String _iso(DateTime value) => value.toUtc().toIso8601String();
}

/// Datasource fake que implementa el MISMO contrato que la remota (spec §5
/// "Fake behind the same repository interface").
///
/// No importa ni instancia `Dio`: la demo offline no hace ninguna peticion.
class FakeInverterDatasource implements InverterDatasource {
  FakeInverterDatasource({
    int seed = 42,
    DateTime? start,
    Duration cadence = const Duration(seconds: 5),
  }) : _fleet = SeededInverterFleet(seed: seed, start: start, cadence: cadence);

  final SeededInverterFleet _fleet;

  @override
  Future<List<Inversor>> fetchAll() async => [
    for (final json in _fleet.catalogJson) InversorMapper.fromJson(json),
  ];

  @override
  Future<List<LecturaInversor>> fetchLatestReadings() async => [
    for (final json in _fleet.nextLatestReadingsJson())
      LecturaInversorMapper.fromJson(json),
  ];

  @override
  Future<List<LecturaInversor>> fetchHistory(
    int inversorId, {
    int size = 200,
  }) async => [
    for (final json in _fleet.historyJson(inversorId, size: size))
      LecturaInversorMapper.fromJson(json),
  ];

  @override
  Stream<LecturaInversor> watchLive(int inversorId) async* {
    if (inversorId < 1 || inversorId > _fleet.inverterCount) return;
    while (true) {
      yield LecturaInversorMapper.fromJson(_fleet.nextReadingJson(inversorId));
      await Future<void>.delayed(_fleet.cadence);
    }
  }
}
