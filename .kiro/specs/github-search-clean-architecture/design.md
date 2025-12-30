# Design Document: GitHub Search Clean Architecture

## Overview

This design implements Clean Architecture for the GitHub search application, transforming the existing BLoC-based implementation into a properly layered architecture that follows SOLID principles. The design establishes clear boundaries between business logic, data access, and presentation concerns while maintaining the existing Flutter and Angular frontend compatibility.

## Architecture

The application follows Clean Architecture's concentric layer approach:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │   Flutter UI    │              │   Angular UI    │      │
│  │     (BLoC)      │              │  (Components)   │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │    Entities     │  │   Use Cases     │  │ Repository  │ │
│  │                 │  │                 │  │ Interfaces  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Data Layer                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  Repository     │  │  Data Sources   │  │   Models    │ │
│  │ Implementation  │  │ (API, Cache)    │  │ (DTOs)      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### Domain Layer Components

#### Entities
```dart
// Core business entity representing a GitHub repository
class GitHubRepository {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final GitHubUser owner;
  final int stargazersCount;
  final String language;
  final DateTime updatedAt;
  
  // Business logic methods
  bool get isPopular => stargazersCount > 1000;
  String get displayName => fullName.isNotEmpty ? fullName : name;
}

// Value object for search criteria
class SearchCriteria {
  final String query;
  final int page;
  final int perPage;
  
  // Validation logic
  bool get isValid => query.trim().isNotEmpty && query.length >= 2;
}
```

#### Repository Interfaces
```dart
abstract class GitHubRepositoryInterface {
  Future<SearchResult<GitHubRepository>> searchRepositories(SearchCriteria criteria);
  Future<GitHubRepository?> getRepositoryById(int id);
}
```

#### Use Cases
```dart
class SearchRepositoriesUseCase {
  final GitHubRepositoryInterface _repository;
  
  SearchRepositoriesUseCase(this._repository);
  
  Future<UseCaseResult<List<GitHubRepository>>> execute(SearchCriteria criteria) async {
    if (!criteria.isValid) {
      return UseCaseResult.failure(InvalidSearchCriteriaException());
    }
    
    try {
      final result = await _repository.searchRepositories(criteria);
      return UseCaseResult.success(result.items);
    } catch (e) {
      return UseCaseResult.failure(_mapException(e));
    }
  }
}
```

### Data Layer Components

#### Repository Implementation
```dart
class GitHubRepositoryImpl implements GitHubRepositoryInterface {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  
  GitHubRepositoryImpl(this._remoteDataSource, this._localDataSource);
  
  @override
  Future<SearchResult<GitHubRepository>> searchRepositories(SearchCriteria criteria) async {
    try {
      // Check cache first
      final cachedResult = await _localDataSource.getSearchResult(criteria.query);
      if (cachedResult != null && !_isCacheExpired(cachedResult)) {
        return _mapToSearchResult(cachedResult);
      }
      
      // Fetch from remote
      final remoteResult = await _remoteDataSource.searchRepositories(criteria);
      
      // Cache the result
      await _localDataSource.cacheSearchResult(criteria.query, remoteResult);
      
      return _mapToSearchResult(remoteResult);
    } catch (e) {
      throw _mapDataException(e);
    }
  }
}
```

#### Data Sources
```dart
abstract class RemoteDataSource {
  Future<SearchResultDto> searchRepositories(SearchCriteria criteria);
  Future<GitHubRepositoryDto?> getRepositoryById(int id);
}

abstract class LocalDataSource {
  Future<SearchResultDto?> getSearchResult(String query);
  Future<void> cacheSearchResult(String query, SearchResultDto result);
  Future<void> clearCache();
}
```

### Presentation Layer Integration

#### BLoC Integration
```dart
class GitHubSearchBloc extends Bloc<GitHubSearchEvent, GitHubSearchState> {
  final SearchRepositoriesUseCase _searchUseCase;
  
  GitHubSearchBloc(this._searchUseCase) : super(SearchStateEmpty()) {
    on<SearchTextChanged>(_onSearchTextChanged);
  }
  
  Future<void> _onSearchTextChanged(
    SearchTextChanged event,
    Emitter<GitHubSearchState> emit,
  ) async {
    final criteria = SearchCriteria(query: event.text, page: 1, perPage: 30);
    
    emit(SearchStateLoading());
    
    final result = await _searchUseCase.execute(criteria);
    
    result.fold(
      onSuccess: (repositories) => emit(SearchStateSuccess(repositories)),
      onFailure: (exception) => emit(SearchStateError(_getErrorMessage(exception))),
    );
  }
}
```

