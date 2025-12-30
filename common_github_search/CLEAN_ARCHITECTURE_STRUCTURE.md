# Clean Architecture Project Structure

This document outlines the new Clean Architecture structure implemented for the GitHub Search application.

## Directory Structure

```
lib/
├── src/
│   ├── core/                          # Core Layer - Cross-cutting concerns
│   │   ├── di/                        # Dependency Injection
│   │   └── utils/                     # Shared utilities
│   ├── domain/                        # Domain Layer - Business Logic
│   │   ├── entities/                  # Business entities
│   │   ├── repositories/              # Repository interfaces
│   │   ├── use_cases/                 # Business use cases
│   │   └── exceptions/                # Domain exceptions
│   ├── data/                          # Data Layer - External data access
│   │   ├── repositories/              # Repository implementations
│   │   ├── data_sources/              # Data source abstractions
│   │   │   ├── remote/                # API clients
│   │   │   └── local/                 # Cache implementations
│   │   └── models/                    # Data Transfer Objects (DTOs)
│   └── presentation/                  # Presentation Layer - UI logic
│       └── bloc/                      # BLoC components
├── common_github_search.dart          # Main library export
└── main.dart                          # Legacy compatibility export

test/
├── core/                              # Core layer tests
├── domain/                            # Domain layer tests
├── data/                              # Data layer tests
└── presentation/                      # Presentation layer tests
```

## File Migration Summary

### Moved Files:
- `src/github_search_bloc/*` → `src/presentation/bloc/`
- `src/github_client.dart` → `src/data/data_sources/remote/github_client.dart`
- `src/github_cache.dart` → `src/data/data_sources/local/github_cache.dart`
- `src/github_repository.dart` → `src/data/repositories/github_repository.dart`
- `src/models/*` → `src/data/models/`

### Updated Dependencies:
- Added `test: ^1.24.0` for unit testing
- Added `mockito: ^5.4.0` for mocking in tests
- Added `build_runner: ^2.4.0` for code generation

## Architecture Layers

### 1. Domain Layer (Business Logic)
- **Entities**: Core business objects with business rules
- **Use Cases**: Business operations that orchestrate data flow
- **Repository Interfaces**: Contracts for data access
- **Exceptions**: Domain-specific error types

### 2. Data Layer (External Data Access)
- **Repository Implementations**: Concrete implementations of domain contracts
- **Data Sources**: Abstractions for remote APIs and local caches
- **DTOs**: Data transfer objects for serialization

### 3. Presentation Layer (UI Logic)
- **BLoC Components**: State management for UI
- **Event/State Classes**: UI interaction contracts

### 4. Core Layer (Cross-cutting Concerns)
- **Dependency Injection**: Service registration and resolution
- **Utilities**: Shared helper functions

## Next Steps

The project structure is now ready for Clean Architecture implementation. The next tasks will involve:

1. Creating domain entities and use cases
2. Implementing repository interfaces and abstractions
3. Refactoring existing code to follow dependency inversion
4. Setting up dependency injection container
5. Adding comprehensive testing support

## Backward Compatibility

The main export files (`common_github_search.dart` and `main.dart`) have been updated to maintain compatibility with existing Flutter and Angular applications while using the new structure internally.