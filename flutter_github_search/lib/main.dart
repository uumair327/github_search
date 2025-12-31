import 'package:common_github_search/common_github_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_github_search/search_form.dart';

void main() {
  // Initialize the Clean Architecture dependencies
  initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Search',
      home: Scaffold(
        appBar: AppBar(title: const Text('GitHub Search')),
        body: BlocProvider(
          create: (context) => createGithubSearchBloc(),
          child: const SearchForm(),
        ),
      ),
    );
  }
}
