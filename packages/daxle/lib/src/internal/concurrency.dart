import 'package:meta/meta.dart';

/// {@template concurrency}
/// Defines the concurrency execution strategy for asynchronous tasks.
///
/// `Concurrency` controls how collections of deferred tasks (such as [Task]
/// or [TaskEither]) are scheduled and executed across the event loop:
///
/// - [Concurrency.sequential]: Executes tasks strictly one after another (1 active task).
/// - [Concurrency.unbounded]: Executes all tasks simultaneously in parallel without limits.
/// - [Concurrency.bounded]: Executes tasks in parallel using a worker pool limited to [limit] active tasks.
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
extension type const Concurrency._(int limit) {
  /// Strictly sequential execution (1 active task at a time).
  ///
  /// Tasks are executed in strict order. Task N+1 will not begin until Task N completes.
  static const Concurrency sequential = Concurrency._(1);

  /// Unbounded parallel execution.
  ///
  /// All tasks are dispatched to the event loop simultaneously.
  static const Concurrency unbounded = Concurrency._(0);

  /// Creates a bounded concurrency strategy with a worker pool of [limit] active tasks.
  const factory Concurrency.bounded(int limit) = Concurrency._;

  /// Whether execution is strictly sequential (limit == 1).
  bool get isSequential => limit == 1;

  /// Whether execution is unbounded parallel (limit == 0).
  bool get isUnbounded => limit == 0;

  /// Whether execution is bounded with a worker pool limit (limit >= 2).
  bool get isBounded => limit > 1;

  Future<List<R>> process<R>(Iterable<Future<R> Function()> items) async {
    if (limit < 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Invalid concurrency limit. '
            '\n'
            'For 1 active task, use Concurrency.sequential.'
            '\n'
            'For N active task, use Concurrency.bounded(n).'
            '\n'
            'For unbounded active task, use Concurrency.unbounded.',
      );
    }

    // There is no need to split [items] into chunks of [limit] if it is unbounded
    if (isUnbounded) {
      return await Future.wait(items.map((i) => i()), eagerError: true);
    }

    final itemsList = items.toList();
    final totalLength = itemsList.length;
    final chunks = <Iterable<Future<R> Function()>>[];

    for (int i = 0; i < totalLength; i += limit) {
      try {
        RangeError.checkValidRange(i, i + limit, totalLength);
        chunks.add(itemsList.sublist(i, i + limit));
      } on RangeError {
        chunks.add(itemsList.sublist(i));
        break;
      }
    }

    final results = <R>[];

    for (final chunk in chunks) {
      results.addAll(
        await Future.wait(
          chunk.map((c) => c()),
          eagerError: true,
        ),
      );
    }

    return results;
  }
}
