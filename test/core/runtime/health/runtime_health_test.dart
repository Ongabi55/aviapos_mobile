import 'package:flutter_test/flutter_test.dart';

import 'package:aviapos_mobile/core/runtime/health/health_check.dart';
import 'package:aviapos_mobile/core/runtime/health/runtime_health.dart';
import 'package:aviapos_mobile/core/runtime/health/runtime_health_service.dart';

class HealthyCheck implements HealthCheck {
  const HealthyCheck();

  @override
  String get name => 'healthy';

  @override
  Future<HealthCheckResult> check() async {
    return const HealthCheckResult(
      name: 'healthy',
      status: RuntimeHealthStatus.healthy,
    );
  }
}

class DegradedCheck implements HealthCheck {
  const DegradedCheck();

  @override
  String get name => 'degraded';

  @override
  Future<HealthCheckResult> check() async {
    return const HealthCheckResult(
      name: 'degraded',
      status: RuntimeHealthStatus.degraded,
    );
  }
}

class UnhealthyCheck implements HealthCheck {
  const UnhealthyCheck();

  @override
  String get name => 'unhealthy';

  @override
  Future<HealthCheckResult> check() async {
    return const HealthCheckResult(
      name: 'unhealthy',
      status: RuntimeHealthStatus.unhealthy,
    );
  }
}

class ThrowingCheck implements HealthCheck {
  const ThrowingCheck();

  @override
  String get name => 'throwing';

  @override
  Future<HealthCheckResult> check() async {
    throw StateError('dependency unavailable');
  }
}

void main() {
  group('RuntimeHealthService', () {
    test('reports unhealthy when no checks are registered', () async {
      const service = RuntimeHealthService();

      final result = await service.evaluate();

      expect(result.status, RuntimeHealthStatus.unhealthy);
      expect(result.ready, isFalse);
      expect(result.checks, isEmpty);
    });

    test('reports healthy when all checks pass', () async {
      const service = RuntimeHealthService(
        checks: [
          HealthyCheck(),
        ],
      );

      final result = await service.evaluate();

      expect(result.status, RuntimeHealthStatus.healthy);
      expect(result.ready, isTrue);
      expect(result.checks, hasLength(1));
    });

    test('reports degraded when a check is degraded', () async {
      const service = RuntimeHealthService(
        checks: [
          HealthyCheck(),
          DegradedCheck(),
        ],
      );

      final result = await service.evaluate();

      expect(result.status, RuntimeHealthStatus.degraded);
      expect(result.ready, isTrue);
      expect(result.checks, hasLength(2));
    });

    test('reports unhealthy when a check fails', () async {
      const service = RuntimeHealthService(
        checks: [
          HealthyCheck(),
          UnhealthyCheck(),
        ],
      );

      final result = await service.evaluate();

      expect(result.status, RuntimeHealthStatus.unhealthy);
      expect(result.ready, isFalse);
    });

    test('converts health check exceptions into unhealthy results', () async {
      const service = RuntimeHealthService(
        checks: [
          ThrowingCheck(),
        ],
      );

      final result = await service.evaluate();

      expect(result.status, RuntimeHealthStatus.unhealthy);
      expect(result.ready, isFalse);
      expect(result.checks.single.name, 'throwing');
      expect(result.checks.single.message, contains('dependency unavailable'));
    });
  });
}