import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:aviapos_mobile/services/networking/package_http_adapter.dart';

void main() {
  group('PackageHttpAdapter', () {
    test('supports all five HTTP methods', () async {
      final observedRequests = <http.Request>[];

      final adapter = PackageHttpAdapter(
        client: MockClient((request) async {
          observedRequests.add(request);
          return http.Response('{}', 200);
        }),
      );

      final uri = Uri.https('api.example.test', '/resource');

      await adapter.get(uri);
      await adapter.post(uri, body: {'value': 1});
      await adapter.put(uri, body: {'value': 2});
      await adapter.patch(uri, body: {'value': 3});
      await adapter.delete(uri, body: {'value': 4});

      expect(observedRequests.map((request) => request.method).toList(), [
        'GET',
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      ]);

      expect(observedRequests.every((request) => request.url == uri), isTrue);

      adapter.close();
    });

    test('serializes structured request bodies as JSON', () async {
      http.Request? observedRequest;

      final adapter = PackageHttpAdapter(
        client: MockClient((request) async {
          observedRequest = request;
          return http.Response('{}', 200);
        }),
      );

      await adapter.post(
        Uri.https('api.example.test', '/auth/login'),
        body: {
          'merchant_id': 'merchant-001',
          'username': 'test-user',
          'password': 'test-password',
        },
      );

      expect(observedRequest!.headers['content-type'], 'application/json');

      expect(
        observedRequest!.body,
        '{"merchant_id":"merchant-001",'
        '"username":"test-user",'
        '"password":"test-password"}',
      );

      adapter.close();
    });

    test('preserves a caller-provided Content-Type header', () async {
      http.Request? observedRequest;

      final adapter = PackageHttpAdapter(
        client: MockClient((request) async {
          observedRequest = request;
          return http.Response('{}', 200);
        }),
      );

      await adapter.post(
        Uri.https('api.example.test', '/resource'),
        headers: {'Content-Type': 'application/vnd.avia+json'},
        body: {'value': 1},
      );

      expect(
        observedRequest!.headers['content-type'],
        'application/vnd.avia+json',
      );

      adapter.close();
    });

    test('preserves string request bodies', () async {
      http.Request? observedRequest;

      final adapter = PackageHttpAdapter(
        client: MockClient((request) async {
          observedRequest = request;
          return http.Response('{}', 200);
        }),
      );

      await adapter.post(
        Uri.https('api.example.test', '/resource'),
        body: '{"value":1}',
      );

      expect(observedRequest!.body, '{"value":1}');

      adapter.close();
    });

    test('decodes JSON response bodies', () async {
      final adapter = PackageHttpAdapter(
        client: MockClient((request) async {
          return http.Response(
            '{"authenticated":true,"count":2}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final response = await adapter.get(
        Uri.https('api.example.test', '/resource'),
      );

      expect(response.statusCode, 200);
      expect(response.body, {'authenticated': true, 'count': 2});

      adapter.close();
    });

    test('preserves non-JSON response bodies as text', () async {
      final adapter = PackageHttpAdapter(
        client: MockClient((request) async {
          return http.Response('Service unavailable', 503);
        }),
      );

      final response = await adapter.get(
        Uri.https('api.example.test', '/resource'),
      );

      expect(response.statusCode, 503);
      expect(response.body, 'Service unavailable');

      adapter.close();
    });

    test('represents an empty response body as null', () async {
      final adapter = PackageHttpAdapter(
        client: MockClient((request) async {
          return http.Response('', 204);
        }),
      );

      final response = await adapter.get(
        Uri.https('api.example.test', '/resource'),
      );

      expect(response.statusCode, 204);
      expect(response.body, isNull);

      adapter.close();
    });

    test('allows transport exceptions to propagate', () async {
      final adapter = PackageHttpAdapter(
        client: MockClient((request) async {
          throw Exception('Simulated transport failure');
        }),
      );

      expect(
        () => adapter.get(Uri.https('api.example.test', '/resource')),
        throwsA(isA<Exception>()),
      );

      adapter.close();
    });
  });
}
