/// Shared context passed between bootstrap stages.
///
/// BootstrapContext provides a controlled container for values
/// produced during application startup.
///
/// The context is intentionally small. It should not become a
/// general-purpose service locator.
class BootstrapContext {
  final Map<Type, Object> _values = {};

  void put<T extends Object>(T value) {
    _values[T] = value;
  }

  T? get<T extends Object>() {
    return _values[T] as T?;
  }

  bool contains<T extends Object>() {
    return _values.containsKey(T);
  }

  void clear() {
    _values.clear();
  }
}
