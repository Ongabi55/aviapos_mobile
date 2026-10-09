import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/core/bootstrap/bootstrap_context.dart';
import 'package:aviapos_mobile/core/bootstrap/stages/environment_bootstrap_stage.dart';
import 'package:aviapos_mobile/core/environment/environment_config.dart';
import 'package:aviapos_mobile/core/environment/environment_loader.dart';
import 'package:aviapos_mobile/core/environment/validation/environment_config_validator.dart';

void main() {
  test(
    'environment bootstrap stage stores validated configuration in context',
    () async {
      final context = BootstrapContext();

      const loader = EnvironmentLoader();
      const validator = EnvironmentConfigValidator();

      const stage = EnvironmentBootstrapStage(
        loader: loader,
        validator: validator,
      );

      await stage.execute(context);

      final config = context.get<EnvironmentConfig>();

      expect(config, isNotNull);
      expect(config!.applicationName, 'Avia');
    },
  );
}
