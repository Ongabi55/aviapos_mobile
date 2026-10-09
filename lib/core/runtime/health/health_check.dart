import 'runtime_health.dart';

/// Contract for a replaceable runtime health check.
///
/// Implementations are responsible only for determining the
/// operational condition of one dependency or subsystem.
abstract interface class HealthCheck {
  String get name;

  Future<HealthCheckResult> check();
}
