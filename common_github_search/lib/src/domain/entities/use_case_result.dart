/// Result wrapper for use case operations
/// Encapsulates success/failure states with proper error handling
class UseCaseResult<T> {
  const UseCaseResult._({
    this.data,
    this.exception,
    required this.isSuccess,
  });

  final T? data;
  final Exception? exception;
  final bool isSuccess;

  /// Create a successful result with data
  factory UseCaseResult.success(T data) {
    return UseCaseResult._(
      data: data,
      exception: null,
      isSuccess: true,
    );
  }

  /// Create a failure result with exception
  factory UseCaseResult.failure(Exception exception) {
    return UseCaseResult._(
      data: null,
      exception: exception,
      isSuccess: false,
    );
  }

  /// Business rule: Result is either success or failure, never both
  bool get isFailure => !isSuccess;

  /// Business rule: Successful results must have data
  bool get hasData => isSuccess && data != null;

  /// Business rule: Failed results must have exception
  bool get hasException => isFailure && exception != null;

  /// Fold pattern for handling both success and failure cases
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Exception exception) onFailure,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data!);
    } else if (exception != null) {
      return onFailure(exception!);
    } else {
      throw StateError('UseCaseResult is in an invalid state');
    }
  }

  /// Map the success value to a new type
  UseCaseResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return UseCaseResult.success(mapper(data!));
      } catch (e) {
        return UseCaseResult.failure(e is Exception ? e : Exception(e.toString()));
      }
    } else if (exception != null) {
      return UseCaseResult.failure(exception!);
    } else {
      return UseCaseResult.failure(Exception('UseCaseResult is in an invalid state'));
    }
  }

  /// Chain multiple use case operations
  UseCaseResult<R> flatMap<R>(UseCaseResult<R> Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return mapper(data!);
      } catch (e) {
        return UseCaseResult.failure(e is Exception ? e : Exception(e.toString()));
      }
    } else if (exception != null) {
      return UseCaseResult.failure(exception!);
    } else {
      return UseCaseResult.failure(Exception('UseCaseResult is in an invalid state'));
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UseCaseResult<T> &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          exception == other.exception &&
          isSuccess == other.isSuccess;

  @override
  int get hashCode => data.hashCode ^ exception.hashCode ^ isSuccess.hashCode;

  @override
  String toString() {
    if (isSuccess) {
      return 'UseCaseResult.success($data)';
    } else {
      return 'UseCaseResult.failure($exception)';
    }
  }
}