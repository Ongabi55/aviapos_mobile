import 'runtime_environment.dart';

class EnvironmentConfig {
  final RuntimeEnvironment environment;
  final String apiBaseUrl;
  final String applicationName;

  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.applicationName,
  });
}
