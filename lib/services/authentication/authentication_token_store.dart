import 'authentication_token.dart';

/// Abstract contract for persisting, reading, and clearing the authentication token.
abstract interface class AuthenticationTokenStore {
  /// Persists the supplied [token] securely.
  Future<void> save(AuthenticationToken token);

  /// Retrieves the stored token, or `null` if no token exists in storage.
  ///
  /// Throws [FormatException] if the stored data is malformed or invalid.
  Future<AuthenticationToken?> read();

  /// Removes any stored token.
  Future<void> clear();
}
