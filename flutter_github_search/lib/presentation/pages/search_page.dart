import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_github_search/common_github_search.dart';
import '../widgets/widgets.dart';

/// Main search page following clean architecture presentation layer principles
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocProvider(
        create: (context) => createGithubSearchBloc(),
        child: const SearchPageBody(),
      ),
    );
  }
}

/// Body of the search page with proper widget composition
class SearchPageBody extends StatelessWidget {
  const SearchPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        SearchBarWidget(),
        Expanded(child: SearchResultsWidget()),
      ],
    );
  }
}