import 'dart:async';

/// A private helper utility to invoke the global error handler if registered.
void _notifyGlobal(
  void Function(Object, StackTrace)? handler,
  Object error,
  StackTrace stackTrace,
) {
  handler?.call(error, stackTrace);
}

/// A private helper to execute a synchronous function guarded by try-catch
/// and automatically trigger global error logging/telemetry on failure.
T _runGuarded<T>(
  T Function() f,
  void Function(Object, StackTrace)? onPipeError,
) {
  try {
    return f();
  } catch (e, st) {
    _notifyGlobal(onPipeError, e, st);
    rethrow;
  }
}

/// A private helper to execute an asynchronous function guarded by try-catch
/// and automatically trigger global error logging/telemetry on failure.
Future<T> _runGuardedAsync<T>(
  FutureOr<T> Function() f,
  void Function(Object, StackTrace)? onPipeError,
) async {
  try {
    return await f();
  } catch (e, st) {
    _notifyGlobal(onPipeError, e, st);
    rethrow;
  }
}

/// Represents a deferred, type-safe synchronous pipeline of operations.
///
/// A [Pipeline] allows chaining multiple synchronous operations together in a
/// clean, linear composition. All operations are deferred (evaluated lazily)
/// until [run] is called.
///
/// Example:
/// ```dart
/// final result = Pipeline(() => 5)
///     .pipe((x) => x * 2)
///     .pipe((x) => 'Value: $x')
///     .run(); // Returns 'Value: 10'
/// ```
class Pipeline<T> {
  final T Function() _compute;
  final void Function(Object error, StackTrace stackTrace)? _onPipeError;

  /// Initializes a synchronous pipeline with a 0-argument producer function.
  ///
  /// The [producer] function computes the starting value of the pipeline when
  /// [run] is invoked.
  ///
  /// An optional [onPipeError] callback can be provided to observe errors thrown
  /// at any stage in the pipeline. This callback is purely observational (e.g.
  /// for logging or metrics) and does not intercept or suppress the errors.
  Pipeline(
    T Function() producer, {
    void Function(Object error, StackTrace stackTrace)? onPipeError,
  }) : _compute = (() => _runGuarded(producer, onPipeError)),
       _onPipeError = onPipeError;

  Pipeline._(this._compute, this._onPipeError);

  /// Chains a synchronous transformation step onto the pipeline.
  ///
  /// The provided function [f] takes the output of the previous step and
  /// transforms it into a new type [R]. If [f] throws an exception, it is
  /// passed to the global [onPipeError] handler (if defined) before propagating.
  Pipeline<R> pipe<R>(R Function(T value) f) {
    return Pipeline<R>._(() {
      final prev = _compute();
      return _runGuarded(() => f(prev), _onPipeError);
    }, _onPipeError);
  }

  /// Chains a synchronous observational side-effect.
  ///
  /// The provided function [f] executes side-effects using the output of the
  /// previous step, but the original value passes through unchanged to the next
  /// step. If [f] throws an exception, it propagates down the pipeline.
  Pipeline<T> tap(void Function(T value) f) {
    return Pipeline<T>._(() {
      final prev = _compute();
      _runGuarded(() => f(prev), _onPipeError);
      return prev;
    }, _onPipeError);
  }

  /// Recovers from exceptions thrown in any preceding step of the pipeline
  /// by returning a static fallback value of type [T].
  ///
  /// The provided function [onError] is called with the caught error and
  /// stack trace, and must return the fallback value to resume the pipeline.
  Pipeline<T> recover(T Function(Object error, StackTrace stackTrace) onError) {
    return Pipeline<T>._(() {
      try {
        return _compute();
      } catch (e, st) {
        return onError(e, st);
      }
    }, _onPipeError);
  }

  /// Flat-maps this pipeline into another [Pipeline].
  ///
  /// Used for composing dependent sequential computations, preventing nested
  /// pipelines (avoiding `Pipeline<Pipeline<R>>`). Execution of the inner
  /// pipeline is completely lazy and deferred until `.run()` is called.
  ///
  /// Example:
  /// ```dart
  /// Pipeline(() => 5)
  ///     .flatMap((x) => Pipeline(() => x * 2))
  ///     .run(); // Returns 10
  /// ```
  Pipeline<R> flatMap<R>(Pipeline<R> Function(T value) f) {
    return Pipeline<R>._(() {
      final prev = _compute();
      final nextPipeline = _runGuarded(() => f(prev), _onPipeError);
      return nextPipeline.run();
    }, _onPipeError);
  }

