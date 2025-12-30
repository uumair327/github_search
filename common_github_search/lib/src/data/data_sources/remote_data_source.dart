import '../../domain/entities/search_criteria.dart';
import '../models/search_result_dto.dart';
import '../models/github_repository_dto.dart';

/// Abstract interface for remote data sources
/// Defines contract for fetching data from external APIs
abstract class RemoteDataSource {
  /// Search for repositories based on criteria
  /// Throws exceptions for network errors, API errors, or parsing errors
  Future<SearchResultDto> searchRepositories(SearchCriteria criteria);

  /// Get a specific repository by ID
  /// Returns null if repository is not found
  /// Throws exceptions for network errors, API errors, or parsing errors
  Future<GitHubRepositoryDto?> getRepositoryById(int id);
}