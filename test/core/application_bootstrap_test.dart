import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/core/bootstrap/application_bootstrap.dart';
import 'package:aviapos_mobile/core/bootstrap/bootstrap_context.dart';
import 'package:aviapos_mobile/core/bootstrap/bootstrap_pipeline.dart';
import 'package:aviapos_mobile/core/bootstrap/bootstrap_stage.dart';

class TestBootstrapStage implements BootstrapStage {
  @override
  final String name;

  final List<String> executionLog;

  TestBootstrapStage({required this.name, required this.executionLog});

  @override
  Future<void> execute(BootstrapContext context) async {
    executionLog.add(name);
  }
}

void main() {
  test('application bootstrap runs the configured pipeline', () async {
    final executionLog = <String>[];

    final pipeline = BootstrapPipeline(
      stages: [
        TestBootstrapStage(name: 'environment', executionLog: executionLog),
        TestBootstrapStage(name: 'second_stage', executionLog: executionLog),
      ],
    );

    final applicationBootstrap = ApplicationBootstrap(pipeline: pipeline);

    final result = await applicationBootstrap.run();

    expect(result.success, isTrue);

    expect(executionLog, ['environment', 'second_stage']);

    expect(result.completedStages, ['environment', 'second_stage']);
  });
}
