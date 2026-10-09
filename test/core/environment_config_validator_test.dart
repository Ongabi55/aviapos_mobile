import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/core/environment/environment_config.dart';
import 'package:aviapos_mobile/core/environment/environment_loader.dart';
import 'package:aviapos_mobile/core/environment/validation/environment_config_validator.dart';
import 'package:aviapos_mobile/core/environment/runtime_environment.dart';

void main() {
  test('valid environment configuration passes validation', () {
    const loader = EnvironmentLoader();
    const validator = EnvironmentConfigValidator();

    final config = loader.load();

    expect(() => validator.validate(config), returnsNormally);
  });

  test('empty API base URL fails validation', () {
    const validator = EnvironmentConfigValidator();

    const config = EnvironmentConfig(
      environment: RuntimeEnvironment.development,
      apiBaseUrl: '',
      applicationName: 'Avia',
    );

    expect(() => validator.validate(config), throwsA(isA<FormatException>()));
  });

  test('empty application name fails validation', () {
    const validator = EnvironmentConfigValidator();

    const config = EnvironmentConfig(
      environment: RuntimeEnvironment.development,
      apiBaseUrl: 'http://localhost:8000',
      applicationName: '',
    );

    expect(() => validator.validate(config), throwsA(isA<FormatException>()));
  });
}
