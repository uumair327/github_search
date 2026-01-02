// This is a shared library for common functionality between Flutter and Angular projects
// It should not contain Flutter-specific UI code or main() functions

// Export the main components of this library using the new Clean Architecture structure
export 'src/data/data_sources/remote/github_api_data_source.dart';
export 'src/data/repositories/github_repository_impl.dart';
export 'src/data/data_sources/local/in_memory_cache_data_source.dart';
export 'src/data/models/models.dart';
export 'src/presentation/bloc/github_search_bloc.dart';
