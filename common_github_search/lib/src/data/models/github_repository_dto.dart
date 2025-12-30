import '../../domain/entities/github_repository.dart';
import 'github_user_dto.dart';

/// Data Transfer Object for GitHub repository data
/// Handles JSON serialization/deserialization and conversion to domain entities
class GitHubRepositoryDto {
  const GitHubRepositoryDto({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.owner,
    required this.stargazersCount,
    this.language,
    required this.updatedAt,
    required this.htmlUrl,
  });

  factory GitHubRepositoryDto.fromJson(Map<String, dynamic> json) {
    return GitHubRepositoryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      owner: GitHubUserDto.fromJson(json['owner'] as Map<String, dynamic>),
      stargazersCount: json['stargazers_count'] as int,
      language: json['language'] as String?,
      updatedAt: json['updated_at'] as String,
      htmlUrl: json['html_url'] as String,
    );
  }

  final int id;
  final String name;
  final String fullName;
  final String? description;
  final GitHubUserDto owner;
  final int stargazersCount;
  final String? language;
  final String updatedAt;
  final String htmlUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'owner': owner.toJson(),
      'stargazers_count': stargazersCount,
      'language': language,
      'updated_at': updatedAt,
      'html_url': htmlUrl,
    };
  }

  /// Convert DTO to domain entity
  GitHubRepository toDomain() {
    return GitHubRepository(
      id: id,
      name: name,
      fullName: fullName,
      description: description ?? '',
      owner: owner.toDomain(),
      stargazersCount: stargazersCount,
      language: language ?? '',
      updatedAt: DateTime.parse(updatedAt),
      htmlUrl: htmlUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubRepositoryDto &&
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
  String toString() => 'GitHubRepositoryDto(id: $id, name: $name, fullName: $fullName, '
      'description: $description, owner: $owner, stargazersCount: $stargazersCount, '
      'language: $language, updatedAt: $updatedAt, htmlUrl: $htmlUrl)';
}