  /// Combines this pipeline with [other] using the provided [combiner] function.
  ///
  /// Used to merge independent pipelines. Computations are evaluated
  /// sequentially in the following contract:
  /// 1. Evaluate this (left) pipeline.
  /// 2. Evaluate [other] (right) pipeline.
  /// 3. Pass both values into the [combiner] function.
  ///
  /// Example:
  /// ```dart
  /// final p1 = Pipeline(() => 5);
  /// final p2 = Pipeline(() => 10);
  /// final zipped = p1.zip(p2, (a, b) => a + b);
  /// zipped.run(); // Returns 15
  /// ```
  Pipeline<R> zip<S, R>(
    Pipeline<S> other,
    R Function(T value, S otherValue) combiner,
  ) {
    return Pipeline<R>._(() {
      final valT = _compute();
      final valS = other.run();
      return _runGuarded(() => combiner(valT, valS), _onPipeError);
    }, _onPipeError);
  }

  /// Recovers from exceptions thrown in any preceding step of the pipeline
  /// by continuing execution with another fallback [Pipeline]. Execution
  /// remains deferred until `.run()` is called.
  ///
  /// Example:
  /// ```dart
  /// Pipeline(() => 5)
  ///     .pipe((x) => throw Exception())
  ///     .recoverWith((e, st) => Pipeline(() => 42))
  ///     .run(); // Returns 42
  /// ```
  Pipeline<T> recoverWith(
    Pipeline<T> Function(Object error, StackTrace stackTrace) onError,
  ) {
    return Pipeline<T>._(() {
      try {
        return _compute();
      } catch (e, st) {
        final nextPipeline = onError(e, st);
        return nextPipeline.run();
      }
    }, _onPipeError);
  }

  /// Registers a synchronous cleanup callback that is executed regardless of
  /// success or failure of the pipeline.
  ///
  /// Note: The original return value or exception is propagated unchanged,
  /// unless the [cleanup] function itself throws an exception.
  ///
  /// *(This represents the semantic equivalent of the reserved 'finally' keyword in Dart).*
  Pipeline<T> finalize(void Function() cleanup) {
    return Pipeline<T>._(() {
      try {
        return _compute();
      } finally {
        cleanup();
      }
    }, _onPipeError);
  }

  /// Transforms exceptions thrown by any preceding step of the pipeline
  /// into another exception without recovering.
  ///
  /// Unlike [recover], execution still fails, but the thrown exception is mapped
  /// to the type returned by the [transform] callback.
  ///
  /// Example:
  /// ```dart
  /// Pipeline(() => 5)
  ///     .pipe((x) => throw Exception('Original'))
  ///     .mapError((error, stack) => ArgumentError('Transformed: $error'))
  ///     .run(); // Throws ArgumentError
  /// ```
  Pipeline<T> mapError(
    Object Function(Object error, StackTrace stackTrace) transform,
  ) {
    return Pipeline<T>._(() {
      try {
        return _compute();
      } catch (e, st) {
        Error.throwWithStackTrace(transform(e, st), st);
      }
    }, _onPipeError);
  }

  /// Transforms the pipeline output into a single type, folding both the
  /// successful value and the failure exception states.
  ///
  /// Allows clean caller handling without wrapping execution in `try-catch` blocks.
  ///
  /// Example:
  /// ```dart
  /// final result = Pipeline(() => 5)
  ///     .fold(
  ///       success: (x) => 'Success: $x',
  ///       failure: (e, st) => 'Failed: $e',
  ///     )
  ///     .run(); // Returns 'Success: 5'
  /// ```
  Pipeline<R> fold<R>({
    required R Function(T value) success,
    required R Function(Object error, StackTrace stackTrace) failure,
  }) {
    return Pipeline<R>._(() {
      final T val;
      try {
        val = _compute();
      } catch (e, st) {
        return failure(e, st);
      }
      return success(val);
    }, _onPipeError);
  }

  /// Executes all stages of the synchronous pipeline, returning the final value.
  T run() => _compute();

  /// Converts this synchronous pipeline into an [AsyncPipeline].
  ///
  /// Any subsequent operations chained to the returned pipeline will be processed
  /// asynchronously. The global [onPipeError] handler is preserved during the transition.
  AsyncPipeline<T> toAsync() {
    return AsyncPipeline._(() async => _compute(), _onPipeError);
  }
}

