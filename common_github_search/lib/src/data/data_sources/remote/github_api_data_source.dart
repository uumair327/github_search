import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../domain/entities/search_criteria.dart';
import '../../../domain/exceptions/exceptions.dart';
import '../../models/search_result_dto.dart';
import '../../models/github_repository_dto.dart';
import '../remote_data_source.dart';

/// Implementation of RemoteDataSource using GitHub API
/// Handles HTTP requests, error handling, and response parsing
class GitHubApiDataSource implements RemoteDataSource {
  GitHubApiDataSource({
    http.Client? httpClient,
    this.baseUrl = 'https://api.github.com',
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  @override
  Future<SearchResultDto> searchRepositories(SearchCriteria criteria) async {
    try {
      // Build search URL with parameters
      final queryParams = {
        'q': criteria.trimmedQuery,
        'page': criteria.page.toString(),
        'per_page': criteria.perPage.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/search/repositories').replace(
        queryParameters: queryParams,
      );

      // Make HTTP request with timeout
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 30));

      // Handle response based on status code
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return SearchResultDto.fromJson(jsonData);
      } else if (response.statusCode == 403) {
        // Rate limit exceeded
        throw const NetworkException('API rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 422) {
        // Validation failed (invalid query)
        throw const InvalidSearchCriteriaException('Invalid search query format');
      } else if (response.statusCode >= 500) {
        // Server error
        throw const NetworkException('GitHub API is currently unavailable');
      } else {
        // Other client errors
        final errorBody = response.body.isNotEmpty ? response.body : 'Unknown error';
        throw NetworkException('API request failed with status ${response.statusCode}: $errorBody');
      }
    } on TimeoutException {
      throw const NetworkException('Request timed out');
    } on SocketException {
      throw const NetworkException('No internet connection available');
    } on FormatException catch (e) {
      throw DataParsingException('Failed to parse API response: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error: ${e.message}');
    } catch (e) {
      // Map any other exceptions using ErrorMapper
      throw ErrorMapper.mapException(e);
    }
  }

  @override
  Future<GitHubRepositoryDto?> getRepositoryById(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/repositories/$id');

      // Make HTTP request with timeout
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 30));

      // Handle response based on status code
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return GitHubRepositoryDto.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // Repository not found
        return null;
      } else if (response.statusCode == 403) {
        // Rate limit exceeded
        throw const NetworkException('API rate limit exceeded. Please try again later.');
      } else if (response.statusCode >= 500) {
        // Server error
        throw const NetworkException('GitHub API is currently unavailable');
      } else {
        // Other client errors
        final errorBody = response.body.isNotEmpty ? response.body : 'Unknown error';
        throw NetworkException('API request failed with status ${response.statusCode}: $errorBody');
      }
    } on TimeoutException {
      throw const NetworkException('Request timed out');
    } on SocketException {
      throw const NetworkException('No internet connection available');
    } on FormatException catch (e) {
      throw DataParsingException('Failed to parse API response: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP error: ${e.message}');
    } catch (e) {
      // Map any other exceptions using ErrorMapper
      throw ErrorMapper.mapException(e);
    }
  }

  /// Close the HTTP client and release resources
  void close() {
    _httpClient.close();
  }
}