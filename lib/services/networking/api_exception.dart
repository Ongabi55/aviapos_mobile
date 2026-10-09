
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const ApiException({required this.message, this.statusCode, this.cause});

  @override
  String toString() {
    if (statusCode == null) {
      return 'ApiException: $message';
    }

    return 'ApiException($statusCode): $message';
  }
}
