import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/core/environment/environment_config.dart';
import 'package:aviapos_mobile/core/environment/environment_loader.dart';
import 'package:aviapos_mobile/core/environment/validation/environment_config_validator.dart';
import 'package:aviapos_mobile/core/environment/runtime_environment.dart';

void main() {
  const validator = EnvironmentConfigValidator();

  EnvironmentConfig config({
    required RuntimeEnvironment environment,
    required String apiBaseUrl,
    String applicationName = 'Avia',
  }) {
    return EnvironmentConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      applicationName: applicationName,
    );
  }

  test('valid environment configuration passes validation', () {
    const loader = EnvironmentLoader();

    expect(() => validator.validate(loader.load()), returnsNormally);
  });

  test('empty API base URL fails validation', () {
    expect(
      () => validator.validate(
        config(environment: RuntimeEnvironment.development, apiBaseUrl: ''),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('empty application name fails validation', () {
    expect(
      () => validator.validate(
        config(
          environment: RuntimeEnvironment.development,
          apiBaseUrl: 'http://localhost:8000',
          applicationName: '',
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('development permits HTTP', () {
    expect(
      () => validator.validate(
        config(
          environment: RuntimeEnvironment.development,
          apiBaseUrl: 'http://localhost:8000',
        ),
      ),
      returnsNormally,
    );
  });

  test('test environment permits HTTP', () {
    expect(
      () => validator.validate(
        config(
          environment: RuntimeEnvironment.test,
          apiBaseUrl: 'http://localhost:8000',
        ),
      ),
      returnsNormally,
    );
  });

  test('staging rejects HTTP', () {
    expect(
      () => validator.validate(
        config(
          environment: RuntimeEnvironment.staging,
          apiBaseUrl: 'http://staging.example.com',
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('production rejects HTTP', () {
    expect(
      () => validator.validate(
        config(
          environment: RuntimeEnvironment.production,
          apiBaseUrl: 'http://api.example.com',
        ),
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('staging accepts HTTPS', () {
    expect(
      () => validator.validate(
        config(
          environment: RuntimeEnvironment.staging,
          apiBaseUrl: 'https://staging.example.com',
        ),
      ),
      returnsNormally,
    );
  });

  test('production accepts HTTPS', () {
    expect(
      () => validator.validate(
        config(
          environment: RuntimeEnvironment.production,
          apiBaseUrl: 'https://api.example.com',
        ),
      ),
      returnsNormally,
    );
  });
}
