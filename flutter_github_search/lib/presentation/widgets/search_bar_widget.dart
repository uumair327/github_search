import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_github_search/common_github_search.dart';

/// Search bar widget following clean architecture presentation principles
/// Handles user input and dispatches events to BLoC
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _textController = TextEditingController();
  late GithubSearchBloc _githubSearchBloc;

  @override
  void initState() {
    super.initState();
    _githubSearchBloc = context.read<GithubSearchBloc>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _textController,
        autocorrect: false,
        onChanged: (text) {
          _githubSearchBloc.add(TextChanged(text: text));
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: GestureDetector(
            onTap: _onClearTapped,
            child: const Icon(Icons.clear),
          ),
          border: const OutlineInputBorder(),
          hintText: 'Enter a search term',
          labelText: 'Search GitHub Repositories',
        ),
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _githubSearchBloc.add(const TextChanged(text: ''));
  }
}