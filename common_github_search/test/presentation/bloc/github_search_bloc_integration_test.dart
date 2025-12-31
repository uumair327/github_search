import 'package:test/test.dart';
import 'package:common_github_search/common_github_search.dart';

void main() {
  group('GithubSearchBloc Clean Architecture Integration', () {
    setUp(() {
      // Reset and initialize the DI container with all dependencies
      resetApp();
      initializeApp();
    });

    tearDown(() {
      // Clean up after each test
      resetApp();
    });

    test('can be instantiated with use case from DI container', () {
      // Arrange & Act
      final useCase = getDependency<SearchRepositoriesUseCase>();
      final bloc = GithubSearchBloc(searchRepositoriesUseCase: useCase);

      // Assert
      expect(bloc, isA<GithubSearchBloc>());
      expect(bloc.state, isA<SearchStateEmpty>());

      // Cleanup
      bloc.close();
    });

    test('can be created using factory method', () {
      // Arrange & Act
      final bloc = createGithubSearchBloc();

      // Assert
      expect(bloc, isA<GithubSearchBloc>());
      expect(bloc.state, isA<SearchStateEmpty>());

      // Cleanup
      bloc.close();
    });

    test('initial state is SearchStateEmpty', () {
      // Arrange
      final useCase = getDependency<SearchRepositoriesUseCase>();
      final bloc = GithubSearchBloc(searchRepositoriesUseCase: useCase);

      // Act & Assert
      expect(bloc.state, equals(SearchStateEmpty()));

      // Cleanup
      bloc.close();
    });

    test('can handle TextChanged event without throwing', () async {
      // Arrange
      final useCase = getDependency<SearchRepositoriesUseCase>();
      final bloc = GithubSearchBloc(searchRepositoriesUseCase: useCase);

      // Act - This should not throw an exception
      bloc.add(const TextChanged(text: ''));
      
      // Wait a bit for the event to be processed
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should still be in empty state for empty text
      expect(bloc.state, isA<SearchStateEmpty>());

      // Cleanup
      bloc.close();
    });

    test('dependencies are properly registered', () {
      // Assert that all required dependencies are registered
      expect(isDependencyRegistered<SearchRepositoriesUseCase>(), isTrue);
      expect(isDependencyRegistered<GitHubRepositoryInterface>(), isTrue);
      expect(isDependencyRegistered<RemoteDataSource>(), isTrue);
      expect(isDependencyRegistered<LocalDataSource>(), isTrue);
    });
  });
}