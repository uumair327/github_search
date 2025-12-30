import '../entities/entities.dart';

/// Abstract repository interface for GitHub operations
/// Defines the contract for data access without implementation details
/// Follows the Repository pattern and Dependency Inversion Principle
abstract class GitHubRepositoryInterface {
  /// Search for GitHub repositories based on criteria
  /// Returns a SearchResult containing matching repositories
  /// Throws domain exceptions for business rule violations or data access errors
  Future<SearchResult<GitHubRepository>> searchRepositories(SearchCriteria criteria);

  /// Get a specific repository by its ID
  /// Returns null if repository is not found
  /// Throws domain exceptions for data access errors
  Future<GitHubRepository?> getRepositoryById(int id);

  /// Get repositories for a specific user
  /// Returns a list of repositories owned by the user
  /// Throws domain exceptions for business rule violations or data access errors
  Future<List<GitHubRepository>> getRepositoriesByUser(String username);
}