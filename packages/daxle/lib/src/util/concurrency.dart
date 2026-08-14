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

  Future<List<R>> process<R>(Iterable<Future<R> Function()> items) async {
    _validateLimit();

    final jobs = items.toList();
    if (jobs.isEmpty) return [];

    // There is no need to split [items] into chunks of [poolSize] if it is unbounded
    if (isUnbounded) return _processJobsUnbounded(jobs);
    if (isSequential) return _processJobsSequential(jobs);

    return _processJobsBounded(jobs);
  }

  Future<List<R>> _processJobsUnbounded<R>(
    Iterable<Future<R> Function()> jobs,
  ) async => Future.wait(jobs.map((j) => j()), eagerError: true);

  Future<List<R>> _processJobsSequential<R>(
    Iterable<Future<R> Function()> jobs,
  ) async {
    final results = <R>[];

    for (final j in jobs) {
      results.add(await j());
    }

    return results;
  }

  Future<List<R>> _processJobsBounded<R>(
    Iterable<Future<R> Function()> jobs,
  ) async {
    final SplayTreeMap<int, R> results = .new();

    final iter = jobs.indexed.iterator;

    await Future.wait(
      .generate(poolSize, (_) async {
        while (iter.moveNext()) {
          final (index, job) = iter.current;

          final result = await job();
          results.putIfAbsent(index, () => result);
        }
      }),
      eagerError: true,
    );

    return results.values.toList();
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
