import 'bootstrap_pipeline.dart';
import 'bootstrap_result.dart';

class ApplicationBootstrap {
  final BootstrapPipeline pipeline;

  const ApplicationBootstrap({required this.pipeline});

  Future<BootstrapResult> run() {
    return pipeline.execute();
  }
}
