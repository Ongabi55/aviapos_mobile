import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'authentication_token.dart';
import 'authentication_token_store.dart';

/// Secure implementation of [AuthenticationTokenStore] using [FlutterSecureStorage].
///
/// Stores `access_token` and `token_type` together under a private storage key.
/// Never logs or exposes access token values in diagnostic or exception output.
class SecureAuthenticationTokenStore implements AuthenticationTokenStore {
  static const String _storageKey = 'aviapos.auth.token';

  final FlutterSecureStorage _storage;

  const SecureAuthenticationTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> save(AuthenticationToken token) async {
    final serialized = jsonEncode(token.toMap());
    await _storage.write(key: _storageKey, value: serialized);
  }

  @override
  Future<AuthenticationToken?> read() async {
    final storedValue = await _storage.read(key: _storageKey);

    if (storedValue == null || storedValue.trim().isEmpty) {
      return null;
    }

    Object? decoded;
    try {
      decoded = jsonDecode(storedValue);
    } catch (_) {
      throw const FormatException(
        'Stored authentication token is not valid JSON.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Stored authentication token must be a JSON object.',
      );
    }

    try {
      return AuthenticationToken.fromMap(decoded);
    } on FormatException {
      throw const FormatException(
        'Stored authentication token violates the contract.',
      );
    }
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _storageKey);
  }
}
