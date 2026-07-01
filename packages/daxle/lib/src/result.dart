import 'package:daxle/src/either.dart';
import 'package:daxle/src/option.dart';
import 'package:meta/meta.dart';

/// {@template result}
/// Represents the result of an operation that can succeed or fail.
///
/// A `Result<T, E>` can be either:
/// - `Ok(value)`, representing a successful operation with a value of type [T].
/// - `Err(error)`, representing a failed operation with an [error] of type [E].
///
/// Use `Result<T, E>` to make success and failure explicit instead of relying on exceptions.
/// This is similar to `Result`/`Either` types in functional languages like Rust or Haskell.
///
/// Example:
/// ```dart
/// Result<int, String> a = .ok(10);
/// Result<int, String> b = .err("Failed");
///
/// print(a.isOk); // true
/// print(b.isErr); // true
/// ```
/// {@endtemplate}
@immutable
sealed class Result<T, E> {
  /// {@macro result}
  const Result();

  /// {@template result_ok}
  /// Creates a `Result` representing a successful operation.
  ///
  /// This is equivalent to constructing an `Ok(value)`.
  ///
  /// Example:
  /// ```dart
  /// Result<int, String> x = .ok(5); // Ok(5)
  /// print(x.isOk); // true
  /// ```
  /// {@endtemplate}
  const factory Result.ok(T value) = Ok<T, E>;

  /// {@template result_err}
  /// Creates a `Result` representing a failed operation.
  ///
  /// This is equivalent to constructing an `Err(error, [stackTrace])`.
  ///
  /// Example:
  /// ```dart
  /// Result<int, String> y = .err("Oops"); // Err
  /// print(y.isErr); // true
  /// ```
  /// {@endtemplate}
  const factory Result.err(E err, [StackTrace? stackTrace]) = Err<T, E>;

  /// Creates a `Result<R, E>` from a synchronous function `f`.
  ///
  /// If `f` returns a value, this returns `Ok(value)`.
  ///
  /// If `f` throws an error, the behavior depends on the `onError` callback:
  /// - If `onError` is provided, it is called with the caught error,
  ///   and this returns an `Err` with the result.
  /// - If `onError` is **not** provided, this attempts to cast the caught
  ///   error to `E` and returns an `Err` with the casted value.
  ///
  /// **Warning:** If `onError` is not provided and the caught error cannot be
  /// cast to `E`, a `TypeError` will be thrown.
  ///
  /// `Error` objects are always re-thrown, unless explicitly handled in `onError` callback.
  ///
  /// Example with `onError`:
  /// ```dart
  /// final result = Result.from<int, String>(
  ///   () => throw Exception('Network error'),
  ///   onError: (e) => 'Failed to fetch: $e',
  /// );
  /// // result is Err('Failed to fetch: Exception: Network error')
  /// ```
  ///
  /// Example without `onError` (unsafe):
  /// ```dart
  /// final result = Result.from<int, String>(
  ///   () => throw 'An error occurred',
  /// );
  /// // result is Err('An error occurred')
  /// ```
  static Result<R, E> from<R, E>(
    R Function() f, {
    E Function(Object)? onError,
  }) {
    try {
      return .ok(f());
    } catch (err, stackTrace) {
      if (onError != null) {
        return .err(onError(err), stackTrace);
      }

      if (err is Error) rethrow;
      return .err(err as E, stackTrace);
    }
  }

  /// Creates a `Result<R, E>` from an asynchronous function `f`.
  ///
  /// If `f` completes with a value, this returns `Ok(value)`.
  ///
  /// If `f` throws an error, the behavior depends on the `onError` callback:
  /// - If `onError` is provided, it is called with the caught error,
  ///   and this returns an `Err` with the result.
  /// - If `onError` is **not** provided, this attempts to cast the caught
  ///   error to `E` and returns an `Err` with the casted value.
  ///
  /// **Warning:** If `onError` is not provided and the caught error cannot be
  /// cast to `E`, a `TypeError` will be thrown.
  ///
  /// `Error` objects are always re-thrown, unless explicitly handled in `onError` callback.
  ///
  /// Example with `onError`:
  /// ```dart
  /// final result = await Result.fromAsync<int, String>(
  ///   () async => throw Exception('Network error'),
  ///   onError: (e) => 'Failed to fetch: $e',
  /// );
  /// // result is Err('Failed to fetch: Exception: Network error')
  /// ```
  ///
  /// Example without `onError` (unsafe):
  /// ```dart
  /// final result = await Result.fromAsync<int, String>(
  ///   () async => throw 'An error occurred',
  /// );
  /// // result is Err('An error occurred')
  /// ```
  static Future<Result<R, E>> fromAsync<R, E>(
    Future<R> Function() f, {
    E Function(Object)? onError,
  }) async {
    try {
      return .ok(await f());
    } catch (err, stackTrace) {
      if (onError != null) {
        return .err(onError(err), stackTrace);
      }

      if (err is Error) rethrow;
      return .err(err as E, stackTrace);
    }
  }

  /// Returns `true` if this `Result` is `Ok`.
  bool get isOk;

  /// Returns `true` if this `Result` is `Err`.
  bool get isErr;

  /// Returns the value inside `Ok`, or evaluates and returns [orElse] if `Err`.
  T getOrElse(T Function(E error) orElse);

