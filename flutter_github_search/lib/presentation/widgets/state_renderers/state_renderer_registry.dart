import 'package:flutter/material.dart';
import 'package:common_github_search/common_github_search.dart';
import 'state_renderer.dart';

/// Registry for state renderers
/// Follows Open/Closed Principle - can add new renderers without modifying existing code
class StateRendererRegistry {
  StateRendererRegistry() {
    // Register default renderers
    _renderers.addAll([
      const EmptyStateRenderer(),
      const LoadingStateRenderer(),
      const ErrorStateRenderer(),
      const SuccessStateRenderer(),
    ]);
  }

  final List<StateRenderer> _renderers = [];

  /// Add a new renderer to the registry
  /// Allows extension without modification
  void addRenderer(StateRenderer renderer) {
    _renderers.add(renderer);
  }

  /// Find the appropriate renderer for the given state
  Widget renderState(GithubSearchState state) {
    for (final renderer in _renderers) {
      if (renderer.canHandle(state)) {
        return renderer.render(state);
      }
    }
    
    // Fallback renderer for unknown states
    return const Center(
      child: Text(
        'Unknown state',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}