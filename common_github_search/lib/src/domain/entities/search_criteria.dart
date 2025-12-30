/// Value object for search criteria with validation logic
/// Encapsulates search parameters and business rules
class SearchCriteria {
  const SearchCriteria({
    required this.query,
    this.page = 1,
    this.perPage = 30,
  });

  final String query;
  final int page;
  final int perPage;

  /// Business rule: Query must be valid (non-empty and at least 2 characters)
  bool get isValid => query.trim().isNotEmpty && query.trim().length >= 2;

  /// Business rule: Page must be positive
  bool get hasValidPage => page > 0;

  /// Business rule: Per page must be within reasonable bounds
  bool get hasValidPerPage => perPage > 0 && perPage <= 100;

  /// Business rule: All criteria must be valid
  bool get isCompletelyValid => isValid && hasValidPage && hasValidPerPage;

  /// Get trimmed query for consistent processing
  String get trimmedQuery => query.trim();

  /// Validation error messages
  String? get validationError {
    if (!isValid) {
      return 'Query must be at least 2 characters long';
    }
    if (!hasValidPage) {
      return 'Page must be greater than 0';
    }
    if (!hasValidPerPage) {
      return 'Per page must be between 1 and 100';
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchCriteria &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => query.hashCode ^ page.hashCode ^ perPage.hashCode;

  @override
  String toString() => 'SearchCriteria(query: $query, page: $page, perPage: $perPage)';

  /// Create a copy with modified parameters
  SearchCriteria copyWith({
    String? query,
    int? page,
    int? perPage,
  }) {
    return SearchCriteria(
      query: query ?? this.query,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
    );
  }
}