## Data Models

### Domain Models
```dart
class GitHubRepository {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final GitHubUser owner;
  final int stargazersCount;
  final String language;
  final DateTime updatedAt;
  final String htmlUrl;
}

class GitHubUser {
  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;
}

class SearchResult<T> {
  final List<T> items;
  final int totalCount;
  final bool incompleteResults;
}
```

### Data Transfer Objects
```dart
class GitHubRepositoryDto {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final GitHubUserDto owner;
  final int stargazersCount;
  final String? language;
  final String updatedAt;
  final String htmlUrl;
  
  factory GitHubRepositoryDto.fromJson(Map<String, dynamic> json) => ...
  Map<String, dynamic> toJson() => ...
  
  GitHubRepository toDomain() => GitHubRepository(...);
}
```

### Result Types
```dart
class UseCaseResult<T> {
  final T? data;
  final DomainException? exception;
  final bool isSuccess;
  
  UseCaseResult.success(this.data) : exception = null, isSuccess = true;
  UseCaseResult.failure(this.exception) : data = null, isSuccess = false;
  
  void fold({
    required Function(T data) onSuccess,
    required Function(DomainException exception) onFailure,
  }) {
    if (isSuccess && data != null) {
      onSuccess(data!);
    } else if (exception != null) {
      onFailure(exception!);
    }
  }
}
```
## Dependency Injection Configuration

### Container Setup
```dart
class DIContainer {
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();
  
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, Function> _factories = {};
  
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }
  
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }
  
  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    
    if (_factories.containsKey(T)) {
      return (_factories[T] as T Function())();
    }
    
    throw DependencyNotRegisteredException('Type $T not registered');
  }
}
```

### Registration Configuration
```dart
void configureDependencies() {
  final container = DIContainer();
  
  // Data sources (singletons for connection pooling)
  container.registerSingleton<RemoteDataSource>(
    GitHubApiDataSource(httpClient: http.Client())
  );
  container.registerSingleton<LocalDataSource>(
    InMemoryCacheDataSource()
  );
  
  // Repository (singleton for caching)
  container.registerSingleton<GitHubRepositoryInterface>(
    GitHubRepositoryImpl(
      container.get<RemoteDataSource>(),
      container.get<LocalDataSource>(),
    )
  );
  
  // Use cases (factories for stateless operations)
  container.registerFactory<SearchRepositoriesUseCase>(
    () => SearchRepositoriesUseCase(container.get<GitHubRepositoryInterface>())
  );
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Entity Business Rule Validation
*For any* domain entity with business rules, all validation methods should consistently enforce those rules across all possible input values
**Validates: Requirements 1.2**

### Property 2: Repository Caching Behavior
*For any* search query, when a repository fetches data and the same query is made again within the cache validity period, the cached result should be returned without making another remote call
**Validates: Requirements 2.3**

### Property 3: Repository Error Fallback
*For any* repository operation that encounters a remote data source failure, the repository should attempt fallback mechanisms (like returning cached data) or provide appropriate error handling
**Validates: Requirements 2.5**

### Property 4: Use Case Input Validation
*For any* use case execution with invalid input parameters, the use case should reject the input and return a validation failure without attempting to process the request
**Validates: Requirements 3.2**

### Property 5: Use Case Result Consistency
*For any* use case execution, the result should always be either a success containing domain entities or a failure containing a domain exception, never both or neither
**Validates: Requirements 3.4**

### Property 6: Data Serialization Round Trip
*For any* valid domain entity, serializing it to a DTO and then deserializing back should produce an equivalent domain entity
**Validates: Requirements 4.3**

### Property 7: Error Mapping Consistency
*For any* external error from data sources, the data layer should map it to an appropriate domain exception with meaningful error information
**Validates: Requirements 4.4**

### Property 8: Data Source Coordination
*For any* data operation, the repository should follow the defined precedence rules (cache first, then remote, then fallback) consistently
**Validates: Requirements 4.5**

### Property 9: Singleton Container Behavior
*For any* stateful service registered as a singleton in the DI container, multiple requests for that service should return the exact same instance
**Validates: Requirements 5.3**

### Property 10: Factory Container Behavior
*For any* stateless service registered as a factory in the DI container, multiple requests for that service should return different instances
**Validates: Requirements 5.4**

### Property 11: Dependency Resolution Completeness
*For any* registered service with dependencies, the DI container should successfully resolve the complete dependency graph without circular dependencies
**Validates: Requirements 5.5**

### Property 12: External Error Mapping
*For any* external system error (network, API, etc.), the data layer should map it to a corresponding domain exception type
**Validates: Requirements 6.2**

### Property 13: Network Error Message Quality
*For any* network error, the resulting domain exception should contain a meaningful error message that describes the problem
**Validates: Requirements 6.3**

### Property 14: Use Case Exception Handling
*For any* exception that occurs during use case execution, the use case should catch it and return a failure result rather than letting the exception propagate
**Validates: Requirements 6.4**

### Property 15: Error Information Structure
*For any* error that reaches the presentation layer, it should contain structured information (error type, message, context) suitable for user feedback
**Validates: Requirements 6.5**

### Property 16: Presentation Use Case Delegation
*For any* business operation triggered by user interaction, the presentation layer should delegate to the appropriate use case rather than handling business logic directly
**Validates: Requirements 8.2**

### Property 17: BLoC Event-Domain Coordination
*For any* UI event processed by a BLoC, it should result in a corresponding domain operation through use cases
**Validates: Requirements 8.3**

### Property 18: Presentation State Update Consistency
*For any* use case result received by the presentation layer, it should update the UI state appropriately (success states for successful results, error states for failures)
**Validates: Requirements 8.4**

## Error Handling

### Domain Exceptions
```dart
abstract class DomainException implements Exception {
  final String message;
  final String code;
  
