import '../../models/search_result_dto.dart';
import '../../models/github_repository_dto.dart';
import '../local_data_source.dart';

/// In-memory implementation of LocalDataSource
/// Provides caching functionality with expiration support
class InMemoryCacheDataSource implements LocalDataSource {
  InMemoryCacheDataSource({
    this.cacheExpirationMinutes = 15,
  });

  @override
  final int cacheExpirationMinutes;

  // Cache storage with timestamps
  final Map<String, _CachedSearchResult> _searchCache = {};
  final Map<int, _CachedRepository> _repositoryCache = {};

  @override
  Future<SearchResultDto?> getSearchResult(String query) async {
    final cachedResult = _searchCache[query.toLowerCase()];
    
    if (cachedResult == null) {
      return null;
    }

    // Check if cache is expired
    if (_isCacheExpired(cachedResult.timestamp)) {
      _searchCache.remove(query.toLowerCase());
      return null;
    }

    return cachedResult.data;
  }

  @override
  Future<void> cacheSearchResult(String query, SearchResultDto result) async {
    _searchCache[query.toLowerCase()] = _CachedSearchResult(
      data: result,
      timestamp: DateTime.now(),
    );

    // Also cache individual repositories for faster access
    for (final repo in result.items) {
      await cacheRepository(repo);
    }
  }

  @override
  Future<GitHubRepositoryDto?> getRepositoryById(int id) async {
    final cachedRepo = _repositoryCache[id];
    
    if (cachedRepo == null) {
      return null;
    }

    // Check if cache is expired
    if (_isCacheExpired(cachedRepo.timestamp)) {
      _repositoryCache.remove(id);
      return null;
    }

    return cachedRepo.data;
  }

  @override
  Future<void> cacheRepository(GitHubRepositoryDto repository) async {
    _repositoryCache[repository.id] = _CachedRepository(
      data: repository,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<void> clearCache() async {
    _searchCache.clear();
    _repositoryCache.clear();
  }

  @override
  Future<bool> isCacheValid(String query) async {
    final cachedResult = _searchCache[query.toLowerCase()];
    
    if (cachedResult == null) {
      return false;
    }

    return !_isCacheExpired(cachedResult.timestamp);
  }

  /// Check if a timestamp is expired based on cache expiration time
  bool _isCacheExpired(DateTime timestamp) {
    final now = DateTime.now();
    final expirationTime = timestamp.add(Duration(minutes: cacheExpirationMinutes));
    return now.isAfter(expirationTime);
  }

  /// Get cache statistics for debugging/monitoring
  Map<String, dynamic> getCacheStats() {
    int validSearchEntries = 0;
    int expiredSearchEntries = 0;
    int validRepoEntries = 0;
    int expiredRepoEntries = 0;

    // Count search cache entries
    for (final entry in _searchCache.values) {
      if (_isCacheExpired(entry.timestamp)) {
        expiredSearchEntries++;
      } else {
        validSearchEntries++;
      }
    }

    // Count repository cache entries
    for (final entry in _repositoryCache.values) {
      if (_isCacheExpired(entry.timestamp)) {
        expiredRepoEntries++;
      } else {
        validRepoEntries++;
      }
    }

    return {
      'searchCache': {
        'valid': validSearchEntries,
        'expired': expiredSearchEntries,
        'total': _searchCache.length,
      },
      'repositoryCache': {
        'valid': validRepoEntries,
        'expired': expiredRepoEntries,
        'total': _repositoryCache.length,
      },
      'cacheExpirationMinutes': cacheExpirationMinutes,
    };
  }

  /// Clean up expired entries from cache
  Future<void> cleanupExpiredEntries() async {
    // Remove expired search results
    final expiredSearchKeys = <String>[];
    for (final entry in _searchCache.entries) {
      if (_isCacheExpired(entry.value.timestamp)) {
        expiredSearchKeys.add(entry.key);
      }
    }
    for (final key in expiredSearchKeys) {
      _searchCache.remove(key);
    }

    // Remove expired repositories
    final expiredRepoKeys = <int>[];
    for (final entry in _repositoryCache.entries) {
      if (_isCacheExpired(entry.value.timestamp)) {
        expiredRepoKeys.add(entry.key);
      }
    }
    for (final key in expiredRepoKeys) {
      _repositoryCache.remove(key);
    }
  }
}

/// Internal class to store cached search results with timestamps
class _CachedSearchResult {
  const _CachedSearchResult({
    required this.data,
    required this.timestamp,
  });

  final SearchResultDto data;
  final DateTime timestamp;
}

/// Internal class to store cached repositories with timestamps
class _CachedRepository {
  const _CachedRepository({
    required this.data,
    required this.timestamp,
  });

  final GitHubRepositoryDto data;
  final DateTime timestamp;
}