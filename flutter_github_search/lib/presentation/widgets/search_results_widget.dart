import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_github_search/common_github_search.dart';
import 'repository_item_widget.dart';

/// Search results widget following clean architecture presentation principles
/// Displays different states based on BLoC state
class SearchResultsWidget extends StatelessWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      builder: (context, state) {
        return switch (state) {
          SearchStateEmpty() => const _EmptyStateWidget(),
          SearchStateLoading() => const _LoadingStateWidget(),
          SearchStateError() => _ErrorStateWidget(error: state.error),
          SearchStateSuccess() => state.repositories.isEmpty
              ? const _NoResultsWidget()
              : _SuccessStateWidget(repositories: state.repositories),
        };
      },
    );
  }
}

/// Widget displayed when no search has been performed
class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Please enter a term to begin',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget displayed during search loading
class _LoadingStateWidget extends StatelessWidget {
  const _LoadingStateWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator.adaptive(),
          SizedBox(height: 16),
          Text('Searching repositories...'),
        ],
      ),
    );
  }
}

/// Widget displayed when an error occurs
class _ErrorStateWidget extends StatelessWidget {
  const _ErrorStateWidget({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget displayed when search returns no results
class _NoResultsWidget extends StatelessWidget {
  const _NoResultsWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Results',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget displayed when search is successful
class _SuccessStateWidget extends StatelessWidget {
  const _SuccessStateWidget({required this.repositories});

  final List<GitHubRepository> repositories;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: repositories.length,
      itemBuilder: (BuildContext context, int index) {
        return RepositoryItemWidget(repository: repositories[index]);
      },
    );
  }
}