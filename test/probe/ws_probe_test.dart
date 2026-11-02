// test/probe/ws_probe_test.dart

import 'package:dio/dio.dart';
import 'package:etecsa_supervision/infraestructure/telemetry/live_telemetry_client.dart';
import 'package:flutter_test/flutter_test.dart';

const String _authUrl = 'http://localhost:8080/api/authenticate';
const String _wsUrl = 'ws://localhost:8080/websocket/tracker/websocket';
const int _inversorId = 1;

/// Autentica contra el backend real y devuelve el JWT.
Future<String> _authenticate() async {
  final dio = Dio();
  final response = await dio.post(
    _authUrl,
    data: <String, String>{
      'username': 'admin',
      'password': 'admin',
    },
  );
  final data = response.data;
  if (data is! Map<String, dynamic>) {
    throw Exception('Respuesta de autenticacion inesperada: $data');
  }
  final token = data['id_token'] as String?;
  if (token == null || token.isEmpty) {
    throw Exception('El backend no devolvio id_token');
  }
  return token;
}

void main() {
  test(
    'WS probe: STOMP sobre WebSocket conecta y suscribe al topic live',
    () async {
      final token = await _authenticate();
      expect(token, isNotEmpty);

      final client = LiveTelemetryClient(
        accessToken: token,
        webSocketUrl: _wsUrl,
      );

      var connected = false;
      final clientErrors = <Object>[];

      client.connectionState.listen((state) => connected = state);
      client.onError.listen((error) => clientErrors.add(error));

      // Inicia el handshake (no espera: el estado se observa por connectionState).
      await client.connect();

      // Espera a CONNECTED hasta 20 s.
      final stopwatch = Stopwatch()..start();
      while (!connected && stopwatch.elapsedMilliseconds < 20000) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      // Si esta conectado, suscribe al topic live del inversor 1. El envio del
      // frame STOMP SUBSCRIBE es la confirmacion de suscripcion.
      if (connected) {
        client.subscribe(_inversorId, (reading) {});
      }

      if (clientErrors.isNotEmpty) {
        // ignore: avoid_print
        print('ERRORES STOMP: $clientErrors');
      }
      if (connected) {
        // ignore: avoid_print
        print('PASS: transporte STOMP/WebSocket operativo.');
      } else {
        // ignore: avoid_print
        print('FAIL: no se establecio la conexion STOMP en 20 s.');
      }

      await client.dispose();

      expect(connected, isTrue, reason: 'STOMP CONNECTED no recibo en 20 s');
    },
    tags: ['probe'],
    timeout: Timeout(Duration(seconds: 30)),
  );
}
