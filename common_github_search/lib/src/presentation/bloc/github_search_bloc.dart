import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/entities/entities.dart';
import '../../domain/use_cases/use_cases.dart';
import '../../domain/exceptions/exceptions.dart';
import 'github_search_event.dart';
import 'github_search_state.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

/// BLoC for GitHub search functionality following Clean Architecture
/// 
/// Delegates business operations to use cases and handles presentation concerns
/// Requirements covered:
/// - 8.2: Delegate to appropriate use cases for business operations
/// - 8.3: Coordinate between UI events and domain operations
/// - 8.4: Handle use case results and update UI state accordingly
class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  GithubSearchBloc({required SearchRepositoriesUseCase searchRepositoriesUseCase})
    : _searchRepositoriesUseCase = searchRepositoriesUseCase,
      super(SearchStateEmpty()) {
    on<TextChanged>(_onTextChanged, transformer: debounce(_duration));
  }

  final SearchRepositoriesUseCase _searchRepositoriesUseCase;

  /// Handle text changed events by delegating to search use case
  /// 
  /// Business logic delegation:
  /// - Creates SearchCriteria from user input
  /// - Delegates to SearchRepositoriesUseCase for business processing
  /// - Maps use case results to appropriate UI states
  /// - Handles domain exceptions with proper error messages
  Future<void> _onTextChanged(
    TextChanged event,
    Emitter<GithubSearchState> emit,
  ) async {
    final searchTerm = event.text.trim();

    // Handle empty search - return to empty state
    if (searchTerm.isEmpty) {
      return emit(SearchStateEmpty());
    }

    // Emit loading state while processing
    emit(SearchStateLoading());

    // Create search criteria from user input
    final criteria = SearchCriteria(
      query: searchTerm,
      page: 1,
      perPage: 30,
    );

    // Delegate to use case for business processing
    final result = await _searchRepositoriesUseCase.execute(criteria);

    // Map use case result to presentation state
    result.fold(
      onSuccess: (repositories) {
        emit(SearchStateSuccess(repositories));
      },
      onFailure: (exception) {
        final errorMessage = _mapExceptionToUserMessage(exception);
        emit(SearchStateError(errorMessage));
      },
    );
  }

  /// Map domain exceptions to user-friendly error messages
  /// 
  /// Provides appropriate error messages for different exception types
  /// while maintaining separation between domain and presentation concerns
  String _mapExceptionToUserMessage(Exception exception) {
    if (exception is DomainException) {
      switch (exception.code) {
        case 'INVALID_SEARCH_CRITERIA':
          return 'Please enter a valid search term (at least 2 characters)';
        case 'NETWORK_ERROR':
          return 'Network error. Please check your connection and try again.';
        case 'DATA_PARSING_ERROR':
          return 'Unable to process search results. Please try again.';
        case 'REPOSITORY_NOT_FOUND':
          return 'No repositories found for your search.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    
    // Fallback for non-domain exceptions
    return 'An unexpected error occurred. Please try again.';
  }
}