import 'http_response.dart';

abstract interface class HttpAdapter {
  Future<HttpResponse> get(
      Uri uri, {
        Map<String, String>? headers,
      });

  Future<HttpResponse> post(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      });

  Future<HttpResponse> put(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      });

  Future<HttpResponse> patch(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      });

  Future<HttpResponse> delete(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      });
}