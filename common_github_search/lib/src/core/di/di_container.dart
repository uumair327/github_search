/// Dependency Injection Container for managing object lifecycles
/// 
/// Supports both singleton and factory registration patterns.
/// Handles dependency graph resolution automatically.
class DIContainer {
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();

  final Map<Type, dynamic> _singletons = {};
  final Map<Type, Function> _factories = {};

  /// Register a singleton instance that will be reused for all requests
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Register a factory function that creates new instances on each request
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Get an instance of type T
  /// 
  /// Returns singleton if registered as singleton, otherwise creates new instance
  /// from factory. Throws [DependencyNotRegisteredException] if type not registered.
  T get<T>() {
    // Check singletons first
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // Check factories
    if (_factories.containsKey(T)) {
      return (_factories[T] as T Function())();
    }

    throw DependencyNotRegisteredException('Type $T not registered');
  }

  /// Check if a type is registered (either as singleton or factory)
  bool isRegistered<T>() {
    return _singletons.containsKey(T) || _factories.containsKey(T);
  }

  /// Clear all registrations (useful for testing)
  void clear() {
    _singletons.clear();
    _factories.clear();
  }

  /// Get all registered singleton types
  List<Type> get registeredSingletons => _singletons.keys.toList();

  /// Get all registered factory types
  List<Type> get registeredFactories => _factories.keys.toList();
}

/// Exception thrown when trying to resolve an unregistered dependency
class DependencyNotRegisteredException implements Exception {
  final String message;
  
  const DependencyNotRegisteredException(this.message);
  
  @override
  String toString() => 'DependencyNotRegisteredException: $message';
}