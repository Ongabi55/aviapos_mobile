import '../networking/api_client.dart';
import '../networking/api_exception.dart';
import 'authentication_credentials.dart';
import 'authentication_token.dart';

/// Coordinates authentication requests with the Avia backend.
///
/// This service does not manage token persistence, application navigation,
/// authorization policies, or authenticated session lifecycle.
class AuthenticationService {
  final ApiClient apiClient;

  const AuthenticationService({required this.apiClient});

  /// Authenticates the supplied credentials and returns the access token.
  ///
  /// Throws [ApiException] when the backend returns an unsuccessful HTTP
  /// response or when the response body violates the authentication contract.
  ///
  /// Transport exceptions are allowed to propagate to the caller.
  Future<AuthenticationToken> login(
    AuthenticationCredentials credentials,
  ) async {
    final response = await apiClient.post(
      '/auth/login',
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: credentials.toMap(),
    );

    if (!response.isSuccess) {
      throw ApiException(
        message: 'Authentication request failed.',
        statusCode: response.statusCode,
      );
    }

    final body = response.body;

    if (body is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'Authentication response must be a JSON object.',
      );
    }

    try {
      return AuthenticationToken.fromMap(body);
    } on FormatException catch (error) {
      throw ApiException(
        message: 'Authentication response does not match the contract.',
        cause: error,
      );
    }
  }
}
