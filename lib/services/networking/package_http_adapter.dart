import 'dart:convert';

import 'package:http/http.dart' as http;

import 'http_adapter.dart';
import 'http_response.dart';

/// Production HTTP transport backed by package:http.
///
/// Keeps concrete HTTP transport details behind the HttpAdapter contract.
/// Structured request bodies are serialized as JSON, and JSON responses
/// are decoded before being returned to higher layers.
class PackageHttpAdapter implements HttpAdapter {
  final http.Client _client;

  PackageHttpAdapter({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<HttpResponse> get(Uri uri, {Map<String, String>? headers}) {
    return _send('GET', uri, headers: headers);
  }

  @override
  Future<HttpResponse> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send('POST', uri, headers: headers, body: body);
  }

  @override
  Future<HttpResponse> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send('PUT', uri, headers: headers, body: body);
  }

  @override
  Future<HttpResponse> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send('PATCH', uri, headers: headers, body: body);
  }

  @override
  Future<HttpResponse> delete(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send('DELETE', uri, headers: headers, body: body);
  }

  Future<HttpResponse> _send(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final request = http.Request(method, uri);

    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (body != null) {
      final hasContentType =
          headers?.keys.any((key) => key.toLowerCase() == 'content-type') ??
          false;

      if (body is String) {
        request.body = body;
      } else {
        request.body = jsonEncode(body);

        if (!hasContentType) {
          request.headers['Content-Type'] = 'application/json';
        }
      }
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    final responseText = utf8.decode(response.bodyBytes);
    Object? responseBody;

    if (responseText.isEmpty) {
      responseBody = null;
    } else {
      try {
        responseBody = jsonDecode(responseText);
      } on FormatException {
        // Preserve non-JSON response bodies for the API layer to handle.
        responseBody = responseText;
      }
    }

    return HttpResponse(
      statusCode: response.statusCode,
      headers: response.headers,
      body: responseBody,
    );
  }

  /// Releases resources held by the underlying HTTP client.
  ///
  /// The owner of this adapter should call close() when the adapter
  /// is no longer needed.
  void close() {
    _client.close();
  }
}
