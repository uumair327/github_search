// Clean Architecture Library Exports
// This library provides a Clean Architecture implementation for GitHub search functionality
// with proper separation of concerns and dependency inversion.

// =============================================================================
// INITIALIZATION - Required for Clean Architecture setup
// =============================================================================
// Call initializeApp() once at application startup before using any services
export 'src/core/di/dependency_configuration.dart' show 
  initializeApp, 
  resetApp,
  createGithubSearchBloc,
  getDependency,
  isDependencyRegistered;

// =============================================================================
// PRESENTATION LAYER - UI Components and State Management
// =============================================================================
// BLoC components for state management (compatible with Flutter and Angular)
export 'src/presentation/bloc/github_search_bloc.dart';
export 'src/presentation/bloc/github_search_event.dart';
export 'src/presentation/bloc/github_search_state.dart';

// =============================================================================
// DOMAIN LAYER - Business Logic and Entities
// =============================================================================
// Core business entities
export 'src/domain/entities/entities.dart';

// Repository interfaces (abstractions)
export 'src/domain/repositories/repositories.dart';

// Use cases for business operations
export 'src/domain/use_cases/use_cases.dart';

// Domain exceptions for error handling
export 'src/domain/exceptions/exceptions.dart';

// =============================================================================
// BACKWARD COMPATIBILITY - Legacy Direct Access
// =============================================================================
// These exports maintain compatibility with existing Flutter/Angular apps
// that may directly access data layer components. New applications should
// use the Clean Architecture approach with dependency injection.

// Data sources (for legacy compatibility)
export 'src/data/data_sources/local/github_cache.dart';
export 'src/data/data_sources/remote/github_client.dart';
export 'src/data/data_sources/local_data_source.dart';
export 'src/data/data_sources/remote_data_source.dart';

// Repository implementation (for legacy compatibility)
export 'src/data/repositories/github_repository.dart';

// Data models (DTOs)
export 'src/data/models/models.dart';

// =============================================================================
// ADVANCED USAGE - Direct DI Container Access
// =============================================================================
// For advanced users who need direct access to the DI container
export 'src/core/di/di_container.dart' show DIContainer;
