import 'package:flutter/material.dart';
import 'package:common_github_search/common_github_search.dart';
import '../presentation/presentation.dart';

/// Main application widget following clean architecture principles
/// Handles app initialization and provides the root widget
class GitHubSearchApp extends StatelessWidget {
  const GitHubSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SearchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Initialize the application with proper clean architecture setup
void initializeGitHubSearchApp() {
  // Initialize the Clean Architecture dependencies from common library
  initializeApp();
}