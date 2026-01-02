import 'package:flutter/material.dart';
import 'package:common_github_search/common_github_search.dart';

/// Abstract base class for state renderers
/// Follows Open/Closed Principle - open for extension, closed for modification
abstract class StateRenderer {
  const StateRenderer();
  
  /// Check if this renderer can handle the given state
  bool canHandle(GithubSearchState state);
  
  /// Render the widget for the state
  Widget render(GithubSearchState state);
}

/// Renderer for empty state
class EmptyStateRenderer extends StateRenderer {
  const EmptyStateRenderer();
  
  @override
  bool canHandle(GithubSearchState state) => state is SearchStateEmpty;
  
  @override
  Widget render(GithubSearchState state) {
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

/// Renderer for loading state
class LoadingStateRenderer extends StateRenderer {
  const LoadingStateRenderer();
  
  @override
  bool canHandle(GithubSearchState state) => state is SearchStateLoading;
  
  @override
  Widget render(GithubSearchState state) {
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

/// Renderer for error state
class ErrorStateRenderer extends StateRenderer {
  const ErrorStateRenderer();
  
  @override
  bool canHandle(GithubSearchState state) => state is SearchStateError;
  
  @override
  Widget render(GithubSearchState state) {
    final errorState = state as SearchStateError;
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
          const Text(
            'Error',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorState.error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renderer for success state
class SuccessStateRenderer extends StateRenderer {
  const SuccessStateRenderer();
  
  @override
  bool canHandle(GithubSearchState state) => state is SearchStateSuccess;
  
  @override
  Widget render(GithubSearchState state) {
    final successState = state as SearchStateSuccess;
    
    if (successState.repositories.isEmpty) {
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
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: successState.repositories.length,
      itemBuilder: (context, index) {
        // Import the RepositoryItemWidget
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(successState.repositories[index].owner.avatarUrl),
            ),
            title: Text(successState.repositories[index].displayName),
            subtitle: successState.repositories[index].hasDescription 
                ? Text(successState.repositories[index].description)
                : null,
            trailing: const Icon(Icons.open_in_new),
          ),
        );
      },
    );
  }
}