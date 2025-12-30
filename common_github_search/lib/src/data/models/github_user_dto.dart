import '../../domain/entities/github_user.dart';

/// Data Transfer Object for GitHub user data
/// Handles JSON serialization/deserialization and conversion to domain entities
class GitHubUserDto {
  const GitHubUserDto({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
  });

  factory GitHubUserDto.fromJson(Map<String, dynamic> json) {
    return GitHubUserDto(
      id: json['id'] as int,
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
    );
  }

  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
    };
  }

  /// Convert DTO to domain entity
  GitHubUser toDomain() {
    return GitHubUser(
      id: id,
      login: login,
      avatarUrl: avatarUrl,
      htmlUrl: htmlUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubUserDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          login == other.login &&
          avatarUrl == other.avatarUrl &&
          htmlUrl == other.htmlUrl;

  @override
  int get hashCode => id.hashCode ^ login.hashCode ^ avatarUrl.hashCode ^ htmlUrl.hashCode;

  @override
  String toString() => 'GitHubUserDto(id: $id, login: $login, avatarUrl: $avatarUrl, htmlUrl: $htmlUrl)';
}