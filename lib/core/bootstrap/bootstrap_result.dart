class BootstrapResult {
  final bool success;
  final List<String> completedStages;
  final String? failureStage;
  final Object? error;

  const BootstrapResult({
    required this.success,
    required this.completedStages,
    this.failureStage,
    this.error,
  });
}
