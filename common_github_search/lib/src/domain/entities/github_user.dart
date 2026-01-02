/// Domain entity representing a GitHub user
/// Contains core business logic and validation rules
class GitHubUser {
  const GitHubUser({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
  });

  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  

  /// Business rule: User login must be valid
  bool get hasValidLogin => login.isNotEmpty && login.trim().length > 0;

  /// Business rule: Avatar URL should be a valid URL
  bool get hasValidAvatarUrl => avatarUrl.isNotEmpty && Uri.tryParse(avatarUrl) != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          login == other.login &&
          avatarUrl == other.avatarUrl &&
          htmlUrl == other.htmlUrl;

  @override
  int get hashCode => id.hashCode ^ login.hashCode ^ avatarUrl.hashCode ^ htmlUrl.hashCode;

  @override
  String toString() => 'GitHubUser(id: $id, login: $login, avatarUrl: $avatarUrl, htmlUrl: $htmlUrl)';
}