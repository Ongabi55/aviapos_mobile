import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/core/bootstrap/bootstrap_context.dart';
import 'package:aviapos_mobile/core/bootstrap/bootstrap_pipeline.dart';
import 'package:aviapos_mobile/core/bootstrap/bootstrap_stage.dart';

class TestBootstrapStage implements BootstrapStage {
  @override
  final String name;

  final List<String> executionLog;

  final bool shouldFail;

  TestBootstrapStage({
    required this.name,
    required this.executionLog,
    this.shouldFail = false,
  });

  @override
  Future<void> execute(BootstrapContext context) async {
    executionLog.add(name);

    if (shouldFail) {
      throw StateError('Stage failed: $name');
    }
  }
}

void main() {
  test('pipeline executes stages in order', () async {
    final executionLog = <String>[];

    final pipeline = BootstrapPipeline(
      stages: [
        TestBootstrapStage(name: 'first_stage', executionLog: executionLog),
        TestBootstrapStage(name: 'second_stage', executionLog: executionLog),
      ],
    );

    final result = await pipeline.execute();

    expect(result.success, isTrue);
    expect(executionLog, ['first_stage', 'second_stage']);
    expect(result.completedStages, ['first_stage', 'second_stage']);
  });

  test('pipeline stops when a stage fails', () async {
    final executionLog = <String>[];

    final pipeline = BootstrapPipeline(
      stages: [
        TestBootstrapStage(name: 'first_stage', executionLog: executionLog),
        TestBootstrapStage(
          name: 'failing_stage',
          executionLog: executionLog,
          shouldFail: true,
        ),
        TestBootstrapStage(
          name: 'never_reached_stage',
          executionLog: executionLog,
        ),
      ],
    );

    final result = await pipeline.execute();

    expect(result.success, isFalse);
    expect(result.completedStages, ['first_stage']);
    expect(result.failureStage, 'failing_stage');
    expect(result.error, isA<StateError>());

    expect(executionLog, ['first_stage', 'failing_stage']);
  });
}
