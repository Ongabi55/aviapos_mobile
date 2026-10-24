import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/services/authentication/authentication_credentials.dart';
import 'package:aviapos_mobile/services/authentication/authentication_service.dart';
import 'package:aviapos_mobile/services/networking/api_client.dart';
import 'package:aviapos_mobile/services/networking/api_exception.dart';
import 'package:aviapos_mobile/services/networking/http_adapter.dart';
import 'package:aviapos_mobile/services/networking/http_response.dart';

class FakeAuthenticationAdapter implements HttpAdapter {
  HttpResponse response = const HttpResponse(
    statusCode: 200,
    body: {'access_token': 'test-token', 'token_type': 'bearer'},
  );

  Uri? lastUri;
  Object? lastBody;
  Map<String, String>? lastHeaders;

  @override
  Future<HttpResponse> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    lastUri = uri;
    lastBody = body;
    lastHeaders = headers;

    return response;
  }

  @override
  Future<HttpResponse> get(Uri uri, {Map<String, String>? headers}) async {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse> delete(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeAuthenticationAdapter adapter;
  late AuthenticationService service;

  const credentials = AuthenticationCredentials(
    merchantId: 'M001',
    username: 'owner',
    password: 'password123',
  );

  setUp(() {
    adapter = FakeAuthenticationAdapter();

    service = AuthenticationService(
      apiClient: ApiClient(
        baseUri: Uri.parse('https://example.com'),
        adapter: adapter,
      ),
    );
  });

  test('login sends the expected request and returns the token', () async {
    final token = await service.login(credentials);

    expect(adapter.lastUri, Uri.parse('https://example.com/auth/login'));

    expect(adapter.lastBody, {
      'merchant_id': 'M001',
      'username': 'owner',
      'password': 'password123',
    });

    expect(adapter.lastHeaders?['Content-Type'], 'application/json');

    expect(adapter.lastHeaders?['Accept'], 'application/json');

    expect(token.accessToken, 'test-token');
    expect(token.tokenType, 'bearer');
  });

  test('login rejects unsuccessful HTTP responses', () async {
    adapter.response = const HttpResponse(
      statusCode: 401,
      body: {'detail': 'Invalid credentials'},
    );

    await expectLater(
      service.login(credentials),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });

  test('login rejects a non-map response body', () async {
    adapter.response = const HttpResponse(
      statusCode: 200,
      body: 'not a JSON object',
    );

    await expectLater(service.login(credentials), throwsA(isA<ApiException>()));
  });

  test('login rejects a malformed token response', () async {
    adapter.response = const HttpResponse(
      statusCode: 200,
      body: {'token_type': 'bearer'},
    );

    await expectLater(service.login(credentials), throwsA(isA<ApiException>()));
  });

  test('login rejects an empty access token', () async {
    adapter.response = const HttpResponse(
      statusCode: 200,
      body: {'access_token': ' ', 'token_type': 'bearer'},
    );

    await expectLater(service.login(credentials), throwsA(isA<ApiException>()));
  });
}
