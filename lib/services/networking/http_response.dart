/// A transport-level HTTP response.
///
/// This class is transport-agnostic and forms the boundary between
/// the networking layer and the rest of the platform.
///
/// Higher layers should never depend on concrete HTTP libraries.
class HttpResponse {
  /// HTTP status code.
  final int statusCode;

  /// Response headers.
  final Map<String, String> headers;

  /// Raw response body.
  final Object? body;

  const HttpResponse({
    required this.statusCode,
    this.headers = const {},
    this.body,
  });

  /// True if the request completed successfully.
  bool get isSuccess =>
      statusCode >= 200 && statusCode < 300;
}