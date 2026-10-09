import 'health_check.dart';
import 'runtime_health.dart';

/// Coordinates runtime health checks and produces
/// an aggregate operational state.
class RuntimeHealthService {
  final List<HealthCheck> checks;

  const RuntimeHealthService({this.checks = const []});

  Future<RuntimeHealth> evaluate() async {
    if (checks.isEmpty) {
      return const RuntimeHealth(
        status: RuntimeHealthStatus.unhealthy,
        ready: false,
        checks: [],
      );
    }

    final results = <HealthCheckResult>[];

    for (final check in checks) {
      try {
        final result = await check.check();
        results.add(result);
      } catch (error) {
        results.add(
          HealthCheckResult(
            name: check.name,
            status: RuntimeHealthStatus.unhealthy,
            message: 'Health check failed: $error',
          ),
        );
      }
    }

    final hasUnhealthy = results.any(
      (result) => result.status == RuntimeHealthStatus.unhealthy,
    );

    final hasDegraded = results.any(
      (result) => result.status == RuntimeHealthStatus.degraded,
    );

    if (hasUnhealthy) {
      return RuntimeHealth(
        status: RuntimeHealthStatus.unhealthy,
        ready: false,
        checks: List.unmodifiable(results),
      );
    }

    if (hasDegraded) {
      return RuntimeHealth(
        status: RuntimeHealthStatus.degraded,
        ready: true,
        checks: List.unmodifiable(results),
      );
    }

    return RuntimeHealth(
      status: RuntimeHealthStatus.healthy,
      ready: true,
      checks: List.unmodifiable(results),
    );
  }
}
