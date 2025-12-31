import 'package:http/http.dart' as http;

import '../../data/data_sources/remote_data_source.dart';
import '../../data/data_sources/local_data_source.dart';
import '../../data/data_sources/remote/github_client.dart';
import '../../data/data_sources/local/github_cache.dart';
import '../../data/repositories/github_repository.dart';
import '../../domain/repositories/github_repository_interface.dart';
import '../../domain/use_cases/search_repositories_use_case.dart';
import '../../presentation/bloc/github_search_bloc.dart';
import 'di_container.dart';

/// Configure all dependencies for the application
/// 
/// Registers services with appropriate lifecycles:
/// - Singletons for stateful services (data sources, repositories)
/// - Factories for stateless services (use cases)
/// 
/// Requirements covered:
/// - 5.1: Implement dependency injection container for managing object lifecycles
/// - 5.3: Provide singleton instances for stateful services like repositories
/// - 5.4: Provide factory instances for stateless services like use cases
void configureDependencies() {
  final container = DIContainer();

  // Clear any existing registrations (useful for testing)
  container.clear();

  // Register HTTP client as singleton for connection pooling
  container.registerSingleton<http.Client>(http.Client());

  // Register data sources as singletons for connection pooling and cache management
  container.registerSingleton<RemoteDataSource>(
    GitHubApiDataSource(
      httpClient: container.get<http.Client>(),
    ),
  );

  container.registerSingleton<LocalDataSource>(
    InMemoryCacheDataSource(),
  );

  // Register repository as singleton for caching benefits
  container.registerSingleton<GitHubRepositoryInterface>(
    GitHubRepositoryImpl(
      remoteDataSource: container.get<RemoteDataSource>(),
      localDataSource: container.get<LocalDataSource>(),
    ),
  );

  // Register use cases as factories since they are stateless
  container.registerFactory<SearchRepositoriesUseCase>(
    () => SearchRepositoriesUseCase(
      container.get<GitHubRepositoryInterface>(),
    ),
  );
}

/// Initialize the application with dependency injection
/// 
/// This function should be called once at application startup
/// before any other services are used. It ensures proper initialization
/// order and prevents multiple initializations.
/// 
/// Requirements covered:
/// - 5.1: Implement dependency injection container for managing object lifecycles
/// - 5.2: Register abstractions with their concrete implementations
/// 
/// Throws [StateError] if called multiple times without calling [resetApp] first.
void initializeApp() {
  final container = DIContainer();
  
  // Check if already initialized to prevent double initialization
  if (container.isRegistered<http.Client>()) {
    throw StateError(
      'Application is already initialized. Call resetApp() first if you need to reinitialize.'
    );
  }
  
  // Configure all dependencies in proper order
  configureDependencies();
  
  // Verify critical dependencies are registered
  _verifyInitialization();
}

/// Reset the application state for testing or reinitialization
/// 
/// This function clears all registered dependencies and allows
/// for fresh initialization. Primarily used for testing scenarios.
void resetApp() {
  DIContainer().clear();
}

/// Verify that all critical dependencies are properly initialized
/// 
/// This internal function ensures that the initialization process
/// completed successfully and all required services are available.
void _verifyInitialization() {
  final container = DIContainer();
  
  // Verify core services are registered by checking each type
  if (!container.isRegistered<http.Client>()) {
    throw StateError('Critical service http.Client was not registered during initialization');
  }
  
  if (!container.isRegistered<RemoteDataSource>()) {
    throw StateError('Critical service RemoteDataSource was not registered during initialization');
  }
  
  if (!container.isRegistered<LocalDataSource>()) {
    throw StateError('Critical service LocalDataSource was not registered during initialization');
  }
  
  if (!container.isRegistered<GitHubRepositoryInterface>()) {
    throw StateError('Critical service GitHubRepositoryInterface was not registered during initialization');
  }
  
  if (!container.isRegistered<SearchRepositoriesUseCase>()) {
    throw StateError('Critical service SearchRepositoriesUseCase was not registered during initialization');
  }
}

/// Get a dependency from the container
/// 
/// This is a convenience function that provides access to the DI container
/// for retrieving registered dependencies.
T getDependency<T>() {
  return DIContainer().get<T>();
}

/// Check if a dependency is registered
/// 
/// Useful for testing and debugging dependency configuration
bool isDependencyRegistered<T>() {
  return DIContainer().isRegistered<T>();
}

/// Factory method to create GithubSearchBloc with Clean Architecture
/// 
/// This is a convenience method for frontend applications to easily
/// create the BLoC with proper dependency injection.
/// 
/// Usage:
/// ```dart
/// // Initialize the app first
/// initializeApp();
/// 
/// // Create the BLoC
/// final bloc = createGithubSearchBloc();
/// ```
GithubSearchBloc createGithubSearchBloc() {
  final useCase = getDependency<SearchRepositoriesUseCase>();
  return GithubSearchBloc(searchRepositoriesUseCase: useCase);
}