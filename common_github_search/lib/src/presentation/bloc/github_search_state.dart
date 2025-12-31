import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

sealed class GithubSearchState extends Equatable {
  const GithubSearchState();

  @override
  List<Object> get props => [];
}

final class SearchStateEmpty extends GithubSearchState {}

final class SearchStateLoading extends GithubSearchState {}

final class SearchStateSuccess extends GithubSearchState {
  const SearchStateSuccess(this.repositories);

  final List<GitHubRepository> repositories;

  @override
  List<Object> get props => [repositories];

  @override
  String toString() => 'SearchStateSuccess { repositories: ${repositories.length} }';
}

final class SearchStateError extends GithubSearchState {
  const SearchStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}