import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/services/authentication/'
    'authentication_token.dart';

void main() {
  group('AuthenticationToken', () {
    test('parses the backend login response', () {
      final token = AuthenticationToken.fromMap({
        'access_token': 'test-access-token',
        'token_type': 'bearer',
      });

      expect(token.accessToken, equals('test-access-token'));
      expect(token.tokenType, equals('bearer'));
    });

    test('rejects a missing access token', () {
      expect(
        () => AuthenticationToken.fromMap({'token_type': 'bearer'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an empty access token', () {
      expect(
        () => AuthenticationToken.fromMap({
          'access_token': '   ',
          'token_type': 'bearer',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a missing token type', () {
      expect(
        () =>
            AuthenticationToken.fromMap({'access_token': 'test-access-token'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an empty token type', () {
      expect(
        () => AuthenticationToken.fromMap({
          'access_token': 'test-access-token',
          'token_type': '',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('does not expose the access token in diagnostic output', () {
      final token = AuthenticationToken.fromMap({
        'access_token': 'secret-access-token',
        'token_type': 'bearer',
      });

      expect(token.toString(), isNot(contains('secret-access-token')));

      expect(token.toString(), contains('[REDACTED]'));
    });
  });
}
