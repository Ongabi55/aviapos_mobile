class AuthenticationCredentials {
  final String merchantId;
  final String username;
  final String password;

  const AuthenticationCredentials({
    required this.merchantId,
    required this.username,
    required this.password,
  });

  Map<String, String> toMap() {
    return {
      'merchant_id': merchantId,
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'AuthenticationCredentials('
        'merchantId: $merchantId, '
        'username: $username, '
        'password: [REDACTED])';
  }
}
