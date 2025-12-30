import 'dart:async';
import 'dart:io';

import 'domain_exception.dart';

/// Utility class for mapping external exceptions to domain exceptions
/// Provides consistent error mapping across all layers of the application
/// Follows the requirements for meaningful error messages and proper error handling
class ErrorMapper {
  /// Map external exceptions to appropriate domain exceptions
  /// 
  /// This method ensures that all external errors are properly converted
  /// to domain exceptions with meaningful error messages for users
  /// 
  /// Requirements covered:
  /// - 6.2: Map external errors to appropriate domain exceptions
  /// - 6.3: Provide meaningful error messages for network errors
  static DomainException mapDataException(Exception exception) {
    if (exception is DomainException) {
      // Already a domain exception, pass through
      return exception;
    } else if (exception is SocketException) {
      return const NetworkException('No internet connection available');
    } else if (exception is HttpException) {
      return NetworkException('HTTP error: ${exception.message}');
    } else if (exception is FormatException) {
      return DataParsingException('Invalid data format: ${exception.message}');
    } else if (exception is TimeoutException) {
      return const NetworkException('Request timed out');
    } else {
      return UnknownException('An unexpected error occurred: ${exception.toString()}');
    }
  }

  /// Map any dynamic exception to domain exception
  /// Handles cases where the exception type is not known at compile time
  static DomainException mapException(dynamic exception) {
    if (exception is Exception) {
      return mapDataException(exception);
    } else if (exception is Error) {
      return UnknownException('System error: ${exception.toString()}');
    } else {
      return UnknownException('Unknown error: ${exception.toString()}');
    }
  }

  /// Get user-friendly error message from domain exception
  /// Provides structured error information suitable for presentation layer
  /// 
  /// Requirements covered:
  /// - 6.5: Provide structured error information for user feedback
  static String getUserFriendlyMessage(DomainException exception) {
    switch (exception.code) {
      case 'INVALID_SEARCH_CRITERIA':
        return 'Please enter a valid search term (at least 2 characters)';
      case 'REPOSITORY_NOT_FOUND':
        return 'The requested repository could not be found';
      case 'NETWORK_ERROR':
        return 'Unable to connect to GitHub. Please check your internet connection and try again.';
      case 'DATA_PARSING_ERROR':
        return 'There was a problem processing the data from GitHub. Please try again.';
      case 'UNKNOWN_ERROR':
        return 'An unexpected error occurred. Please try again later.';
      default:
        return exception.message;
    }
  }

  /// Check if an exception represents a network-related error
  /// Useful for determining retry strategies or fallback mechanisms
  static bool isNetworkError(DomainException exception) {
    return exception.code == 'NETWORK_ERROR';
  }

  /// Check if an exception represents a validation error
  /// Useful for handling user input validation feedback
  static bool isValidationError(DomainException exception) {
    return exception.code == 'INVALID_SEARCH_CRITERIA';
  }
}