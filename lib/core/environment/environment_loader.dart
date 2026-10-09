import 'environment_config.dart';
import 'runtime_environment.dart';

class EnvironmentLoader {
  const EnvironmentLoader();

  EnvironmentConfig load({
    RuntimeEnvironment environment = RuntimeEnvironment.development,
  }) {
    return EnvironmentConfig(
      environment: environment,
      apiBaseUrl: _resolveApiBaseUrl(environment),
      applicationName: 'Avia',
    );
  }

  String _resolveApiBaseUrl(RuntimeEnvironment environment) {
    switch (environment) {
      case RuntimeEnvironment.development:
        return 'http://localhost:8000';

      case RuntimeEnvironment.test:
        return 'http://localhost:8000';

      case RuntimeEnvironment.staging:
        return 'https://staging-api.avia.example';

      case RuntimeEnvironment.production:
        return 'https://api.avia.example';
    }
  }
}