  const DomainException(this.message, this.code);
}

class InvalidSearchCriteriaException extends DomainException {
  const InvalidSearchCriteriaException() 
    : super('Search criteria is invalid', 'INVALID_SEARCH_CRITERIA');
}

class RepositoryNotFoundException extends DomainException {
  const RepositoryNotFoundException(int id) 
    : super('Repository with id $id not found', 'REPOSITORY_NOT_FOUND');
}

class NetworkException extends DomainException {
  const NetworkException(String details) 
    : super('Network error occurred: $details', 'NETWORK_ERROR');
}
```

### Error Mapping Strategy
```dart
class ErrorMapper {
  static DomainException mapDataException(Exception exception) {
    if (exception is SocketException) {
      return NetworkException('No internet connection');
    } else if (exception is HttpException) {
      return NetworkException('HTTP error: ${exception.message}');
    } else if (exception is FormatException) {
      return DataParsingException('Invalid data format');
    }
    return UnknownException('An unexpected error occurred');
  }
}
```

## Testing Strategy

### Dual Testing Approach
The architecture supports comprehensive testing through both unit tests and property-based tests:

**Unit Tests**: Verify specific examples, edge cases, and error conditions
- Test specific search scenarios with known inputs and expected outputs
- Test error conditions like network failures and invalid inputs
- Test integration points between layers
- Verify mock interactions and dependency injection

**Property Tests**: Verify universal properties across all inputs
- Test that business rules hold for all valid entity states
- Verify caching behavior works correctly for any search query
- Ensure error handling is consistent across all failure scenarios
- Validate serialization round-trips for all domain entities

### Property-Based Testing Configuration
- Use the `test` package with `fake` and `mockito` for Dart testing
- Configure each property test to run minimum 100 iterations
- Tag each test with: **Feature: github-search-clean-architecture, Property {number}: {property_text}**
- Each correctness property must be implemented by a single property-based test

### Testing Framework Setup
```dart
// Property-based testing with generated test data
void main() {
  group('Domain Entity Properties', () {
    test('Property 1: Entity Business Rule Validation', () {
      // Feature: github-search-clean-architecture, Property 1: Entity Business Rule Validation
      final generator = GitHubRepositoryGenerator();
      
      for (int i = 0; i < 100; i++) {
        final repository = generator.generate();
        expect(repository.isPopular, equals(repository.stargazersCount > 1000));
        expect(repository.displayName.isNotEmpty, isTrue);
      }
    });
  });
}
```

### Integration Testing
- Test complete flows from presentation to data layer
- Use real HTTP clients with mock servers for API testing
- Verify dependency injection container resolves all dependencies correctly
- Test error propagation through all layers