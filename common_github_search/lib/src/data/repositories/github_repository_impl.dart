import 'dart:async';

import '../../domain/entities/entities.dart';
import '../../domain/exceptions/exceptions.dart';
import '../../domain/repositories/github_repository_interface.dart';
import '../data_sources/local_data_source.dart';
import '../data_sources/remote_data_source.dart';
import '../strategies/cache_strategy.dart';

/// Concrete implementation of GitHubRepositoryInterface
/// Coordinates between remote and local data sources with caching strategy
/// Implements proper error mapping to domain exceptions
/// 
/// SOLID Compliance:
/// - SRP: Single responsibility - coordinate data access (improved with strategy pattern)
/// - OCP: Open for extension through strategy pattern
/// - LSP: Properly implements GitHubRepositoryInterface
/// - ISP: Depends only on needed interfaces
/// - DIP: Depends on abstractions (RemoteDataSource, CacheStrategy)
class GitHubRepositoryImpl implements GitHubRepositoryInterface {
  GitHubRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    CacheStrategy? cacheStrategy,
    LocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _cacheStrategy = cacheStrategy ?? 
            (localDataSource != null ? DefaultCacheStrategy(localDataSource) : NoCacheStrategy());

  final RemoteDataSource _remoteDataSource;
  final CacheStrategy _cacheStrategy;

  @override
  Future<SearchResult<GitHubRepository>> searchRepositories(SearchCriteria criteria) async {
    try {
      // Check cache first using strategy
      final cachedResult = await _cacheStrategy.getCachedResult(criteria.trimmedQuery);
      if (cachedResult != null) {
        return cachedResult;
      }

      // Fetch from remote data source
      final remoteResult = await _remoteDataSource.searchRepositories(criteria);
      
      // Cache the result using strategy
      await _cacheStrategy.cacheResult(criteria.trimmedQuery, remoteResult);
      
      // Convert DTO to domain entity and return
      return remoteResult.toDomain();
    } catch (e) {
      // Try fallback using strategy
      final fallbackResult = await _cacheStrategy.getFallbackResult(criteria.trimmedQuery);
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
      // For individual repository lookup, we could implement caching here too
      // but keeping it simple for now as per original design
      final remoteRepository = await _remoteDataSource.getRepositoryById(id);
      if (remoteRepository == null) {
        return null;
      }

      // Convert DTO to domain entity and return
      return remoteRepository.toDomain();
    } catch (e) {
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
}