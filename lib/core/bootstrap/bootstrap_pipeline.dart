import 'bootstrap_context.dart';
import 'bootstrap_result.dart';
import 'bootstrap_stage.dart';

class BootstrapPipeline {
  final List<BootstrapStage> stages;

  const BootstrapPipeline({required this.stages});

  Future<BootstrapResult> execute() async {
    final context = BootstrapContext();
    final completedStages = <String>[];

    for (final stage in stages) {
      try {
        await stage.execute(context);
        completedStages.add(stage.name);
      } catch (error) {
        return BootstrapResult(
          success: false,
          completedStages: completedStages,
          failureStage: stage.name,
          error: error,
        );
      }
    }

    return BootstrapResult(success: true, completedStages: completedStages);
  }
}
