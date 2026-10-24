class AuthenticationToken {
  final String accessToken;
  final String tokenType;

  const AuthenticationToken({
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthenticationToken.fromMap(Map<String, dynamic> map) {
    final accessToken = map['access_token'];
    final tokenType = map['token_type'];

    if (accessToken is! String || accessToken.trim().isEmpty) {
      throw const FormatException(
        'Authentication response must contain a valid access_token.',
      );
    }

    if (tokenType is! String || tokenType.trim().isEmpty) {
      throw const FormatException(
        'Authentication response must contain a valid token_type.',
      );
    }

    return AuthenticationToken(accessToken: accessToken, tokenType: tokenType);
  }

  Map<String, dynamic> toMap() {
    return {'access_token': accessToken, 'token_type': tokenType};
  }

  @override
  String toString() {
    return 'AuthenticationToken('
        'accessToken: [REDACTED], '
        'tokenType: $tokenType)';
  }
}
