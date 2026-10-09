import 'http_adapter.dart';
import 'http_response.dart';

class ApiClient {
  final Uri baseUri;
  final HttpAdapter adapter;

  const ApiClient({required this.baseUri, required this.adapter});

  Future<HttpResponse> get(String path, {Map<String, String>? headers}) {
    return adapter.get(_buildUri(path), headers: headers);
  }

  Future<HttpResponse> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? idempotencyKey,
  }) {
    return adapter.post(
      _buildUri(path),
      headers: _mergeHeaders(headers, idempotencyKey: idempotencyKey),
      body: body,
    );
  }

  Future<HttpResponse> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? idempotencyKey,
  }) {
    return adapter.put(
      _buildUri(path),
      headers: _mergeHeaders(headers, idempotencyKey: idempotencyKey),
      body: body,
    );
  }

  Future<HttpResponse> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? idempotencyKey,
  }) {
    return adapter.patch(
      _buildUri(path),
      headers: _mergeHeaders(headers, idempotencyKey: idempotencyKey),
      body: body,
    );
  }

  Future<HttpResponse> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    String? idempotencyKey,
  }) {
    return adapter.delete(
      _buildUri(path),
      headers: _mergeHeaders(headers, idempotencyKey: idempotencyKey),
      body: body,
    );
  }

  Uri _buildUri(String path) {
    return baseUri.resolve(path);
  }

  Map<String, String>? _mergeHeaders(
    Map<String, String>? headers, {
    String? idempotencyKey,
  }) {
    final merged = <String, String>{...?headers};

    if (idempotencyKey != null) {
      merged['Idempotency-Key'] = idempotencyKey;
    }

    return merged.isEmpty ? null : merged;
  }
}
