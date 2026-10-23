// test/support/fixtures.dart

import 'package:etecsa_supervision/domain/entities/gateway.dart';
import 'package:etecsa_supervision/domain/entities/inversor.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';
import 'package:etecsa_supervision/domain/entities/marca.dart';
import 'package:etecsa_supervision/domain/entities/modelo.dart';
import 'package:etecsa_supervision/domain/entities/sitio.dart';

/// Campos de telemetría exactos de `DatoInversorDTO` (26), en el orden del
/// DTO Java. Es la lista contra la que se mide la paridad de contrato:
/// si el backend agrega o renombra un campo, los tests de mapeo fallan.
const List<String> datoInversorTelemetryKeys = [
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

/// Nombres de sitio de los fixtures, deliberadamente fuera de orden
/// alfabetico: si la agrupacion no ordena las claves, los tests fallan.
const List<String> kSiteNames = [
  'Planta Norte',
  'Planta Sur',
  'Planta Este',
  'Planta Oeste',
  'Planta Central',
];

/// Inversor completo con todas las relaciones pobladas.
Inversor buildInversor({
  int id = 1,
  String? nombre,
  String? sitioNombre,
  String? marcaNombre,
  String? estadoDispositivo,
  bool esMaster = true,
  int slaveId = 1,
  int? masterReferenciaId,
  Gateway? gateway,
}) {
  final site = sitioNombre ?? kSiteNames.first;
  return Inversor(
    id: id,
    nombre: nombre ?? 'INV-${id.toString().padLeft(3, '0')}',
    numeroSerie: 'SN-$id',
    esMaster: esMaster,
    tipoConexion: 'TcpModbus',
    puertoSerial: null,
    slaveId: slaveId,
    activo: true,
    estadoDispositivo: estadoDispositivo ?? 'Conectado',
    ultimaLectura: DateTime.utc(2026, 6, 17, 10),
    ultimoError: null,
    periodoMuestreoSeg: 10,
    fechaRegistro: DateTime.utc(2026, 1, 1),
    ultimaConexion: DateTime.utc(2026, 6, 17, 9, 59),
    sitio: Sitio(id: 1, nombre: site),
    marca: Marca(id: 1, nombre: marcaNombre ?? 'Felicity'),
    modelo: const Modelo(
      id: 1,
      nombre: 'A1',
      capacidadVa: 5000,
      voltajeSistemaNom: 48,
    ),
    gateway: gateway ?? buildGateway(),
    masterReferenciaId: masterReferenciaId,
  );
}

/// Flota determinista: [count] inversores repartidos en [siteCount] sitios.
/// Por defecto los 300 / 5 sitios de la spec §2.
List<Inversor> buildFleet({int count = 300, int siteCount = 5}) => [
      for (var i = 0; i < count; i++)
        buildInversor(
          id: i + 1,
          sitioNombre: kSiteNames[i % siteCount],
          esMaster: i % 10 == 0,
          slaveId: (i % 8) + 1,
        ),
    ];

/// Gateway de pruebas. [tiempoEsperaMs] `null` simula al backend que no
/// expone la cadencia (fallback de 10 s de la politica de frescura).
Gateway buildGateway({
  String nombre = 'GW-1',
  int? tiempoEsperaMs = 10000,
}) =>
    Gateway(
      id: 1,
      nombre: nombre,
      descripcion: 'Gateway de pruebas',
      ubicacion: null,
      direccionIp: '192.168.1.10',
      puerto: 502,
      activo: true,
      estadoConexion: 'Conectado',
      ultimaLectura: DateTime.utc(2026, 6, 17, 10),
      ultimoError: null,
      tiempoEsperaMs: tiempoEsperaMs,
      reintentos: 0,
      sitio: null,
    );

/// Lectura mínima para los tests de politicas (no de mapeo).
LecturaInversor buildLectura({
  int id = 1,
  int? inversorId = 1,
  DateTime? tiempo,
  double? pvPotenciaW,
  int? socPct,
  int? codigoFallo,
}) =>
    LecturaInversor(
      id: id,
      inversorId: inversorId,
      tiempo: tiempo ?? DateTime.utc(2026, 6, 17, 12),
      pvPotenciaW: pvPotenciaW,
      socPct: socPct,
      codigoFallo: codigoFallo,
    );

/// JSON completo de `DatoInversorDTO`: id, tiempo, inversor y los 26
/// campos de telemetría con valores tipicos.
Map<String, dynamic> fullDatoInversorJson({
  int id = 7,
  String? tiempo = '2026-06-17T10:00:00Z',
  int? inversorId = 1,
  String? inversorNombre = 'INV-001',
}) =>
    {
      'id': id,
      'tiempo': tiempo,
      'bateriaVoltajeV': 48.6,
      'bateriaCorrienteA': -12.5,
      'bateriaPotenciaW': -607.5,
      'pvVoltajeV': 120.3,
      'pvPotenciaW': 45000.0,
      'pvCorrienteA': 374.0,
      'salidaVoltajeV': 220.0,
      'salidaPotenciaW': 43000.0,
      'salidaCorrienteA': 195.5,
      'salidaAparenteVa': 44000.0,
      'salidaFrecuenciaHz': 60.0,
      'cargaPorcentaje': 65,
      'socPct': 82,
      'redVoltajeV': 221.0,
      'redFrecuenciaHz': 59.9,
      'busVoltajeV': 400.0,
      'temperaturaC': 41.5,
      'eficienciaPct': 92.5,
      'consumoRedW': 1500.0,
      'modoOperacion': 'GRID_TIE',
      'codigoFallo': 7,
      'bateriaCargando': true,
      'pvActivo': true,
      'redActiva': true,
      'crcValido': true,
      'latenciaMs': 35,
      'inversor': {'id': inversorId, 'nombre': inversorNombre},
    };

/// JSON con las 26 columnas de telemetría presentes pero en `null` (el
/// backend sin gateway). Nada debe volverse `0`.
Map<String, dynamic> allNullDatoInversorJson() => <String, dynamic>{
      'id': 1,
      'tiempo': null,
      'inversor': {'id': 1, 'nombre': 'INV-001'},
      for (final key in datoInversorTelemetryKeys) key: null,
    };

/// JSON mínimo: solo lo imprescindible, sin ninguna clave de telemetría.
Map<String, dynamic> minimalDatoInversorJson() => <String, dynamic>{
      'id': 1,
      'tiempo': '2026-06-17T10:00:00Z',
    };

/// JSON completo de `InversorDTO` con todas sus relaciones.
Map<String, dynamic> fullInversorJson() => <String, dynamic>{
      'id': 1,
      'nombre': 'INV-001',
      'numeroSerie': 'SN-001',
      'esMaster': true,
      'tipoConexion': 'TcpModbus',
      'puertoSerial': null,
      'slaveId': 1,
      'activo': true,
      'estadoDispositivo': 'Conectado',
      'ultimaLectura': '2026-06-17T10:00:00Z',
      'ultimoError': null,
      'periodoMuestreoSeg': 10,
      'fechaRegistro': '2026-01-01T00:00:00Z',
      'ultimaConexion': '2026-06-17T09:59:00Z',
      'sitio': {
        'id': 1,
        'nombre': 'Planta Norte',
        'descripcion': 'Planta principal',
        'ubicacion': 'Habana',
        'contacto': 'ana',
        'telefono': '555555',
        'activo': true,
        'fechaInstalacion': '2026-01-01',
      },
      'marca': {
        'id': 1,
        'nombre': 'Felicity',
        'fabricante': 'Felicity Power',
        'registroInicio': 0,
        'registroFin': 99,
        'registroInfoInicio': 0,
        'registroInfoFin': 10,
        'baudRateDefault': 9600,
        'descripcion': null,
        'activaMarcaDefault': true,
      },
      'modelo': {
        'id': 1,
        'nombre': 'A1',
        'capacidadVa': 5000,
        'voltajeSistemaNom': 48,
        'descripcion': null,
        'marca': {'id': 1, 'nombre': 'Felicity'},
      },
      'gateway': {
        'id': 1,
        'nombre': 'GW-1',
        'descripcion': 'Gateway principal',
        'ubicacion': null,
        'direccionIp': '192.168.1.10',
        'puerto': 502,
        'activo': true,
        'estadoConexion': 'Conectado',
        'ultimaLectura': '2026-06-17T10:00:00Z',
        'ultimoError': null,
        'tiempoEsperaMs': 10000,
        'reintentos': 0,
        'sitio': null,
      },
      'masterReferencia': {'id': 9, 'nombre': 'INV-009'},
    };

/// JSON de `InversorDTO` sin relaciones ni metadatos.
Map<String, dynamic> minimalInversorJson() => <String, dynamic>{
      'id': 3,
      'nombre': 'INV-003',
    };
