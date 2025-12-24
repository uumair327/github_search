# BLoC GitHub Search Project - Architecture & Best Practices

## Overview

This project is an official example from the BLoC library (bloclibrary.dev) that demonstrates how to build a GitHub repository search application using the BLoC (Business Logic Component) pattern. The project showcases a sophisticated multi-platform architecture where business logic is shared between Flutter and AngularDart applications through a common Dart library.

## Project Structure & Architecture

### Monorepo Organization

The project follows a **monorepo pattern** with three distinct modules:

```
├── common_github_search/     # Shared Dart library (Business Logic)
├── flutter_github_search/    # Flutter mobile application
└── angular_github_search/    # AngularDart web application
```

This structure demonstrates the **"Write Once, Run Everywhere"** philosophy for business logic while maintaining platform-specific UI implementations.

### Core Architecture Principles

1. **Separation of Concerns**: Business logic is completely isolated from UI frameworks
2. **Dependency Injection**: Constructor-based DI for testability and flexibility
3. **Repository Pattern**: Abstraction layer over data sources
4. **Event-Driven Architecture**: Reactive programming with BLoC pattern
5. **Type Safety**: Leverages Dart's sealed classes for compile-time safety

## BLoC Pattern Implementation

### The Heart: GithubSearchBloc

The `GithubSearchBloc` is the centerpiece that demonstrates several BLoC best practices:

```dart
class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  GithubSearchBloc({required GithubRepository githubRepository})
    : _githubRepository = githubRepository,
      super(SearchStateEmpty()) {
    on<TextChanged>(_onTextChanged, transformer: debounce(_duration));
  }
}
```

**Key Features:**
- **Single Event Type**: `TextChanged` - keeps the interface simple and focused
- **Event Transformation**: Uses debouncing (300ms) to prevent excessive API calls
- **Dependency Injection**: Repository is injected, not instantiated internally
- **Clean State Management**: Four distinct states with sealed class hierarchy

### State Hierarchy (Type-Safe Design)

```dart
sealed class GithubSearchState extends Equatable {
  const GithubSearchState();
}

final class SearchStateEmpty extends GithubSearchState {}
final class SearchStateLoading extends GithubSearchState {}
final class SearchStateSuccess extends GithubSearchState {
  const SearchStateSuccess(this.items);
  final List<SearchResultItem> items;
}
final class SearchStateError extends GithubSearchState {
  const SearchStateError(this.error);
  final String error;
}
```

**Design Benefits:**
- **Sealed Classes**: Compile-time exhaustive pattern matching
- **Equatable**: Automatic value equality for state comparison
- **Immutability**: All states are immutable by design
- **Clear Intent**: Each state represents a distinct UI condition

### Event System (Minimal & Focused)

```dart
sealed class GithubSearchEvent extends Equatable {
  const GithubSearchEvent();
}

final class TextChanged extends GithubSearchEvent {
  const TextChanged({required this.text});
  final String text;
}
```

**Design Philosophy:**
- **Single Responsibility**: One event type for one user action
- **Value Objects**: Events carry only necessary data
- **Immutability**: Events are immutable value objects

## Data Layer Architecture

### Repository Pattern Implementation

The `GithubRepository` demonstrates the repository pattern with caching:

```dart
class GithubRepository {
  GithubRepository({GithubCache? cache, GithubClient? client})
    : _cache = cache ?? GithubCache(),
      _client = client ?? GithubClient();

  Future<SearchResult> search(String term) async {
    final cachedResult = _cache.get(term);
    if (cachedResult != null) return cachedResult;
    
    final result = await _client.search(term);
    _cache.set(term, result);
    return result;
  }
}
```

**Architecture Benefits:**
- **Cache-First Strategy**: Improves performance and reduces API calls
- **Dependency Injection**: Both cache and client can be mocked for testing
- **Single Interface**: BLoC doesn't need to know about caching or HTTP details
- **Resource Management**: Proper cleanup with `dispose()` method

