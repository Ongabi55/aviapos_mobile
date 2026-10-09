import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/services/networking/api_client.dart';
import 'package:aviapos_mobile/services/networking/http_adapter.dart';
import 'package:aviapos_mobile/services/networking/http_response.dart';

class FakeHttpAdapter implements HttpAdapter {
  Map<String, String>? lastHeaders;

  @override
  Future<HttpResponse> get(
      Uri uri, {
        Map<String, String>? headers,
      }) async {
    lastHeaders = headers;

    return const HttpResponse(
      statusCode: 200,
      body: {},
    );
  }

  @override
  Future<HttpResponse> post(
      Uri uri, {
        Object? body,
        Map<String, String>? headers,
      }) async {
    lastHeaders = headers;

    return const HttpResponse(
      statusCode: 200,
      body: {},
    );
  }

  @override
  Future<HttpResponse> put(
      Uri uri, {
        Object? body,
        Map<String, String>? headers,
      }) async {
    return const HttpResponse(
      statusCode: 200,
      body: {},
    );
  }

  @override
  Future<HttpResponse> patch(
      Uri uri, {
        Object? body,
        Map<String, String>? headers,
      }) async {
    return const HttpResponse(
      statusCode: 200,
      body: {},
    );
  }

  @override
  Future<HttpResponse> delete(
      Uri uri, {
        Object? body,
        Map<String, String>? headers,
      }) async {
    return const HttpResponse(
      statusCode: 200,
      body: {},
    );
  }
}

void main() {
  test('ApiClient forwards idempotency key to transport adapter', () async {
    final adapter = FakeHttpAdapter();

    final client = ApiClient(
      baseUri: Uri.parse('https://example.com'),
      adapter: adapter,
    );

    await client.post(
      '/payments',
      idempotencyKey: 'request-123',
    );

    expect(
      adapter.lastHeaders?['Idempotency-Key'],
      equals('request-123'),
    );
  });
}