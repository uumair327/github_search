/// Generic search result container for paginated data
/// Encapsulates search results with metadata
class SearchResult<T> {
  const SearchResult({
    required this.items,
    required this.totalCount,
    this.incompleteResults = false,
  });

  final List<T> items;
  final int totalCount;
  final bool incompleteResults;

  /// Business rule: Result has items
  bool get hasItems => items.isNotEmpty;

  /// Business rule: Result indicates if there are more items available
  bool get hasMoreItems => totalCount > items.length;

  /// Business rule: Result is complete if not marked as incomplete
  bool get isComplete => !incompleteResults;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult<T> &&
          runtimeType == other.runtimeType &&
          _listEquals(items, other.items) &&
          totalCount == other.totalCount &&
          incompleteResults == other.incompleteResults;

  @override
  int get hashCode => items.hashCode ^ totalCount.hashCode ^ incompleteResults.hashCode;

  @override
  String toString() => 'SearchResult<$T>(items: ${items.length}, totalCount: $totalCount, incompleteResults: $incompleteResults)';

  /// Helper method to compare lists
  bool _listEquals<E>(List<E> a, List<E> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Create a copy with modified parameters
  SearchResult<T> copyWith({
    List<T>? items,
    int? totalCount,
    bool? incompleteResults,
  }) {
    return SearchResult<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      incompleteResults: incompleteResults ?? this.incompleteResults,
    );
  }
}