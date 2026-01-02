import 'package:flutter/material.dart';
import 'core/app.dart';

void main() {
  // Initialize the Clean Architecture dependencies
  initializeGitHubSearchApp();
  
  // Run the application
  runApp(const GitHubSearchApp());
}
