import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_github_search/common_github_search.dart';
import 'state_renderers/state_renderer_registry.dart';

/// Search results widget following clean architecture presentation principles
/// Displays different states based on BLoC state
/// 
/// SOLID Compliance Improvements:
/// - OCP: Uses renderer registry pattern - open for extension, closed for modification
/// - SRP: Single responsibility - coordinate state rendering
class SearchResultsWidget extends StatelessWidget {
  const SearchResultsWidget({super.key});

  // Static registry to avoid recreating renderers
  static final _rendererRegistry = StateRendererRegistry();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      builder: (context, state) {
        // Use registry to render state - follows OCP
        return _rendererRegistry.renderState(state);
      },
    );
  }
}