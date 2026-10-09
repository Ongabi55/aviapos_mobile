import '../environment_config.dart';

class EnvironmentConfigValidator {
  const EnvironmentConfigValidator();

  void validate(EnvironmentConfig config) {
    if (config.applicationName.trim().isEmpty) {
      throw const FormatException('Application name must not be empty.');
    }

    final uri = Uri.tryParse(config.apiBaseUrl);

    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw FormatException('API base URL is invalid: ${config.apiBaseUrl}');
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw FormatException(
        'API base URL must use HTTP or HTTPS: ${config.apiBaseUrl}',
      );
    }
  }
}
