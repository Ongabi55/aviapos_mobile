class AuthenticatedIdentity {
  final String userId;
  final String merchantId;
  final String username;
  final String role;
  final String? branchId;
  final bool active;

  const AuthenticatedIdentity({
    required this.userId,
    required this.merchantId,
    required this.username,
    required this.role,
    required this.branchId,
    required this.active,
  });

  factory AuthenticatedIdentity.fromMap(Map<String, dynamic> map) {
    final userId = _requiredString(map, 'user_id');
    final merchantId = _requiredString(map, 'merchant_id');
    final username = _requiredString(map, 'username');
    final role = _requiredString(map, 'role');

    final branchId = map['branch_id'];
    if (branchId != null && (branchId is! String || branchId.trim().isEmpty)) {
      throw const FormatException(
        'Authenticated identity branch_id must be a non-empty string or null.',
      );
    }

    final active = map['active'];
    if (active is! bool) {
      throw const FormatException(
        'Authenticated identity must contain a boolean active field.',
      );
    }

    return AuthenticatedIdentity(
      userId: userId,
      merchantId: merchantId,
      username: username,
      role: role,
      branchId: branchId as String?,
      active: active,
    );
  }

  static String _requiredString(Map<String, dynamic> map, String field) {
    final value = map[field];

    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
        'Authenticated identity must contain a valid $field field.',
      );
    }

    return value;
  }

  @override
  String toString() {
    return 'AuthenticatedIdentity('
        'userId: $userId, '
        'merchantId: $merchantId, '
        'username: $username, '
        'role: $role, '
        'branchId: $branchId, '
        'active: $active)';
  }
}