/// Represents a deferred, type-safe asynchronous pipeline of operations.
///
/// An [AsyncPipeline] allows linear composition of asynchronous and synchronous
/// operations. Operations return [FutureOr] types and are evaluated lazily
/// only when [run] is called.
///
/// Example:
/// ```dart
/// final result = await AsyncPipeline(() => Future.value(5))
///     .pipe((x) => Future.delayed(Duration(milliseconds: 5), () => x * 2))
///     .pipe((x) => x + 10)
///     .run(); // Resolves to 20
/// ```
class AsyncPipeline<T> {
  final Future<T> Function() _compute;
  final void Function(Object error, StackTrace stackTrace)? _onPipeError;

  /// Initializes an asynchronous pipeline with a 0-argument producer function.
  ///
  /// The [producer] function can return either a value of type [T] or a `Future<T>`,
  /// and is called to obtain the initial value when [run] is invoked.
  ///
  /// An optional [onPipeError] callback can be provided to observe errors thrown
  /// at any stage in the pipeline. This callback is purely observational (e.g.
  /// for logging or metrics) and does not intercept or suppress the errors.
  AsyncPipeline(
    FutureOr<T> Function() producer, {
    void Function(Object error, StackTrace stackTrace)? onPipeError,
  }) : _compute = (() => _runGuardedAsync(producer, onPipeError)),
       _onPipeError = onPipeError;

  AsyncPipeline._(this._compute, this._onPipeError);

  /// Chains an asynchronous or synchronous transformation step onto the pipeline.
  ///
  /// The provided function [f] takes the output of the previous step and
  /// transforms it into a new type [R] (which can be wrapped in a [Future]).
  /// If [f] throws or fails, it is passed to the global [onPipeError] handler
  /// (if defined) before propagating.
  AsyncPipeline<R> pipe<R>(FutureOr<R> Function(T value) f) {
    return AsyncPipeline<R>._(() async {
      final prev = await _compute();
      return _runGuardedAsync(() => f(prev), _onPipeError);
    }, _onPipeError);
  }

  /// Chains an asynchronous or synchronous observational side-effect.
  ///
  /// The provided function [f] executes side-effects using the output of the
  /// previous step, but the original value passes through unchanged to the next
  /// step. If [f] throws or fails, the error propagates down the pipeline.
  AsyncPipeline<T> tap(FutureOr<void> Function(T value) f) {
    return AsyncPipeline<T>._(() async {
      final prev = await _compute();
      await _runGuardedAsync(() => f(prev), _onPipeError);
      return prev;
    }, _onPipeError);
  }

  /// Recovers from exceptions thrown in any preceding step of the asynchronous pipeline
  /// by returning a static fallback value of type [T].
  ///
  /// The provided function [onError] is called with the caught error and
  /// stack trace, and can return either a fallback value or a `Future<T>` to resume the pipeline.
  AsyncPipeline<T> recover(
    FutureOr<T> Function(Object error, StackTrace stackTrace) onError,
  ) {
    return AsyncPipeline<T>._(() async {
      try {
        return await _compute();
      } catch (e, st) {
        return await onError(e, st);
      }
    }, _onPipeError);
  }

  /// Flat-maps this asynchronous pipeline into another [AsyncPipeline].
  ///
  /// Used for composing dependent sequential computations, preventing nested
  /// pipelines (avoiding `AsyncPipeline<AsyncPipeline<R>>`). Execution of the
  /// inner pipeline remains completely lazy and deferred.
  ///
  /// Example:
  /// ```dart
  /// AsyncPipeline(() => 5)
  ///     .flatMap((x) => AsyncPipeline(() => Future.value(x * 2)))
  ///     .run(); // Resolves to 10
  /// ```
  AsyncPipeline<R> flatMap<R>(AsyncPipeline<R> Function(T value) f) {
    return AsyncPipeline<R>._(() async {
      final prev = await _compute();
      final nextPipeline = await _runGuardedAsync(() => f(prev), _onPipeError);
      return nextPipeline.run();
    }, _onPipeError);
  }

