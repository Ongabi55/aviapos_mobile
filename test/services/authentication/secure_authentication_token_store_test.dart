import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/services/authentication/authentication_token.dart';
import 'package:aviapos_mobile/services/authentication/secure_authentication_token_store.dart';

class FakeFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};
  bool shouldThrowOnRead = false;
  bool shouldThrowOnWrite = false;
  bool shouldThrowOnDelete = false;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (shouldThrowOnRead) {
      throw Exception('Storage read error');
    }
    return _storage[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (shouldThrowOnWrite) {
      throw Exception('Storage write error');
    }
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (shouldThrowOnDelete) {
      throw Exception('Storage delete error');
    }
    _storage.remove(key);
  }
}

void main() {
  group('SecureAuthenticationTokenStore', () {
    late FakeFlutterSecureStorage fakeStorage;
    late SecureAuthenticationTokenStore tokenStore;

    setUp(() {
      fakeStorage = FakeFlutterSecureStorage();
      tokenStore = SecureAuthenticationTokenStore(storage: fakeStorage);
    });

    test('saves and retrieves an authentication token', () async {
      const token = AuthenticationToken(
        accessToken: 'valid-access-token',
        tokenType: 'bearer',
      );

      await tokenStore.save(token);
      final retrieved = await tokenStore.read();

      expect(retrieved, isNotNull);
      expect(retrieved!.accessToken, equals('valid-access-token'));
      expect(retrieved.tokenType, equals('bearer'));
    });

    test('clears a stored authentication token', () async {
      const token = AuthenticationToken(
        accessToken: 'token-to-clear',
        tokenType: 'bearer',
      );

      await tokenStore.save(token);
      await tokenStore.clear();

      final retrieved = await tokenStore.read();
      expect(retrieved, isNull);
    });

    test('returns null when no token is stored', () async {
      final retrieved = await tokenStore.read();
      expect(retrieved, isNull);
    });

    test('returns null when stored value is empty or whitespace', () async {
      await fakeStorage.write(key: 'aviapos.auth.token', value: '   ');

      final retrieved = await tokenStore.read();
      expect(retrieved, isNull);
    });

    test('rejects stored value that is not valid JSON', () async {
      await fakeStorage.write(
        key: 'aviapos.auth.token',
        value: 'not-valid-json',
      );

      expect(
        () => tokenStore.read(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('not valid JSON'),
          ),
        ),
      );
    });

    test(
      'rejects stored value that is a JSON array instead of object',
      () async {
        await fakeStorage.write(
          key: 'aviapos.auth.token',
          value: '["access_token", "bearer"]',
        );

        expect(
          () => tokenStore.read(),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('must be a JSON object'),
            ),
          ),
        );
      },
    );

    test('rejects stored JSON object missing required access_token', () async {
      await fakeStorage.write(
        key: 'aviapos.auth.token',
        value: '{"token_type": "bearer"}',
      );

      expect(
        () => tokenStore.read(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('violates the contract'),
          ),
        ),
      );
    });

    test('rejects stored JSON object with empty access_token', () async {
      await fakeStorage.write(
        key: 'aviapos.auth.token',
        value: '{"access_token": "", "token_type": "bearer"}',
      );

      expect(
        () => tokenStore.read(),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('violates the contract'),
          ),
        ),
      );
    });

    test('propagates storage read failures', () async {
      fakeStorage.shouldThrowOnRead = true;

      expect(
        () => tokenStore.read(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString()',
            contains('Storage read error'),
          ),
        ),
      );
    });

    test('propagates storage write failures', () async {
      fakeStorage.shouldThrowOnWrite = true;
      const token = AuthenticationToken(
        accessToken: 'token',
        tokenType: 'bearer',
      );

      expect(
        () => tokenStore.save(token),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString()',
            contains('Storage write error'),
          ),
        ),
      );
    });

    test('propagates storage delete failures', () async {
      fakeStorage.shouldThrowOnDelete = true;

      expect(
        () => tokenStore.clear(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString()',
            contains('Storage delete error'),
          ),
        ),
      );
    });

    test('does not expose access token secrets in Exception output', () async {
      const secretTokenValue = 'super-secret-access-token-12345';
      await fakeStorage.write(
        key: 'aviapos.auth.token',
        value: '{"access_token": "$secretTokenValue"}',
      );

      try {
        await tokenStore.read();
        fail('Expected FormatException was not thrown');
      } on FormatException catch (exception) {
        expect(exception.toString(), isNot(contains(secretTokenValue)));
      }
    });
  });
}
