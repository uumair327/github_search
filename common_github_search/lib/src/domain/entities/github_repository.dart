import 'github_user.dart';

/// Domain entity representing a GitHub repository
/// Contains core business logic and validation rules
class GitHubRepository {
  const GitHubRepository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.owner,
    required this.stargazersCount,
    required this.language,
    required this.updatedAt,
    required this.htmlUrl,
  });

  final int id;
  final String name;
  final String fullName;
  final String description;
  final GitHubUser owner;
  final int stargazersCount;
  final String language;
  final DateTime updatedAt;
  final String htmlUrl;

  /// Business logic: Repository is considered popular if it has more than 1000 stars
  bool get isPopular => stargazersCount > 1000;

  /// Business logic: Display name prioritizes full name over name
  String get displayName => fullName.isNotEmpty ? fullName : name;

  /// Business logic: Repository is considered active if updated within last 6 months
  bool get isActive {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return updatedAt.isAfter(sixMonthsAgo);
  }

  /// Business logic: Repository has a programming language
  bool get hasLanguage => language.isNotEmpty;

  /// Business logic: Repository has a description
  bool get hasDescription => description.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubRepository &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          fullName == other.fullName &&
          description == other.description &&
          owner == other.owner &&
          stargazersCount == other.stargazersCount &&
          language == other.language &&
          updatedAt == other.updatedAt &&
          htmlUrl == other.htmlUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      fullName.hashCode ^
      description.hashCode ^
      owner.hashCode ^
      stargazersCount.hashCode ^
      language.hashCode ^
      updatedAt.hashCode ^
      htmlUrl.hashCode;

  @override
  String toString() => 'GitHubRepository(id: $id, name: $name, fullName: $fullName, '
      'description: $description, owner: $owner, stargazersCount: $stargazersCount, '
      'language: $language, updatedAt: $updatedAt, htmlUrl: $htmlUrl)';
}