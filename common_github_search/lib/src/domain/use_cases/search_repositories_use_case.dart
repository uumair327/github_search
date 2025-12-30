import '../entities/entities.dart';
import '../repositories/repositories.dart';
import '../exceptions/exceptions.dart';

/// Use case for searching GitHub repositories
/// Encapsulates the business logic for repository search operations
/// Follows the Single Responsibility Principle and Clean Architecture patterns
class SearchRepositoriesUseCase {
  const SearchRepositoriesUseCase(this._repository);

  final GitHubRepositoryInterface _repository;

  /// Execute the search repositories use case
  /// 
  /// Validates input criteria and delegates to repository for data access
  /// Returns a UseCaseResult containing either success with repositories or failure with exception
  /// 
  /// Business rules:
  /// - Input criteria must be valid before processing
  /// - All exceptions are caught and mapped to domain exceptions
  /// - Result is always either success or failure, never both
  Future<UseCaseResult<List<GitHubRepository>>> execute(SearchCriteria criteria) async {
    // Input validation - business rule enforcement
    if (!criteria.isCompletelyValid) {
      return UseCaseResult.failure(
        InvalidSearchCriteriaException(criteria.validationError),
      );
    }

    try {
      // Delegate to repository for data access
      final result = await _repository.searchRepositories(criteria);
      
      // Return successful result with repository items
      return UseCaseResult.success(result.items);
    } catch (e) {
      // Map all exceptions to domain exceptions using ErrorMapper utility
      return UseCaseResult.failure(ErrorMapper.mapException(e));
    }
  }
}