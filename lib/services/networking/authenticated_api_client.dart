import '../authentication/authentication_token_store.dart';
import '../authentication/authentication_token.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'http_response.dart';

/// Sends authenticated requests through the existing ApiClient.
///
/// Reads the stored token for each request and fails closed if the token
/// cannot be retrieved. It does not manage login, logout, token persistence,
/// authorization policies, or merchant context.
class AuthenticatedApiClient {
  final ApiClient apiClient;
  final AuthenticationTokenStore tokenStore;

  const AuthenticatedApiClient({
    required this.apiClient,
    required this.tokenStore,
  });

  Future<HttpResponse> get(String path, {Map<String, String>? headers}) async {
    final authorizedHeaders = await _authorizedHeaders(headers);

    return apiClient.get(path, headers: authorizedHeaders);
  }

  Future<HttpResponse> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? idempotencyKey,
  }) async {
    final authorizedHeaders = await _authorizedHeaders(headers);

    return apiClient.post(
      path,
      headers: authorizedHeaders,
      body: body,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<HttpResponse> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? idempotencyKey,
  }) async {
    final authorizedHeaders = await _authorizedHeaders(headers);

    return apiClient.put(
      path,
      headers: authorizedHeaders,
      body: body,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<HttpResponse> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? idempotencyKey,
  }) async {
    final authorizedHeaders = await _authorizedHeaders(headers);

    return apiClient.patch(
      path,
      headers: authorizedHeaders,
      body: body,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<HttpResponse> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? idempotencyKey,
  }) async {
    final authorizedHeaders = await _authorizedHeaders(headers);

    return apiClient.delete(
      path,
      headers: authorizedHeaders,
      body: body,
      idempotencyKey: idempotencyKey,
    );
  }

  Future<Map<String, String>> _authorizedHeaders(
    Map<String, String>? headers,
  ) async {
    final AuthenticationToken? token;

    try {
      token = await tokenStore.read();
    } catch (error) {
      throw ApiException(
        message: 'Unable to retrieve the authentication token.',
        cause: error,
      );
    }

    if (token == null) {
      throw const ApiException(
        message: 'An authentication token is required for this request.',
      );
    }

    final mergedHeaders = <String, String>{};

    // Prevent a caller-provided Authorization header from overriding
    // the token retrieved from secure storage.
    headers?.forEach((key, value) {
      if (key.toLowerCase() != 'authorization') {
        mergedHeaders[key] = value;
      }
    });

    mergedHeaders['Authorization'] = '${token.tokenType} ${token.accessToken}';

    return mergedHeaders;
  }
}
