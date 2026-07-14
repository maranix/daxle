import 'dart:async';

/// {@template task}
/// Represents a lazy asynchronous computation that produces a value of type [T].
///
/// Unlike a [Future], a [Task] defers execution until [run] is called.
/// This allows you to compose asynchronous operations declaratively before
/// they actually begin executing.
///
/// **Note**: [Task] does not provide explicit failure handling. If the
/// underlying computation throws an exception, the exception propagates normally.
///
/// - Use Task when failures are represented as exceptions following normal Dart semantics.
/// - Use TaskEither when failures are part of the domain and should be represented explicitly as Either.
///
/// ### Example
///
/// ```dart
/// final task = Task(() async {
///   print('Fetching data...');
///   return 'data';
/// });
///
/// // The computation hasn't started yet.
///
/// final result = await task.run(); // Now it runs.
/// ```
/// {@endtemplate}
final class Task<T> {
  final Future<T> Function() _run;

  /// {@macro task}
  const Task(this._run);

  /// Executes the deferred asynchronous computation.
  Future<T> run() => _run();

  /// Transforms the value produced by this [Task] using the provided [f].
  ///
  /// Laziness is preserved. The transformation is only applied when the
  /// returned [Task] is executed.
  Task<R> map<R>(R Function(T value) f) {
    return Task(() async {
      final value = await run();
      return f(value);
    });
  }

  /// Chains another [Task] onto this one.
  ///
  /// Laziness is preserved. The chained task is only executed if and when
  /// the returned [Task] is executed.
  Task<R> flatMap<R>(Task<R> Function(T value) f) {
    return Task(() async {
      final value = await run();
      return await f(value).run();
    });
  }

  /// Runs the provided [callback] on the value produced by this [Task]
  /// without modifying it.
  ///
  /// The callback may be synchronous or asynchronous.
  /// Laziness is preserved. The callback is only executed when the
  /// returned [Task] is executed.
  Task<T> tap(FutureOr<void> Function(T value) callback) {
    return Task(() async {
      final value = await run();
      await callback(value);
      return value;
    });
  }

  /// Executes an [Iterable] of [Task]s sequentially, collecting their results.
  ///
  /// The tasks are executed one after another in order. If any task throws
  /// an exception, execution stops and the exception propagates immediately.
  static Task<List<R>> sequence<R>(Iterable<Task<R>> tasks) {
    return Task(() async {
      final results = <R>[];
      for (final task in tasks) {
        results.add(await task.run());
      }
      return results;
    });
  }

  /// Maps each element of [items] to a [Task] using [mapper], and executes
  /// them sequentially.
  ///
  /// The tasks are executed one after another in order. If any task throws
  /// an exception, execution stops and the exception propagates immediately.
  static Task<List<B>> traverse<A, B>(
    Iterable<A> items,
    Task<B> Function(A item) mapper,
  ) {
    return Task.sequence(items.map(mapper));
  }
}
