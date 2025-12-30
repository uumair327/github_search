import 'dart:async';

import 'package:common_github_search/common_github_search.dart' hide SearchResult;
import '../../domain/entities/entities.dart';
import '../../domain/repositories/github_repository_interface.dart';
import '../../domain/exceptions/exceptions.dart';
import '../data_sources/remote_data_source.dart';
import '../data_sources/local_data_source.dart';
import '../models/search_result.dart' as legacy;

/// Concrete implementation of GitHubRepositoryInterface
/// Coordinates between remote and local data sources with caching strategy
/// Implements proper error mapping to domain exceptions
/// 
/// Requirements covered:
/// - 2.2: Implement concrete repository classes that fulfill domain contracts
/// - 2.3: Handle data source coordination and caching logic
/// - 2.5: Handle errors and provide fallback mechanisms
/// - 4.4: Implement proper error handling and mapping to domain exceptions
class GitHubRepositoryImpl implements GitHubRepositoryInterface {
  GitHubRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  @override
  Future<SearchResult<GitHubRepository>> searchRepositories(SearchCriteria criteria) async {
    try {
      // First, check if we have valid cached data
      final cachedResult = await _getCachedSearchResult(criteria.trimmedQuery);
      if (cachedResult != null) {
        return cachedResult;
      }

      // Fetch from remote data source
      final remoteResult = await _remoteDataSource.searchRepositories(criteria);
      
      // Cache the result for future use
      await _cacheSearchResult(criteria.trimmedQuery, remoteResult);
      
      // Convert DTO to domain entity and return
      return remoteResult.toDomain();
    } catch (e) {
      // Try fallback to cached data even if expired
      final fallbackResult = await _getFallbackCachedResult(criteria.trimmedQuery);
      if (fallbackResult != null) {
        return fallbackResult;
      }
      
      // Map exception to domain exception and rethrow
      throw ErrorMapper.mapException(e);
    }
  }

  @override
  Future<GitHubRepository?> getRepositoryById(int id) async {
    try {
      // Check cache first
      final cachedRepository = await _localDataSource.getRepositoryById(id);
      if (cachedRepository != null) {
        return cachedRepository.toDomain();
      }

      // Fetch from remote data source
      final remoteRepository = await _remoteDataSource.getRepositoryById(id);
      if (remoteRepository == null) {
        return null;
      }

      // Cache the repository
      await _localDataSource.cacheRepository(remoteRepository);
      
      // Convert DTO to domain entity and return
      return remoteRepository.toDomain();
    } catch (e) {
      // For individual repository lookup, try cached version as fallback
      final cachedRepository = await _localDataSource.getRepositoryById(id);
      if (cachedRepository != null) {
        return cachedRepository.toDomain();
      }
      
      // Map exception to domain exception and rethrow
      throw ErrorMapper.mapException(e);
    }
  }

  @override
  Future<List<GitHubRepository>> getRepositoriesByUser(String username) async {
    // This method is not implemented in the current data sources
    // but is part of the domain interface for future extensibility
    throw UnimplementedError('getRepositoriesByUser is not yet implemented');
  }

  /// Get cached search result if valid
  /// Returns null if no cache exists or cache is expired
  Future<SearchResult<GitHubRepository>?> _getCachedSearchResult(String query) async {
    try {
      final isValid = await _localDataSource.isCacheValid(query);
      if (!isValid) {
        return null;
      }

      final cachedResult = await _localDataSource.getSearchResult(query);
      return cachedResult?.toDomain();
    } catch (e) {
      // If cache access fails, continue without cache
      return null;
    }
  }

  /// Get cached search result as fallback, even if expired
  /// Used when remote data source fails
  Future<SearchResult<GitHubRepository>?> _getFallbackCachedResult(String query) async {
    try {
      final cachedResult = await _localDataSource.getSearchResult(query);
      return cachedResult?.toDomain();
    } catch (e) {
      // If cache access fails completely, return null
      return null;
    }
  }

  /// Cache search result for future use
  /// Handles caching errors gracefully without affecting main flow
  Future<void> _cacheSearchResult(String query, dynamic result) async {
    try {
      await _localDataSource.cacheSearchResult(query, result);
    } catch (e) {
      // Cache failures should not affect the main operation
      // Log error in production, but continue execution
    }
  }
}

// TEMPORARY: Legacy compatibility class for existing BLoC
// This will be removed in task 11.1 when BLoC is refactored to use Clean Architecture
// For now, this maintains backward compatibility with the existing presentation layer
class GithubRepository {
  GithubRepository({InMemoryCacheDataSource? cache, GitHubApiDataSource? client})
    : _client = client ?? GitHubApiDataSource();

  final GitHubApiDataSource _client;

  Future<legacy.SearchResult> search(String term) async {
    // Temporary implementation for backward compatibility
    // This delegates to the new API client with proper conversion
    final criteria = SearchCriteria(query: term);
    final result = await _client.searchRepositories(criteria);
    
    // Convert the new DTO format to the legacy format
    final legacyItems = result.items.map((dto) => SearchResultItem(
      fullName: dto.fullName,
      htmlUrl: dto.htmlUrl,
      owner: GithubUser(
        login: dto.owner.login,
        avatarUrl: dto.owner.avatarUrl,
      ),
    )).toList();
    
    return legacy.SearchResult(items: legacyItems);
  }

  void dispose() {
    _client.close();
  }
}