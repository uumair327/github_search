/// Base class for all domain exceptions
/// Provides consistent error structure across the domain layer
abstract class DomainException implements Exception {
  const DomainException(this.message, this.code);

  final String message;
  final String code;

  @override
  String toString() => 'DomainException($code): $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DomainException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Exception thrown when search criteria validation fails
class InvalidSearchCriteriaException extends DomainException {
  const InvalidSearchCriteriaException([String? details])
      : super(
          details ?? 'Search criteria is invalid',
          'INVALID_SEARCH_CRITERIA',
        );
}

/// Exception thrown when a repository is not found
class RepositoryNotFoundException extends DomainException {
  const RepositoryNotFoundException(int id)
      : super(
          'Repository with id $id not found',
          'REPOSITORY_NOT_FOUND',
        );
}

/// Exception thrown when network operations fail
class NetworkException extends DomainException {
  const NetworkException(String details)
      : super(
          'Network error occurred: $details',
          'NETWORK_ERROR',
        );
}

/// Exception thrown when data parsing fails
class DataParsingException extends DomainException {
  const DataParsingException(String details)
      : super(
          'Data parsing error: $details',
          'DATA_PARSING_ERROR',
        );
}

/// Exception thrown for unknown/unexpected errors
class UnknownException extends DomainException {
  const UnknownException(String details)
      : super(
          'An unexpected error occurred: $details',
          'UNKNOWN_ERROR',
        );
}