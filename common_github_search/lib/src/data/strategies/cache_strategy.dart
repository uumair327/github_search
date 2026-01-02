import '../../domain/entities/entities.dart';
import '../data_sources/local_data_source.dart';

/// Strategy interface for cache management
/// Follows Strategy Pattern to separate caching concerns
abstract class CacheStrategy {
  Future<SearchResult<GitHubRepository>?> getCachedResult(String query);
  Future<void> cacheResult(String query, dynamic result);
  Future<SearchResult<GitHubRepository>?> getFallbackResult(String query);
}

/// Default cache strategy implementation
/// Separates caching logic from repository coordination
class DefaultCacheStrategy implements CacheStrategy {
  DefaultCacheStrategy(this._localDataSource);

  final LocalDataSource _localDataSource;

  @override
  Future<SearchResult<GitHubRepository>?> getCachedResult(String query) async {
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

  @override
  Future<void> cacheResult(String query, dynamic result) async {
    try {
      await _localDataSource.cacheSearchResult(query, result);
    } catch (e) {
      // Cache failures should not affect the main operation
      // Log error in production, but continue execution
    }
  }

  @override
  Future<SearchResult<GitHubRepository>?> getFallbackResult(String query) async {
    try {
      final cachedResult = await _localDataSource.getSearchResult(query);
      return cachedResult?.toDomain();
    } catch (e) {
      // If cache access fails completely, return null
      return null;
    }
  }
}

/// No-cache strategy for testing or when caching is disabled
class NoCacheStrategy implements CacheStrategy {
  @override
  Future<SearchResult<GitHubRepository>?> getCachedResult(String query) async => null;

  @override
  Future<void> cacheResult(String query, dynamic result) async {
    // No-op
  }

  @override
  Future<SearchResult<GitHubRepository>?> getFallbackResult(String query) async => null;
}