import '../../domain/entities/search_result.dart';
import '../../domain/entities/github_repository.dart';
import 'github_repository_dto.dart';

/// Data Transfer Object for GitHub search result data
/// Handles JSON serialization/deserialization and conversion to domain entities
class SearchResultDto {
  const SearchResultDto({
    required this.items,
    required this.totalCount,
    this.incompleteResults = false,
  });

  factory SearchResultDto.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((dynamic item) => GitHubRepositoryDto.fromJson(item as Map<String, dynamic>))
        .toList();
    
    return SearchResultDto(
      items: items,
      totalCount: json['total_count'] as int,
      incompleteResults: json['incomplete_results'] as bool? ?? false,
    );
  }

  final List<GitHubRepositoryDto> items;
  final int totalCount;
  final bool incompleteResults;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_count': totalCount,
      'incomplete_results': incompleteResults,
    };
  }

  /// Convert DTO to domain entity
  SearchResult<GitHubRepository> toDomain() {
    return SearchResult<GitHubRepository>(
      items: items.map((item) => item.toDomain()).toList(),
      totalCount: totalCount,
      incompleteResults: incompleteResults,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResultDto &&
          runtimeType == other.runtimeType &&
          _listEquals(items, other.items) &&
          totalCount == other.totalCount &&
          incompleteResults == other.incompleteResults;

  @override
  int get hashCode => items.hashCode ^ totalCount.hashCode ^ incompleteResults.hashCode;

  @override
  String toString() => 'SearchResultDto(items: ${items.length}, totalCount: $totalCount, incompleteResults: $incompleteResults)';

  /// Helper method to compare lists
  bool _listEquals<E>(List<E> a, List<E> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}