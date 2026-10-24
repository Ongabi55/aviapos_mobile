import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/services/authentication/authentication_token.dart';
import 'package:aviapos_mobile/services/authentication/authentication_token_store.dart';
import 'package:aviapos_mobile/services/networking/api_client.dart';
import 'package:aviapos_mobile/services/networking/api_exception.dart';
import 'package:aviapos_mobile/services/networking/authenticated_api_client.dart';
import 'package:aviapos_mobile/services/networking/http_adapter.dart';
import 'package:aviapos_mobile/services/networking/http_response.dart';

class FakeAuthenticationTokenStore implements AuthenticationTokenStore {
  AuthenticationToken? token;
  Object? readError;

  int readCount = 0;

  FakeAuthenticationTokenStore({this.token, this.readError});

  @override
  Future<void> save(AuthenticationToken token) async {
    this.token = token;
  }

  @override
  Future<AuthenticationToken?> read() async {
    readCount++;

    if (readError != null) {
      throw readError!;
    }

    return token;
  }

  @override
  Future<void> clear() async {
    token = null;
  }
}

class RecordingHttpAdapter implements HttpAdapter {
  String? lastMethod;
  Uri? lastUri;
  Map<String, String>? lastHeaders;
  Object? lastBody;
  int requestCount = 0;

  final response = const HttpResponse(
    statusCode: 200,
    body: <String, dynamic>{'success': true},
  );

  void _record(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    requestCount++;
    lastMethod = method;
    lastUri = uri;
    lastHeaders = headers;
    lastBody = body;
  }

  @override
  Future<HttpResponse> get(Uri uri, {Map<String, String>? headers}) async {
    _record('GET', uri, headers: headers);
    return response;
  }

  @override
  Future<HttpResponse> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    _record('POST', uri, headers: headers, body: body);
    return response;
  }

  @override
  Future<HttpResponse> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    _record('PUT', uri, headers: headers, body: body);
    return response;
  }

  @override
  Future<HttpResponse> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    _record('PATCH', uri, headers: headers, body: body);
    return response;
  }

  @override
  Future<HttpResponse> delete(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    _record('DELETE', uri, headers: headers, body: body);
    return response;
  }
}

void main() {
  late RecordingHttpAdapter adapter;
  late FakeAuthenticationTokenStore tokenStore;
  late AuthenticatedApiClient client;

  const token = AuthenticationToken(
    accessToken: 'test-access-token',
    tokenType: 'Bearer',
  );

  setUp(() {
    adapter = RecordingHttpAdapter();

    tokenStore = FakeAuthenticationTokenStore(token: token);

    client = AuthenticatedApiClient(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://example.com'),
        adapter: adapter,
      ),
      tokenStore: tokenStore,
    );
  });

  group('AuthenticatedApiClient', () {
    test('adds the stored token to the Authorization header', () async {
      await client.get('/protected');

      expect(
        adapter.lastHeaders?['Authorization'],
        equals('Bearer test-access-token'),
      );

      expect(adapter.requestCount, equals(1));
      expect(tokenStore.readCount, equals(1));
    });

    test('uses the token type returned by the backend', () async {
      tokenStore.token = const AuthenticationToken(
        accessToken: 'another-token',
        tokenType: 'Bearer',
      );

      await client.get('/protected');

      expect(
        adapter.lastHeaders?['Authorization'],
        equals('Bearer another-token'),
      );
    });

    test('rejects requests when no token is stored', () async {
      tokenStore.token = null;

      await expectLater(client.get('/protected'), throwsA(isA<ApiException>()));

      expect(adapter.requestCount, equals(0));
    });

    test('does not send a request when token storage fails', () async {
      tokenStore.readError = Exception('Storage unavailable');

      await expectLater(client.get('/protected'), throwsA(isA<ApiException>()));

      expect(adapter.requestCount, equals(0));
    });

    test('does not allow a caller to override Authorization', () async {
      await client.get(
        '/protected',
        headers: const {
          'authorization': 'Bearer caller-supplied-token',
          'Accept': 'application/json',
        },
      );

      expect(
        adapter.lastHeaders?['Authorization'],
        equals('Bearer test-access-token'),
      );

      expect(adapter.lastHeaders?.containsKey('authorization'), isFalse);

      expect(adapter.lastHeaders?['Accept'], equals('application/json'));
    });

    test('preserves custom headers and idempotency keys', () async {
      await client.post(
        '/payments',
        headers: const {
          'Content-Type': 'application/json',
          'X-Request-Source': 'aviapos-mobile',
        },
        body: const {'amount_minor': 1500},
        idempotencyKey: 'payment-request-123',
      );

      expect(
        adapter.lastHeaders?['Authorization'],
        equals('Bearer test-access-token'),
      );

      expect(adapter.lastHeaders?['Content-Type'], equals('application/json'));

      expect(
        adapter.lastHeaders?['X-Request-Source'],
        equals('aviapos-mobile'),
      );

      expect(
        adapter.lastHeaders?['Idempotency-Key'],
        equals('payment-request-123'),
      );

      expect(adapter.lastBody, equals({'amount_minor': 1500}));
    });

    test('supports all five HTTP methods', () async {
      await client.get('/resource');
      expect(adapter.lastMethod, equals('GET'));

      await client.post('/resource', body: const {'value': 1});
      expect(adapter.lastMethod, equals('POST'));

      await client.put('/resource', body: const {'value': 2});
      expect(adapter.lastMethod, equals('PUT'));

      await client.patch('/resource', body: const {'value': 3});
      expect(adapter.lastMethod, equals('PATCH'));

      await client.delete('/resource');
      expect(adapter.lastMethod, equals('DELETE'));

      expect(adapter.requestCount, equals(5));
      expect(tokenStore.readCount, equals(5));
    });

    test('resolves the request URI through ApiClient', () async {
      await client.get('/protected');

      expect(
        adapter.lastUri,
        equals(Uri.parse('https://example.com/protected')),
      );
    });

    test('reads the token again for each request', () async {
      await client.get('/first');

      tokenStore.token = const AuthenticationToken(
        accessToken: 'refreshed-token',
        tokenType: 'Bearer',
      );

      await client.get('/second');

      expect(
        adapter.lastHeaders?['Authorization'],
        equals('Bearer refreshed-token'),
      );

      expect(tokenStore.readCount, equals(2));
    });
  });
}