### HTTP Client Layer

The `GithubClient` handles API communication:

```dart
class GithubClient {
  Future<SearchResult> search(String term) async {
    final response = await _httpClient.get(Uri.parse('$baseUrl$term'));
    final results = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return SearchResult.fromJson(results);
    } else {
      throw SearchResultError.fromJson(results);
    }
  }
}
```

**Key Features:**
- **Error Handling**: Distinguishes between success and error responses
- **Type Safety**: Proper JSON deserialization with factory constructors
- **Testability**: HTTP client can be injected for testing

### Caching Strategy

The `GithubCache` provides simple in-memory caching:

```dart
class GithubCache {
  final _cache = <String, SearchResult>{};
  
  SearchResult? get(String term) => _cache[term];
  void set(String term, SearchResult result) => _cache[term] = result;
  bool contains(String term) => _cache.containsKey(term);
}
```

**Design Decisions:**
- **Simple Implementation**: Map-based storage for demonstration
- **Nullable Returns**: Uses Dart's null safety for cache misses
- **Clear Interface**: Simple get/set/contains operations

## Model Design Patterns

### Immutable Data Models

All models follow consistent patterns:

```dart
class SearchResult {
  const SearchResult({required this.items});
  
  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((dynamic item) => SearchResultItem.fromJson(item))
        .toList();
    return SearchResult(items: items);
  }
  
  final List<SearchResultItem> items;
}
```

**Model Principles:**
- **Immutability**: All fields are final
- **Factory Constructors**: Consistent JSON deserialization pattern
- **Type Safety**: Proper type casting and null handling
- **Value Objects**: Models represent data, not behavior

## Platform-Specific Implementations

### Flutter Implementation

The Flutter app demonstrates modern Flutter + BLoC integration:

```dart
class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => GithubRepository(),
      child: MaterialApp(
        home: BlocProvider(
          create: (context) => GithubSearchBloc(
            githubRepository: context.read<GithubRepository>(),
          ),
          child: const SearchForm(),
        ),
      ),
    );
  }
}
```

**Flutter-Specific Patterns:**
- **RepositoryProvider**: Dependency injection at app level
- **BlocProvider**: BLoC instantiation and disposal
- **BlocBuilder**: Reactive UI updates based on state changes
- **Context.read()**: Accessing dependencies from widget tree

### AngularDart Implementation

The AngularDart app shows component-based architecture:

```dart
@Component(
  selector: 'search-form',
  templateUrl: 'search_form_component.html',
  directives: [SearchBarComponent, SearchBodyComponent],
  pipes: [BlocPipe],
)
class SearchFormComponent implements OnInit, OnDestroy {
  late GithubSearchBloc githubSearchBloc;

  void ngOnInit() {
    githubSearchBloc = GithubSearchBloc(githubRepository: githubRepository);
  }

  void ngOnDestroy() {
    githubSearchBloc.close();
  }
}
```

**AngularDart-Specific Patterns:**
- **Component Lifecycle**: Proper BLoC initialization and cleanup
- **Template Binding**: Reactive templates with BlocPipe
- **Component Composition**: Separate components for different concerns
- **Dependency Injection**: Angular's DI system integration

## Best Practices Demonstrated

### 1. Event Transformation & Debouncing

```dart
EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

// Usage in BLoC
on<TextChanged>(_onTextChanged, transformer: debounce(_duration));
```

**Benefits:**
- **Performance**: Prevents excessive API calls during typing
- **User Experience**: Smooth, responsive search experience
- **Resource Efficiency**: Reduces server load and network usage

### 2. Error Handling Strategy

```dart
try {
  final results = await _githubRepository.search(searchTerm);
  emit(SearchStateSuccess(results.items));
} catch (error) {
  emit(
    error is SearchResultError
        ? SearchStateError(error.message)
        : const SearchStateError('something went wrong'),
  );
}
```

