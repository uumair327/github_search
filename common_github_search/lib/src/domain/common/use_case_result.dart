/// Result wrapper for use case operations
/// Encapsulates success/failure states with proper error handling
abstract class UseCaseResult<T> {
  const UseCaseResult();

  /// Create a successful result with data
  factory UseCaseResult.success(T data) = _Success<T>;

  /// Create a failure result with exception
  factory UseCaseResult.failure(Exception exception) = _Failure<T>;

  /// Business rule: Result is either success or failure, never both
  bool get isSuccess;
  bool get isFailure => !isSuccess;

  /// Business rule: Successful results must have data
  bool get hasData;

  /// Business rule: Failed results must have exception
  bool get hasException;

  /// Get the data (only available for success results)
  T? get data;

  /// Get the exception (only available for failure results)
  Exception? get exception;

  /// Fold pattern for handling both success and failure cases
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Exception exception) onFailure,
  });

  /// Map the success value to a new type
  UseCaseResult<R> map<R>(R Function(T data) mapper);

  /// Chain multiple use case operations
  UseCaseResult<R> flatMap<R>(UseCaseResult<R> Function(T data) mapper);
}

/// Success implementation of UseCaseResult
class _Success<T> extends UseCaseResult<T> {
  const _Success(this._data);

  final T _data;

  @override
  bool get isSuccess => true;

  @override
  bool get hasData => true;

  @override
  bool get hasException => false;

  @override
  T? get data => _data;

  @override
  Exception? get exception => null;

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Exception exception) onFailure,
  }) {
    return onSuccess(_data);
  }

  @override
  UseCaseResult<R> map<R>(R Function(T data) mapper) {
    try {
      return UseCaseResult.success(mapper(_data));
    } catch (e) {
      return UseCaseResult.failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  UseCaseResult<R> flatMap<R>(UseCaseResult<R> Function(T data) mapper) {
    try {
      return mapper(_data);
    } catch (e) {
      return UseCaseResult.failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Success<T> &&
          runtimeType == other.runtimeType &&
          _data == other._data;

  @override
  int get hashCode => _data.hashCode;

  @override
  String toString() => 'UseCaseResult.success($_data)';
}

/// Failure implementation of UseCaseResult
class _Failure<T> extends UseCaseResult<T> {
  const _Failure(this._exception);

  final Exception _exception;

  @override
  bool get isSuccess => false;

  @override
  bool get hasData => false;

  @override
  bool get hasException => true;

  @override
  T? get data => null;

  @override
  Exception? get exception => _exception;

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Exception exception) onFailure,
  }) {
    return onFailure(_exception);
  }

  @override
  UseCaseResult<R> map<R>(R Function(T data) mapper) {
    return UseCaseResult.failure(_exception);
  }

  @override
  UseCaseResult<R> flatMap<R>(UseCaseResult<R> Function(T data) mapper) {
    return UseCaseResult.failure(_exception);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Failure<T> &&
          runtimeType == other.runtimeType &&
          _exception == other._exception;

  @override
  int get hashCode => _exception.hashCode;

  @override
  String toString() => 'UseCaseResult.failure($_exception)';
}