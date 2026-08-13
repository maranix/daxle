import 'dart:async';

import 'package:daxle/src/util/concurrency.dart';

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
final class const Task<T>(final Future<T> Function() _run) {
  /// Executes the deferred asynchronous computation.
  Future<T> run() => _run();

  /// Transforms the value produced by this [Task] using the provided [f].
  ///
  /// Laziness is preserved. The transformation is only applied when the
  /// returned [Task] is executed.
  @pragma('vm:prefer-inline')
  Task<R> map<R>(R Function(T value) f) => .new(
    () => run().then(f),
  );

  /// Chains another [Task] onto this one.
  ///
  /// Laziness is preserved. The chained task is only executed if and when
  /// the returned [Task] is executed.
  @pragma('vm:prefer-inline')
  Task<R> flatMap<R>(Task<R> Function(T value) f) => .new(
    () => run().then(
      (value) => f(value).run(),
    ),
  );

  /// Runs the provided [callback] on the value produced by this [Task]
  /// without modifying it.
  ///
  /// The callback may be synchronous or asynchronous.
  /// Laziness is preserved. The callback is only executed when the
  /// returned [Task] is executed.
  Task<T> tap(FutureOr<void> Function(T value) callback) => .new(() async {
    final value = await run();
    await callback(value);
    return value;
  });

  /// Executes an [Iterable] of [Task]s according to [mode], collecting their results in order.
  ///
  /// Default mode is `const .bounded(3)`.
  /// If any task throws an exception, execution fails eagerly and the exception propagates.
  static Task<List<R>> sequence<R>(
    Iterable<Task<R>> tasks, {
    Concurrency mode = const .bounded(3),
  }) => Task(() => mode.process(tasks.map((t) => t.run)));

  /// Maps each element of [items] to a [Task] using [mapper], executing them according to [mode].
  ///
  /// Default mode is `const .bounded(3)`.
  /// If any task throws an exception, execution fails eagerly and the exception propagates.
  static Task<List<B>> traverse<A, B>(
    Iterable<A> items,
    Task<B> Function(A item) mapper, {
    Concurrency mode = const .bounded(3),
  }) => sequence(items.map(mapper), mode: mode);
}
