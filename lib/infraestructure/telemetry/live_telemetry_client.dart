// lib/infraestructure/telemetry/live_telemetry_client.dart

import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:etecsa_supervision/infraestructure/model/dato_inversor_dto.dart';
import 'package:etecsa_supervision/infraestructure/mapper/lectura_inversor_mapper.dart';
import 'package:etecsa_supervision/domain/entities/lectura_inversor.dart';

/// Cliente de telemetria en vivo sobre STOMP/WebSocket.
///
/// Envuelve `stomp_dart_client` para conectarse al endpoint STOMP del
/// backend, suscribirse a `/topic/inversor/{id}/live` y emitir
/// `LecturaInversor` parseadas de cada frame `MESSAGE`.
///
/// El JWT viaja como parametro de consulta `access_token` de la URL
/// WebSocket (Spring lo lee del handshake) y como header STOMP `login` en el
/// frame `CONNECT`. El cliente nunca lanza: los errores de conexion y STOMP
/// se emiten por [onError].
class LiveTelemetryClient {
  LiveTelemetryClient({
    required this.accessToken,
    required this.webSocketUrl,
  });

  /// JWT obtenido de `POST /api/authenticate`.
  final String accessToken;

  /// URL base del endpoint STOMP/WebSocket, sin el parametro de autenticacion.
  /// Ejemplo: `ws://localhost:8080/websocket/tracker/websocket`.
  final String webSocketUrl;

  StompClient? _client;
  StompConfig? _config;

  final Map<int, StreamController<LecturaInversor>> _controllers = {};
  final Map<int, StompUnsubscribe> _subscriptions = {};
  final Set<int> _stompSubscribed = {};

  final StreamController<bool> _connectionState = StreamController<bool>.broadcast();
  final StreamController<Object> _errors = StreamController<Object>.broadcast();

  bool _connected = false;

  /// `true` despues de recibir el frame STOMP `CONNECTED`.
  bool get isConnected => _connected;

  /// Estado de la conexion STOMP (`true` = conectado).
  Stream<bool> get connectionState => _connectionState.stream;

  /// Errores de conexion / STOMP (no lanza: los emite por este stream).
  Stream<Object> get onError => _errors.stream;

  /// Inicia la conexion STOMP pasando el JWT como `access_token` en la URL y
  /// como `login` en el frame CONNECT.
  ///
  /// `activate()` inicia el handshake de forma asincrona; el estado real se
  /// confirma por [connectionState] / [isConnected] una vez llega `CONNECTED`.
  Future<void> connect() async {
    final url = _urlWithToken(webSocketUrl, accessToken);

    _config = StompConfig(
      url: url,
      stompConnectHeaders: <String, String>{
        'login': accessToken,
        'passcode': '',
      },
      heartbeatIncoming: const Duration(seconds: 5),
      heartbeatOutgoing: const Duration(seconds: 5),
      reconnectDelay: Duration.zero,
      onConnect: (frame) {
        _connected = true;
        _connectionState.add(true);
      },
      onDisconnect: (frame) {
        _connected = false;
        _connectionState.add(false);
      },
      onStompError: (frame) {
        _errors.add(Exception('STOMP ERROR ${frame.command}: ${frame.body}'));
      },
      onWebSocketError: (error) {
        _errors.add(error);
      },
    );

    _client = StompClient(config: _config!);
    _client!.activate();
  }

  String _urlWithToken(String url, String token) {
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}access_token=$token';
  }

  /// Suscribe a `/topic/inversor/{inversorId}/live`.
  ///
  /// Cada frame `MESSAGE` se parsea como `DatoInversorDTO` y se mapea a
  /// `LecturaInversor`, que se emite por el stream devuelto y se notifica al
  /// callback [onMessage]. El frame STOMP `SUBSCRIBE` se envia una sola vez
  /// por inversor; las llamadas posteriores reusan el mismo stream.
  Stream<LecturaInversor> subscribe(
    int inversorId,
    void Function(LecturaInversor) onMessage,
  ) {
    final controller = _controllers.putIfAbsent(
      inversorId,
      () => StreamController<LecturaInversor>.broadcast(),
    );

    if (!_stompSubscribed.contains(inversorId)) {
      final destination = '/topic/inversor/$inversorId/live';
      final stompClient = _client;
      if (stompClient != null) {
        _subscriptions[inversorId] = stompClient.subscribe(
          destination: destination,
          callback: (frame) {
            try {
              final body = frame.body;
              if (body == null) return;
              final json = jsonDecode(body) as Map<String, dynamic>;
              final dato = DatoInversorDTO.fromJson(json);
              final lectura = LecturaInversorMapper.fromDto(dato);
              controller.add(lectura);
              onMessage(lectura);
            } catch (error) {
              _errors.add(error);
            }
          },
        );
        _stompSubscribed.add(inversorId);
      }
    }

    return controller.stream;
  }

  /// Cancela la suscripcion a [inversorId] y cierra su stream.
  void unsubscribe(int inversorId) {
    _stompSubscribed.remove(inversorId);
    _subscriptions.remove(inversorId)?.call();
    _controllers.remove(inversorId)?.close();
  }

  /// Cierra todas las suscripciones, los streams y la conexion STOMP.
  Future<void> dispose() async {
    for (final id in _controllers.keys.toList()) {
      unsubscribe(id);
    }
    _client?.deactivate();
    _client = null;
    _config = null;
    _connected = false;
    await _connectionState.close();
    await _errors.close();
  }
}