  /// Combines this asynchronous pipeline with [other] using the provided [combiner] function.
  ///
  /// Evaluates both pipelines concurrently utilizing Dart records and the concurrent `.wait` futures API.
  /// The execution contract runs both pipelines concurrently before combining their results:
  /// 1. Run this and [other] concurrently.
  /// 2. Statically unpack the results type-safely.
  /// 3. Pass both values into the [combiner] function.
  ///
  /// Example:
  /// ```dart
  /// final p1 = AsyncPipeline(() => Future.value(5));
  /// final p2 = AsyncPipeline(() => Future.value(10));
  /// final zipped = p1.zip(p2, (a, b) => a + b);
  /// await zipped.run(); // Resolves to 15
  /// ```
  AsyncPipeline<R> zip<S, R>(
    AsyncPipeline<S> other,
    FutureOr<R> Function(T value, S otherValue) combiner,
  ) {
    return AsyncPipeline<R>._(() async {
      final (valT, valS) = await (_compute(), other.run()).wait;
      return _runGuardedAsync(() => combiner(valT, valS), _onPipeError);
    }, _onPipeError);
  }

  /// Recovers from exceptions thrown in any preceding step of the asynchronous pipeline
  /// by continuing execution with another fallback [AsyncPipeline]. Execution remains
  /// deferred until `.run()` is called.
  ///
  /// Example:
  /// ```dart
  /// AsyncPipeline(() => 5)
  ///     .pipe((x) => throw Exception())
  ///     .recoverWith((e, st) => AsyncPipeline(() => 42))
  ///     .run(); // Resolves to 42
  /// ```
  AsyncPipeline<T> recoverWith(
    AsyncPipeline<T> Function(Object error, StackTrace stackTrace) onError,
  ) {
    return AsyncPipeline<T>._(() async {
      try {
        return await _compute();
      } catch (e, st) {
        final nextPipeline = onError(e, st);
        return await nextPipeline.run();
      }
    }, _onPipeError);
  }

  /// Registers an asynchronous cleanup callback that is executed regardless of
  /// success or failure of the pipeline.
  ///
  /// Note: The original return value or exception is propagated unchanged,
  /// unless the [cleanup] function itself throws an exception.
  ///
  /// *(This represents the semantic equivalent of the reserved 'finally' keyword in Dart).*
  AsyncPipeline<T> finalize(FutureOr<void> Function() cleanup) {
    return AsyncPipeline<T>._(() async {
      try {
        return await _compute();
      } finally {
        await cleanup();
      }
    }, _onPipeError);
  }

  /// Transforms exceptions thrown by any preceding step of the asynchronous pipeline
  /// into another exception without recovering.
  ///
  /// Unlike [recover], execution still fails, but the thrown exception is mapped
  /// to the type returned by the [transform] callback.
  ///
  /// Example:
  /// ```dart
  /// AsyncPipeline(() => 5)
  ///     .pipe((x) => throw Exception('Original'))
  ///     .mapError((error, stack) async => ArgumentError('Transformed: $error'))
  ///     .run(); // Throws ArgumentError
  /// ```
  AsyncPipeline<T> mapError(
    FutureOr<Object> Function(Object error, StackTrace stackTrace) transform,
  ) {
    return AsyncPipeline<T>._(() async {
      try {
        return await _compute();
      } catch (e, st) {
        final transformed = await transform(e, st);
        Error.throwWithStackTrace(transformed, st);
      }
    }, _onPipeError);
  }

  /// Transforms the asynchronous pipeline output into a single type, folding both
  /// the successful value and the failure exception states.
  ///
  /// Allows clean caller handling without wrapping execution in `try-catch` blocks.
  ///
  /// Example:
  /// ```dart
  /// final result = await AsyncPipeline(() => 5)
  ///     .fold(
  ///       success: (x) => 'Success: $x',
  ///       failure: (e, st) => 'Failed: $e',
  ///     )
  ///     .run(); // Resolves to 'Success: 5'
  /// ```
  AsyncPipeline<R> fold<R>({
    required FutureOr<R> Function(T value) success,
    required FutureOr<R> Function(Object error, StackTrace stackTrace) failure,
  }) {
    return AsyncPipeline<R>._(() async {
      final T val;
      try {
        val = await _compute();
      } catch (e, st) {
        return await failure(e, st);
      }
      return await success(val);
    }, _onPipeError);
  }

  /// Executes all stages of the asynchronous pipeline, returning a [Future] that resolves to the final value.
  Future<T> run() => _compute();
}
