import 'package:flutter/material.dart';
import 'package:common_github_search/common_github_search.dart';
import 'package:url_launcher/url_launcher.dart';

/// Repository item widget following clean architecture presentation principles
/// Displays a single repository with proper business logic usage
class RepositoryItemWidget extends StatelessWidget {
  const RepositoryItemWidget({
    super.key,
    required this.repository,
  });

  final GitHubRepository repository;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(repository.owner.avatarUrl),
          onBackgroundImageError: (exception, stackTrace) {
            // Handle image loading error gracefully
          },
          child: repository.owner.hasValidAvatarUrl
              ? null
              : const Icon(Icons.person),
        ),
        title: Text(
          repository.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repository.hasDescription)
              Text(
                repository.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (repository.hasLanguage) ...[
                  Icon(
                    Icons.code,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repository.language,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  Icons.star,
                  size: 16,
                  color: repository.isPopular ? Colors.amber : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  repository.stargazersCount.toString(),
                  style: TextStyle(
                    color: repository.isPopular ? Colors.amber[700] : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: repository.isPopular ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (repository.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _launchRepository(repository.htmlUrl),
      ),
    );
  }

  Future<void> _launchRepository(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}