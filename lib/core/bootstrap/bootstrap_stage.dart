import 'bootstrap_context.dart';

abstract interface class BootstrapStage {
  String get name;

  Future<void> execute(BootstrapContext context);
}
