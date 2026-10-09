/// Operational state of the Avia runtime.
enum RuntimeHealthStatus { healthy, degraded, unhealthy }

/// Result produced by an individual runtime health check.
class HealthCheckResult {
  final String name;
  final RuntimeHealthStatus status;
  final String? message;

  const HealthCheckResult({
    required this.name,
    required this.status,
    this.message,
  });

  bool get isHealthy => status == RuntimeHealthStatus.healthy;
}

/// Aggregate operational state of the runtime.
///
/// RuntimeHealth contains operational information only.
///
/// It must never contain:
/// - merchant state
/// - authentication state
/// - payment state
/// - inventory state
/// - business rules
/// - UI state
class RuntimeHealth {
  final RuntimeHealthStatus status;
  final bool ready;
  final List<HealthCheckResult> checks;

  const RuntimeHealth({
    required this.status,
    required this.ready,
    this.checks = const [],
  });

  bool get isHealthy => status == RuntimeHealthStatus.healthy;

  bool get isDegraded => status == RuntimeHealthStatus.degraded;

  bool get isUnhealthy => status == RuntimeHealthStatus.unhealthy;

  static const RuntimeHealth initial = RuntimeHealth(
    status: RuntimeHealthStatus.unhealthy,
    ready: false,
  );
}