**Error Handling Principles:**
- **Specific Error Types**: Custom exceptions for API errors
- **Graceful Degradation**: Generic fallback for unexpected errors
- **User-Friendly Messages**: Meaningful error states for UI

### 3. Resource Management

```dart
// Repository cleanup
void dispose() {
  _cache.close();
  _client.close();
}

// BLoC cleanup (automatic in flutter_bloc)
void ngOnDestroy() {
  githubSearchBloc.close();
}
```

**Resource Management:**
- **Explicit Cleanup**: Manual resource disposal where needed
- **Framework Integration**: Leverages platform-specific lifecycle management
- **Memory Leak Prevention**: Proper stream and resource cleanup

### 4. Dependency Injection Patterns

**Constructor Injection:**
```dart
GithubSearchBloc({required GithubRepository githubRepository})
  : _githubRepository = githubRepository;
```

**Optional Dependencies with Defaults:**
```dart
GithubRepository({GithubCache? cache, GithubClient? client})
  : _cache = cache ?? GithubCache(),
    _client = client ?? GithubClient();
```

**Benefits:**
- **Testability**: Easy to mock dependencies
- **Flexibility**: Can swap implementations
- **Inversion of Control**: Dependencies flow from outside

## Architectural Decisions & Rationale

### Why Sealed Classes?

Sealed classes provide compile-time exhaustive pattern matching:

```dart
// Compiler ensures all states are handled
Widget buildBody(GithubSearchState state) {
  return switch (state) {
    SearchStateEmpty() => Text('Enter a search term'),
    SearchStateLoading() => CircularProgressIndicator(),
    SearchStateSuccess(:final items) => ListView(children: items),
    SearchStateError(:final error) => Text('Error: $error'),
  };
}
```

### Why Repository Pattern?

The repository pattern provides several benefits:
- **Abstraction**: BLoC doesn't know about HTTP or caching details
- **Testability**: Easy to mock the entire data layer
- **Flexibility**: Can switch between different data sources
- **Caching**: Transparent caching without BLoC awareness

### Why Event Transformation?

Event transformation (debouncing) is crucial for search UIs:
- **Performance**: Prevents API spam during typing
- **User Experience**: Smooth, responsive interface
- **Cost Efficiency**: Reduces API usage and costs

## Testing Strategy (Implied)

The architecture enables comprehensive testing:

**Unit Testing:**
- **BLoC Testing**: Mock repository, test state transitions
- **Repository Testing**: Mock client and cache, test logic
- **Model Testing**: Test JSON serialization/deserialization

**Integration Testing:**
- **End-to-End**: Test complete search flow
- **Platform-Specific**: Test UI integration with BLoC

**Mocking Strategy:**
- **Repository**: Mock for BLoC tests
- **HTTP Client**: Mock for repository tests
- **Cache**: Mock for repository tests

## Key Takeaways

### 1. Architecture Principles
- **Single Responsibility**: Each class has one clear purpose
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Open/Closed**: Open for extension, closed for modification
- **Interface Segregation**: Small, focused interfaces

### 2. BLoC Best Practices
- **Event Transformation**: Use for performance optimization
- **Sealed Classes**: Leverage for type safety
- **Dependency Injection**: Constructor-based for testability
- **Resource Management**: Proper cleanup and disposal

### 3. Code Sharing Strategy
- **Common Library**: Share business logic, not UI
- **Platform Abstraction**: Let each platform handle UI its way
- **Dependency Management**: Use path dependencies for local packages
- **API Design**: Clean, minimal public interfaces

### 4. Modern Dart Features
- **Sealed Classes**: Type-safe hierarchies
- **Pattern Matching**: Exhaustive switch expressions
- **Null Safety**: Proper null handling throughout
- **Factory Constructors**: Consistent object creation patterns

This project serves as an excellent reference for building scalable, maintainable applications using the BLoC pattern while demonstrating how to share business logic across multiple platforms effectively.