import 'dart:io';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:common_github_search/src/domain/domain.dart';

// Generate mocks
@GenerateMocks([GitHubRepositoryInterface])
import 'search_repositories_use_case_test.mocks.dart';

void main() {
  group('SearchRepositoriesUseCase', () {
    late SearchRepositoriesUseCase useCase;
    late MockGitHubRepositoryInterface mockRepository;

    setUp(() {
      mockRepository = MockGitHubRepositoryInterface();
      useCase = SearchRepositoriesUseCase(mockRepository);
    });

    group('Input Validation', () {
      test('should return failure for invalid search criteria', () async {
        // Arrange
        const invalidCriteria = SearchCriteria(query: ''); // Empty query is invalid

        // Act
        final result = await useCase.execute(invalidCriteria);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.exception, isA<InvalidSearchCriteriaException>());
        verifyNever(mockRepository.searchRepositories(any));
      });

      test('should return failure for query too short', () async {
        // Arrange
        const invalidCriteria = SearchCriteria(query: 'a'); // Single character is invalid

        // Act
        final result = await useCase.execute(invalidCriteria);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.exception, isA<InvalidSearchCriteriaException>());
        verifyNever(mockRepository.searchRepositories(any));
      });

      test('should return failure for invalid page number', () async {
        // Arrange
        const invalidCriteria = SearchCriteria(query: 'flutter', page: 0); // Page 0 is invalid

        // Act
        final result = await useCase.execute(invalidCriteria);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.exception, isA<InvalidSearchCriteriaException>());
        verifyNever(mockRepository.searchRepositories(any));
      });

      test('should return failure for invalid perPage number', () async {
        // Arrange
        const invalidCriteria = SearchCriteria(query: 'flutter', perPage: 0); // perPage 0 is invalid

        // Act
        final result = await useCase.execute(invalidCriteria);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.exception, isA<InvalidSearchCriteriaException>());
        verifyNever(mockRepository.searchRepositories(any));
      });
    });

    group('Successful Execution', () {
      test('should return success with repositories for valid criteria', () async {
        // Arrange
        const validCriteria = SearchCriteria(query: 'flutter');
        final mockRepositories = [
          GitHubRepository(
            id: 1,
            name: 'flutter',
            fullName: 'flutter/flutter',
            description: 'Flutter framework',
            owner: const GitHubUser(
              id: 1,
              login: 'flutter',
              avatarUrl: 'https://example.com/avatar.png',
              htmlUrl: 'https://github.com/flutter',
            ),
            stargazersCount: 1000,
            language: 'Dart',
            updatedAt: DateTime.now(),
            htmlUrl: 'https://github.com/flutter/flutter',
          ),
        ];
        final mockSearchResult = SearchResult<GitHubRepository>(
          items: mockRepositories,
          totalCount: 1,
          incompleteResults: false,
        );

        when(mockRepository.searchRepositories(validCriteria))
            .thenAnswer((_) async => mockSearchResult);

        // Act
        final result = await useCase.execute(validCriteria);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(mockRepositories));
        verify(mockRepository.searchRepositories(validCriteria)).called(1);
      });
    });

    group('Error Handling', () {
      test('should map domain exceptions correctly', () async {
        // Arrange
        const validCriteria = SearchCriteria(query: 'flutter');
        final domainException = const NetworkException('Network error');

        when(mockRepository.searchRepositories(validCriteria))
            .thenThrow(domainException);

        // Act
        final result = await useCase.execute(validCriteria);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.exception, equals(domainException));
      });

      test('should map SocketException to NetworkException', () async {
        // Arrange
        const validCriteria = SearchCriteria(query: 'flutter');
        final socketException = SocketException('No internet connection');

        when(mockRepository.searchRepositories(validCriteria))
            .thenThrow(socketException);

        // Act
        final result = await useCase.execute(validCriteria);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.exception, isA<NetworkException>());
        expect((result.exception! as DomainException).message, contains('No internet connection'));
      });

      test('should map FormatException to DataParsingException', () async {
        // Arrange
        const validCriteria = SearchCriteria(query: 'flutter');
        final formatException = FormatException('Invalid JSON');

        when(mockRepository.searchRepositories(validCriteria))
            .thenThrow(formatException);

        // Act
        final result = await useCase.execute(validCriteria);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.exception, isA<DataParsingException>());
        expect((result.exception! as DomainException).message, contains('Invalid data format'));
      });

      test('should map unknown exceptions to UnknownException', () async {
        // Arrange
        const validCriteria = SearchCriteria(query: 'flutter');
        final unknownException = Exception('Something went wrong');

        when(mockRepository.searchRepositories(validCriteria))
            .thenThrow(unknownException);

        // Act
        final result = await useCase.execute(validCriteria);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.exception, isA<UnknownException>());
        expect((result.exception! as DomainException).message, contains('An unexpected error occurred'));
      });
    });
  });
}