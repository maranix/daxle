import 'dart:collection';

import 'package:meta/meta.dart';

/// {@template concurrency}
/// Defines the concurrency execution strategy for asynchronous tasks.
///
/// `Concurrency` controls how collections of deferred tasks (such as [Task]
/// or [TaskEither]) are scheduled and executed across the event loop:
///
/// - [Concurrency.sequential]: Executes tasks strictly one after another (1 active task).
/// - [Concurrency.unbounded]: Executes all tasks simultaneously in parallel without limits.
/// - [Concurrency.bounded]: Executes tasks in parallel using a worker pool limited to [poolSize] active tasks.
///
/// ### Examples using Dot-Shorthand Syntax:
/// ```dart
/// // Unbounded parallel (default)
/// Task.sequence(tasks, mode: .unbounded);
///
/// // Strictly sequential
/// Task.sequence(tasks, mode: .sequential);
///
/// // Worker pool of 10 concurrent tasks
/// Task.sequence(tasks, mode: .bounded(10));
/// ```
/// {@endtemplate}
@immutable
extension type const Concurrency._(int poolSize) {
  /// Strictly sequential execution (1 active task at a time).
  ///
  /// Tasks are executed in strict order. Task N+1 will not begin until Task N completes.
  static const Concurrency sequential = Concurrency._(1);

  /// Unbounded parallel execution.
  ///
  /// All tasks are dispatched to the event loop simultaneously.
  static const Concurrency unbounded = Concurrency._(0);

  /// Creates a bounded concurrency strategy with a worker pool of [poolSize] active tasks.
  const factory Concurrency.bounded(int poolSize) = Concurrency._;

  /// Whether execution is strictly sequential (poolSize == 1).
  bool get isSequential => poolSize == 1;

  /// Whether execution is unbounded parallel (poolSize == 0).
  bool get isUnbounded => poolSize == 0;

  /// Whether execution is bounded with a worker pool poolSize (poolSize >= 2).
  bool get isBounded => poolSize > 1;

  /// Executes [items] according to this concurrency strategy and returns the collected results.
  ///
  /// - **Sliding-Window Worker Pool**: In [isBounded] mode, tasks are dispatched through
  ///   a dynamic worker pool of size [poolSize]. As soon as any worker completes a task,
  ///   it immediately pulls the next pending task from the queue without waiting for slower
  ///   tasks in other slots.
  /// - **Deterministic Ordering**: Results are always collected and returned in the exact
  ///   original order of the input [items].
  /// - **Early-Exit Support ([shouldStop])**: If [shouldStop] is provided and evaluates to `true`
  ///   for any completed task result:
  ///   - In [isSequential] mode, execution halts immediately after the matching task.
  ///   - In [isBounded] mode, the worker queue is immediately locked, preventing any unstarted
  ///     pending tasks from being dispatched or executed.
  ///   - Tasks already in-flight will finish, and all collected results are returned.
  Future<List<R>> process<R>(
    Iterable<Future<R> Function()> items, {
    bool Function(R)? shouldStop,
  }) async {
    _validateLimit();

    final jobs = items.toList();
    if (jobs.isEmpty) return [];

    // There is no need to split [items] into chunks of [poolSize] if it is unbounded
    if (isUnbounded) {
      return _processJobsUnbounded(jobs);
    }

    if (isSequential) {
      return _processJobsSequential(jobs, shouldStop: shouldStop);
    }

    return _processJobsBounded(jobs, shouldStop: shouldStop);
  }

  Future<List<R>> _processJobsUnbounded<R>(
    Iterable<Future<R> Function()> jobs,
  ) async => Future.wait(jobs.map((j) => j()), eagerError: true);

  Future<List<R>> _processJobsSequential<R>(
    Iterable<Future<R> Function()> jobs, {
    bool Function(R)? shouldStop,
  }) async {
    final jobResults = <R>[];

    for (final j in jobs) {
      final result = await j();

      jobResults.add(result);

      if (shouldStop?.call(result) ?? false) return jobResults;
    }

    return jobResults;
  }

  Future<List<R>> _processJobsBounded<R>(
    Iterable<Future<R> Function()> jobs, {
    bool Function(R)? shouldStop,
  }) async {
    final SplayTreeMap<int, R> jobResults = .new();

    final iter = jobs.indexed.iterator;
    var isStopped = false;

    await Future.wait(
      .generate(poolSize, (_) async {
        while (!isStopped && iter.moveNext()) {
          final (index, job) = iter.current;

          final result = await job();
          jobResults.putIfAbsent(index, () => result);

          if (shouldStop?.call(result) ?? false) {
            isStopped = true;
            break;
          }
        }
      }),
      eagerError: true,
    );

    return jobResults.values.toList();
  }

  void _validateLimit() {
    if (poolSize < 0) {
      throw ArgumentError.value(
        poolSize,
        'poolSize',
        'Invalid concurrent pool size. '
            '\n'
            'For 1 active task, use Concurrency.sequential.'
            '\n'
            'For N active task, use Concurrency.bounded(n).'
            '\n'
            'For unbounded active task, use Concurrency.unbounded.',
      );
    }
  }
}
