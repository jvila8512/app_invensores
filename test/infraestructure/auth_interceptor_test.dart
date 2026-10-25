// test/infraestructure/auth_interceptor_test.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:etecsa_supervision/infraestructure/auth/auth_interceptor.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_holder.dart';
import 'package:etecsa_supervision/infraestructure/auth/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter HTTP minimo: registra el header `Authorization` recibido y
/// responde con el codigo indicado.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.statusCode = 200, this.body = '{"login":"admin"}'});

  final int statusCode;
  final String body;
  final List<String?> authorizationHeaders = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorizationHeaders.add(options.headers['Authorization'] as String?);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _buildDio({
  required TokenHolder holder,
  required TokenStorage storage,
  required _FakeAdapter adapter,
  void Function()? onUnauthorized,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://backend.test'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    AuthInterceptor(
      holder: holder,
      storage: storage,
      onUnauthorized: onUnauthorized,
    ),
  );
  return dio;
}

void main() {
  late TokenHolder holder;
  late InMemoryTokenStorage storage;

  setUp(() {
    holder = TokenHolder();
    storage = InMemoryTokenStorage();
  });

  test('adjunta Authorization: Bearer <jwt> a cada peticion', () async {
    holder.set('jwt-123');
    final adapter = _FakeAdapter();
    final dio = _buildDio(holder: holder, storage: storage, adapter: adapter);

    await dio.get<void>('/api/inversores/all');

    expect(adapter.authorizationHeaders, hasLength(1));
    expect(adapter.authorizationHeaders.single, 'Bearer jwt-123');
  });

  test('sin token no envia el header', () async {
    final adapter = _FakeAdapter();
    final dio = _buildDio(holder: holder, storage: storage, adapter: adapter);

    await dio.get<void>('/api/inversores/all');

    expect(adapter.authorizationHeaders.single, isNull);
  });

  test('401 limpia el holder, borra el storage y avisa la expiracion', () async {
    holder.set('jwt-vencido');
    await storage.write('jwt-vencido');

    var notified = false;
    final adapter = _FakeAdapter(statusCode: 401, body: '{}');
    final dio = _buildDio(
      holder: holder,
      storage: storage,
      adapter: adapter,
      onUnauthorized: () => notified = true,
    );

    await expectLater(
      dio.get<void>('/api/account'),
      throwsA(isA<DioException>()),
    );

    expect(holder.hasToken, isFalse, reason: 'el token en memoria se limpió');
    expect(await storage.read(), isNull, reason: 'el token guardado se borró');
    expect(notified, isTrue, reason: 'la sesión expirada se propagó');
  });

  test('un error que no es 401 no cierra la sesión', () async {
    holder.set('jwt-123');
    await storage.write('jwt-123');

    var notified = false;
    final adapter = _FakeAdapter(statusCode: 500, body: '{}');
    final dio = _buildDio(
      holder: holder,
      storage: storage,
      adapter: adapter,
      onUnauthorized: () => notified = true,
    );

    await expectLater(
      dio.get<void>('/api/account'),
      throwsA(isA<DioException>()),
    );

    expect(holder.hasToken, isTrue);
    expect(await storage.read(), 'jwt-123');
    expect(notified, isFalse);
  });

  test('el cuerpo JSON del adapter decodifica sin errores (sanity)', () async {
    final adapter = _FakeAdapter(body: jsonEncode({'login': 'admin'}));
    final dio = _buildDio(holder: holder, storage: storage, adapter: adapter);

    final response = await dio.get<Map<String, dynamic>>('/api/account');

    expect(response.data?['login'], 'admin');
  });
}
