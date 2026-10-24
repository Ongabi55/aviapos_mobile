import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/services/authentication/'
    'authentication_credentials.dart';

void main() {
  group('AuthenticationCredentials', () {
    test('stores the supplied login credentials', () {
      const credentials = AuthenticationCredentials(
        merchantId: 'M001',
        username: 'owner',
        password: 'example-password',
      );

      expect(credentials.merchantId, equals('M001'));
      expect(credentials.username, equals('owner'));
      expect(credentials.password, equals('example-password'));
    });

    test('maps fields to the backend login contract', () {
      const credentials = AuthenticationCredentials(
        merchantId: 'M001',
        username: 'owner',
        password: 'example-password',
      );

      expect(
        credentials.toMap(),
        equals({
          'merchant_id': 'M001',
          'username': 'owner',
          'password': 'example-password',
        }),
      );
    });

    test('does not expose the password in diagnostic output', () {
      const credentials = AuthenticationCredentials(
        merchantId: 'M001',
        username: 'owner',
        password: 'example-password',
      );

      expect(credentials.toString(), isNot(contains('example-password')));

      expect(credentials.toString(), contains('[REDACTED]'));
    });
  });
}
