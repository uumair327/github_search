import '../models/search_result_dto.dart';
import '../models/github_repository_dto.dart';

/// Abstract interface for local data sources (cache)
/// Defines contract for local data storage and retrieval
abstract class LocalDataSource {
  /// Get cached search result for a query
  /// Returns null if no cached result exists or cache is expired
  Future<SearchResultDto?> getSearchResult(String query);

  /// Cache search result for a query
  /// Stores the result with timestamp for expiration checking
  Future<void> cacheSearchResult(String query, SearchResultDto result);

  /// Get cached repository by ID
  /// Returns null if repository is not cached
  Future<GitHubRepositoryDto?> getRepositoryById(int id);

  /// Cache a specific repository
  /// Stores the repository with timestamp for expiration checking
  Future<void> cacheRepository(GitHubRepositoryDto repository);

  /// Clear all cached data
  Future<void> clearCache();

  /// Check if cached data for query is still valid
  /// Returns true if cache exists and is not expired
  Future<bool> isCacheValid(String query);

  /// Get cache expiration time in minutes
  /// Default implementation should return reasonable cache duration
  int get cacheExpirationMinutes => 15;
}