  /// Returns the value inside `Ok`, or throws the original error (with stack trace) if `Err`.
  ///
  /// Example:
  /// ```dart
  /// final result = .ok(5);
  /// print(result.unwrap()); // 5
  ///
  /// final failure = Result<int, Exception>.err(Exception("Oops"));
  /// failure.unwrap(); // throws Exception("Oops")
  /// ```
  @useResult
  T unwrap();

  /// Maps the error inside `Err` using [f], leaves `Ok` unchanged.
  @useResult
  Result<T, F> mapErr<F>(F Function(E error) f);

  /// Maps the value inside `Ok` using [f], leaves `Err` unchanged.
  @useResult
  Result<R, E> map<R>(R Function(T value) f);

  /// Flat-maps the value inside `Ok` using [f], leaves `Err` unchanged.
  @useResult
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) f);

  /// Fold the `Result` into a single value.
  ///
  /// Runs [onOk] if `Ok` or [onErr] if `Err`.
  @useResult
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(E error, StackTrace? stackTrace) onErr,
  });

  /// Returns `this` if `Ok`, otherwise evaluates and returns the result of [f] if `Err`.
  @useResult
  Result<T, E> orElse(Result<T, E> Function(E error, StackTrace? stackTrace) f);

  /// Returns the value inside `Ok`, or throws a [StateError] with [message] if `Err`.
  T expect(String message);

  /// Transforms [this] into [Option], `Ok(value)` becomes `Some(value)` and `Err` becomes `None`.
  ///
  /// Example:
  /// ```dart
  /// final result = .ok(5);
  /// print(result.unwrap()); // 5
  ///
  /// final option = result.toOption(); // Some(5)
  /// ```
  Option<T> toOption();

  /// Transforms [this] into [Either], `Ok(value)` becomes `Right(value)` and `Err` becomes `Left(error)`.
  ///
  /// Example:
  /// ```dart
  /// final result = .ok(5);
  /// print(result.unwrap()); // 5
  ///
  /// final either = result.toEither(); // Either.Right(5)
  /// ```
  Either<E, T> toEither();
}

/// {@template ok}
/// Represents a successful `Result` containing a value.
/// {@endtemplate}
@immutable
final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);

  final T value;

  @override
  bool get isOk => true;

  @override
  bool get isErr => false;

  @override
  T unwrap() => value;

  @override
  T expect(String message) => value;

  @override
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) f) => f(value);

  @override
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(E error, StackTrace? stackTrace) onErr,
  }) => onOk(value);

  @override
  T getOrElse(T Function(E error) orElse) => value;

  @override
  Result<R, E> map<R>(R Function(T value) f) => Ok<R, E>(f(value));

  @override
  Result<T, F> mapErr<F>(F Function(E error) f) => Ok<T, F>(value);

  @override
  Result<T, E> orElse(
    Result<T, E> Function(E error, StackTrace? stackTrace) f,
  ) => this;

  @override
  Option<T> toOption() => .some(value);

  @override
  Either<E, T> toEither() => .right(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Ok<T, E> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Ok($value)';
}

/// {@template err}
/// Represents a failed `Result` containing an error and optional stack trace.
/// {@endtemplate}
@immutable
final class Err<T, E> extends Result<T, E> {
  const Err(this.error, [this.stackTrace]);

  final E error;

  final StackTrace? stackTrace;

  @override
  bool get isOk => false;

  @override
  bool get isErr => true;

  @override
  T unwrap() => Error.throwWithStackTrace(
    error as Object,
    stackTrace ?? StackTrace.current,
  );

  @override
  T expect(String message) {
    final buffer = StringBuffer("Result.err: $message");

    buffer.writeln("\nSource: ${Error.safeToString(error)}");
    if (stackTrace != null) buffer.writeln("\nStackTrace: $stackTrace");

    throw StateError(buffer.toString());
  }

  @override
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) f) =>
      Err<R, E>(error, stackTrace);

  @override
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(E error, StackTrace? stackTrace) onErr,
  }) => onErr(error, stackTrace);

  @override
  T getOrElse(T Function(E error) orElse) => orElse(error);

  @override
  Result<R, E> map<R>(R Function(T value) f) => Err<R, E>(error, stackTrace);

  @override
  Result<T, F> mapErr<F>(F Function(E error) f) =>
      Err<T, F>(f(error), stackTrace);

  @override
  Result<T, E> orElse(
    Result<T, E> Function(E error, StackTrace? stackTrace) f,
  ) => f(error, stackTrace);

  @override
  Option<T> toOption() => .none();

  @override
  Either<E, T> toEither() => .left(error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Err<T, E> && other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() {
    final st = stackTrace != null ? ', stackTrace: $stackTrace' : '';
    return 'Err($error$st)';
  }
}

/// Extension on synchronous functions to convert them to a `Result`.
extension SyncResultFunctionX<T> on T Function() {
  /// Converts this synchronous function into a `Result<T, E>`.
  ///
  /// If it returns a value successfully, it returns [Ok]. If it throws,
  /// the error is caught and wrapped in [Err] (optionally mapped via [onError]).
  Result<T, E> result<E>({E Function(Object error)? onError}) =>
      Result.from(this, onError: onError);
}

/// Extension on asynchronous functions to convert them to a `Result`.
extension AsyncResultFunctionX<T> on Future<T> Function() {
  /// Converts this asynchronous function into a `Future<Result<T, E>>`.
  ///
  /// If it completes successfully, it resolves to [Ok]. If it throws,
  /// the error is caught and wrapped in [Err] (optionally mapped via [onError]).
  Future<Result<T, E>> result<E>({E Function(Object error)? onError}) =>
      Result.fromAsync(this, onError: onError);
}
