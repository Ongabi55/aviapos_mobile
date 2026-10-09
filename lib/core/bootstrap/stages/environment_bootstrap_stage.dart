import '../bootstrap_context.dart';
import '../bootstrap_stage.dart';
import '../../environment/environment_config.dart';
import '../../environment/environment_loader.dart';
import '../../environment/validation/environment_config_validator.dart';

class EnvironmentBootstrapStage implements BootstrapStage {
  final EnvironmentLoader loader;
  final EnvironmentConfigValidator validator;

  const EnvironmentBootstrapStage({
    required this.loader,
    required this.validator,
  });

  @override
  String get name => 'environment';

  @override
  Future<void> execute(BootstrapContext context) async {
    final config = loader.load();

    validator.validate(config);

    context.put<EnvironmentConfig>(config);
  }
}
