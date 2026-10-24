import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/services/authentication/'
    'authenticated_identity.dart';

void main() {
  group('AuthenticatedIdentity', () {
    final validResponse = <String, dynamic>{
      'user_id': 'U001',
      'merchant_id': 'M001',
      'username': 'owner',
      'role': 'OWNER',
      'branch_id': null,
      'active': true,
    };

    test('parses the documented backend response', () {
      final identity = AuthenticatedIdentity.fromMap(validResponse);

      expect(identity.userId, equals('U001'));
      expect(identity.merchantId, equals('M001'));
      expect(identity.username, equals('owner'));
      expect(identity.role, equals('OWNER'));
      expect(identity.branchId, isNull);
      expect(identity.active, isTrue);
    });

    test('supports a non-null branch ID', () {
      final response = <String, dynamic>{...validResponse, 'branch_id': 'B001'};

      final identity = AuthenticatedIdentity.fromMap(response);

      expect(identity.branchId, equals('B001'));
    });

    test('rejects a missing required identity field', () {
      final response = <String, dynamic>{...validResponse}..remove('user_id');

      expect(
        () => AuthenticatedIdentity.fromMap(response),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an empty required identity field', () {
      final response = <String, dynamic>{...validResponse, 'username': ' '};

      expect(
        () => AuthenticatedIdentity.fromMap(response),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a non-string branch ID', () {
      final response = <String, dynamic>{...validResponse, 'branch_id': 123};

      expect(
        () => AuthenticatedIdentity.fromMap(response),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an empty non-null branch ID', () {
      final response = <String, dynamic>{...validResponse, 'branch_id': ' '};

      expect(
        () => AuthenticatedIdentity.fromMap(response),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a non-boolean active field', () {
      final response = <String, dynamic>{...validResponse, 'active': 'true'};

      expect(
        () => AuthenticatedIdentity.fromMap(response),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a missing active field', () {
      final response = <String, dynamic>{...validResponse}..remove('active');

      expect(
        () => AuthenticatedIdentity.fromMap(response),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
