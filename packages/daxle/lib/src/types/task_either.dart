import 'dart:async';

import 'package:daxle/src/util/concurrency.dart';

import 'either.dart';

/// {@template task_either}
/// Represents an asynchronous computation that can fail.
///
/// It wraps a lazy [Future] (a function returning a [Future<Either<L, R>>])
/// allowing safe, declarative chaining of async operations.
///
/// ### Repository and Database Examples
///
/// Use `TaskEither` to wrap asynchronous database queries or repository calls
/// that can fail.
///
/// ```dart
/// class UserRepository {
///   final Database db;
///   UserRepository(this.db);
///
///   TaskEither<DatabaseError, User> getUserById(String id) {
///     return TaskEither.fromFuture(
///       () => db.query('SELECT * FROM users WHERE id = ?', [id]),
///       (error, stackTrace) => DatabaseError('Failed to fetch user: $error'),
///     ).flatMap((result) {
///       if (result.isEmpty) {
///         return TaskEither.left(DatabaseError('User not found'));
///       }
///       return TaskEither.right(User.fromMap(result.first));
///     });
///   }
/// }
/// ```
///
/// ### Realistic Pipeline Example
///
/// Here is a repository pipeline demonstrating how different combinators (like
/// [map], [tap], and [mapLeft]) flow together declaratively:
///
/// ```dart
/// TaskEither<AppError, Unit> publishPendingChanges(String userId) {
///   return getUserProfile(userId)              // TaskEither<DatabaseError, Profile>
///       .mapLeft((dbError) => AppError(dbError)) // Domain error conversion
///       .map(_calculatePendingSteps)            // Synchronous transformation
///       .tap(_publishPending)                  // Side effect (async/sync)
///       .map((_) => unit);                     // Final representation
/// }
/// ```
///
/// ### Side Effects using `tap`
///
/// Use `tap` to run side effects (like updating local cache, analytics, or UI changes)
/// when the computation is successful, without changing the value in the pipeline.
///
/// ```dart
/// getUserById(userId)
///   .tap((user) => cache.saveUser(user)) // Side effect on success
///   .map((user) => user.name);
/// ```
///
/// ### Logging using `tapLeft`
///
/// Use `tapLeft` to execute side effects (like logging) when a computation fails,
/// without affecting the propagated error.
///
/// ```dart
/// getUserById(userId)
///   .tapLeft((err) => logger.severe('Error fetching user: $err'))
///   .map((user) => user.name);
/// ```
///
/// ### Validation Pipelines and `ensure`
///
/// Use `ensure` to validate the successful value of a task, transitioning
/// to a `Left` if the validation fails. `ensure` supports both synchronous
/// and asynchronous predicates.
///
/// ```dart
/// TaskEither<ValidationError, User> validateAndFetchUser(String id) {
///   return getUserById(id)
///     .ensure((user) => user.isActive, () => ValidationError('User is inactive'))
///     .ensure((user) => checkUniqueness(user.email), () => ValidationError('Email already taken'));
/// }
/// ```
///
/// ### Combining Independent Tasks (sequence and traverse)
///
/// If you have a collection of tasks and want to run them with controlled concurrency,
/// use `TaskEither.sequence`. If any task returns a Left, execution stops.
///
/// ```dart
/// final tasks = [
///   updateInventory(itemA),
///   updateInventory(itemB),
///   updateInventory(itemC),
/// ];
/// final TaskEither<InventoryError, List<Unit>> result = TaskEither.sequence(
///   tasks,
///   mode: .bounded(2),
/// );
/// ```
///
/// Or use `TaskEither.traverse` to map an iterable to tasks and run them:
///
/// ```dart
/// final items = ['itemA', 'itemB', 'itemC'];
/// final TaskEither<InventoryError, List<Unit>> result = TaskEither.traverse(
///   items,
///   (item) => updateInventory(item),
///   mode: .sequential,
/// );
/// ```
///
/// ### When to use `map` vs `flatMap`
///
/// - Use `map` to transform a successful value synchronously:
///   `task.map((user) => user.email)`
/// - Use `flatMap` to chain a nested asynchronous computation that returns a `TaskEither`:
///   `task.flatMap((user) => fetchUserPreferences(user.id))`
///
/// ### Common Anti-patterns
///
/// **Anti-pattern: Nested execution instead of chaining**
/// ```dart
/// // Avoid:
/// task.map((user) async {
///   final prefs = await fetchUserPreferences(user.id).run();
///   return prefs.fold((l) => throw l, (r) => r);
/// });
///
/// // Prefer using flatMap:
/// task.flatMap((user) => fetchUserPreferences(user.id));
/// ```
///
/// **Anti-pattern: Executing tasks eagerly**
/// ```dart
/// // Avoid:
/// final future = fetchUser(123).run(); // starts future immediately
/// final task = TaskEither.right(42).flatMap((_) => TaskEither(() => future));
///
/// // Prefer:
/// final task = TaskEither.right(42).flatMap((_) => fetchUser(123));
/// ```
/// {@endtemplate}
final class const TaskEither<L, R>(final Future<Either<L, R>> Function() _run) {
  /// {@template task_either_from_either}
  /// Creates a [TaskEither] that immediately returns the provided [either].
  /// {@endtemplate}
  factory fromEither(Either<L, R> either) => .new(() => .value(either));

  /// Creates a [TaskEither] from an eager [Future].
  ///
  /// Catching any exceptions thrown by the future and mapping them to a Left
  /// using the provided [onError] function.
  factory fromFuture(
    Future<R> Function() future,
    L Function(Object error, StackTrace stackTrace) onError,
  ) => .new(() async {
    try {
      final res = await future();
      return Right<L, R>(res);
    } catch (e, st) {
      return Left<L, R>(onError(e, st));
    }
  });

  /// {@template task_either_left}
  /// Creates a [TaskEither] that resolves to a [Left] with the given [left] value.
  /// {@endtemplate}
  factory left(L left) => .new(() => .value(Left<L, R>(left)));

  /// {@template task_either_right}
  /// Creates a [TaskEither] that resolves to a [Right] with the given [right] value.
  /// {@endtemplate}
  factory right(R right) => .new(() => .value(Right<L, R>(right)));

  /// Runs the underlying asynchronous computation.
  Future<Either<L, R>> run() => _run();

  /// Applies [f] to the success value inside the [Right] of this [TaskEither].
  ///
  /// Catching any exceptions thrown during upstream computation or by [f],
  /// mapping them to a Left if [onError] is provided, or if the thrown error
  /// is of type [L].
  ///
  /// [map] is intended for synchronous transformations. If the transformation
  /// performs another asynchronous operation that returns a [TaskEither], use
  /// [flatMap] instead.
  @pragma('vm:prefer-inline')
  TaskEither<L, B> map<B>(
    B Function(R right) f, {
    L Function(Object error, StackTrace stackTrace)? onError,
  }) => .new(
    () => run()
        .then((either) {
          return either.map(f);
        })
        .catchError((Object e, StackTrace st) {
          if (onError != null) return Left<L, B>(onError(e, st));
          if (e is L) return Left<L, B>(e as L);
          return Future<Either<L, B>>.error(e, st);
        }),
  );

  /// Applies [mapper] to the error value inside the [Left] of this [TaskEither].
  ///
  /// If this [TaskEither] resolves to a [Right], the value continues unchanged.
  /// Laziness is preserved.
  @pragma('vm:prefer-inline')
  TaskEither<L2, R> mapLeft<L2>(
    L2 Function(L error) mapper,
  ) => .new((() => run().then((either) => either.mapLeft(mapper))));

  /// Applies [mapLeft] to the error value if this is a [Left], or [mapRight]
  /// to the success value if this is a [Right].
  ///
  /// Laziness is preserved.
  @pragma('vm:prefer-inline')
  TaskEither<L2, R2> bimap<L2, R2>(
    L2 Function(L error) mapLeft,
    R2 Function(R success) mapRight,
  ) {
    return .new(
      () => run().then((either) => either.bimap(mapLeft, mapRight)),
    );
  }

  /// Chains another [TaskEither] computation onto this one if this one succeeds.
  ///
  /// If this [TaskEither] resolves to a [Left], the failure is propagated and [f]
  /// is not executed.
  ///
  /// Catching any exceptions thrown during upstream computation, by [f], or
  /// by the chained TaskEither, mapping them to a Left if [onError] is provided,
  /// or if the thrown error is of type [L].
  @pragma('vm:prefer-inline')
  TaskEither<L, B> flatMap<B>(
    TaskEither<L, B> Function(R right) f, {
    L Function(Object error, StackTrace stackTrace)? onError,
  }) => .new(
    () => run()
        .then<Either<L, B>>(
          (either) => switch (either) {
            Left(value: final l) => Left<L, B>(l),
            Right(value: final r) => f(r).run(),
          },
        )
        .catchError((Object e, StackTrace st) {
          if (onError != null) return Left<L, B>(onError(e, st));
          if (e is L) return Left<L, B>(e as L);
          return Future<Either<L, B>>.error(e, st);
        }),
  );

  /// Runs the provided [callback] on the [Right] value of this [TaskEither] without modifying it.
  ///
  /// The callback may be synchronous or asynchronous.
  /// The callback is executed only if this [TaskEither] resolves to a [Right].
  /// The original [Right] value continues through the pipeline unchanged.
  @pragma('vm:prefer-inline')
  TaskEither<L, R> tap(
    FutureOr<void> Function(R value) callback,
  ) => .new(
    () => run().then<Either<L, R>>(
      (either) => switch (either) {
        Left() => either,
        Right(value: final r) => () async {
          await callback(r);
          return either;
        }(),
      },
    ),
  );

  /// Runs the provided [callback] on the [Left] value of this [TaskEither] without modifying it.
  ///
  /// The callback may be synchronous or asynchronous.
  /// The callback is executed only if this [TaskEither] resolves to a [Left].
  /// The original [Left] value continues through the pipeline unchanged.
  @pragma('vm:prefer-inline')
  TaskEither<L, R> tapLeft(
    FutureOr<void> Function(L error) callback,
  ) => .new(
    () => run().then<Either<L, R>>(
      (either) => switch (either) {
        Right() => either,
        Left(value: final l) => () async {
          await callback(l);
          return either;
        }(),
      },
    ),
  );

  /// Ensures that the [Right] value of this [TaskEither] satisfies the [predicate].
  ///
  /// The [predicate] may be synchronous or asynchronous.
  /// If this [TaskEither] resolves to a [Right] and the [predicate] returns/resolves
  /// to `true`, the value continues unchanged.
  /// If it returns/resolves to `false`, the result is a [Left] with the value returned
  /// by [onFailure].
  /// If this [TaskEither] resolves to a [Left], it is returned unchanged.
  @pragma('vm:prefer-inline')
  TaskEither<L, R> ensure(
    FutureOr<bool> Function(R value) predicate,
    L Function() onFailure,
  ) => .new(
    () => run().then<Either<L, R>>(
      (either) => switch (either) {
        Left() => either,
        Right(value: final r) => () async {
          final isValid = await predicate(r);
          return isValid ? either : Left<L, R>(onFailure());
        }(),
      },
    ),
  );

  /// Recovers from a [Left] failure by returning the result of [f].
  ///
  /// Catching any exceptions thrown during upstream computation, by [f], or
  /// by the fallback TaskEither, mapping them to a Left if [onError] is provided,
  /// or if the thrown error is of type [L].
  @pragma('vm:prefer-inline')
  TaskEither<L, R> orElse(
    TaskEither<L, R> Function(L left) f, {
    L Function(Object error, StackTrace stackTrace)? onError,
  }) => .new(
    () => run()
        .then<Either<L, R>>(
          (either) => switch (either) {
            Left(value: final l) => f(l).run(),
            Right() => either,
          },
        )
        .catchError((Object e, StackTrace st) {
          if (onError != null) return Left<L, R>(onError(e, st));
          if (e is L) return Left<L, R>(e as L);
          return Future<Either<L, R>>.error(e, st);
        }),
  );

  /// Projects this [TaskEither] into a value of type [B] by running the computation
  /// and applying [ifLeft] if a failure occurred, or [ifRight] if successful.
  ///
  /// Any exceptions thrown during upstream computation are caught and mapped using
  /// [onError] if provided. Exceptions thrown by [ifLeft] or [ifRight] callbacks
  /// are not caught and will propagate to the caller.
  Future<B> fold<B>(
    B Function(L left) ifLeft,
    B Function(R right) ifRight, {
    B Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    final Either<L, R> either;
    try {
      either = await run();
    } catch (e, st) {
      if (onError != null) {
        return onError(e, st);
      }
      rethrow;
    }
    return either.fold(ifLeft, ifRight);
  }

  /// Executes an [Iterable] of [TaskEither]s according to [mode], collecting their successful results.
  ///
  /// Default mode is `const .bounded(3)` (dynamic sliding-window worker pool).
  ///
  /// ### Early Abort on Failure
  /// If any task returns a [Left] failure, the worker queue halts immediately.
  /// Any unstarted pending tasks in the queue are canceled and will **never be executed**,
  /// saving network requests, database writes, and CPU resources.
  ///
  /// Results are preserved in the original order, and the first encountered [Left]
  /// is returned. If all tasks succeed, returns a [Right] containing a list of all values.
  static TaskEither<L, List<R>> sequence<L, R>(
    Iterable<TaskEither<L, R>> tasks, {
    Concurrency mode = const .bounded(3),
  }) => .new(() async {
    final eithers = await mode.process(
      tasks.map((t) => t.run),
      shouldStop: (either) => either.isLeft,
    );

    final results = <R>[];
    for (final either in eithers) {
      switch (either) {
        case Left(value: final l):
          return Left<L, List<R>>(l);
        case Right(value: final r):
          results.add(r);
      }
    }
    return Right<L, List<R>>(results);
  });

  /// Maps each element of [items] to a [TaskEither] using [mapper], executing them according to [mode].
  ///
  /// Default mode is `const .bounded(3)` (dynamic sliding-window worker pool).
  ///
  /// ### Early Abort on Failure
  /// If any mapped task returns a [Left], the worker queue halts immediately and
  /// pending unstarted items are never mapped or executed.
  ///
  /// Otherwise, returns a [Right] containing a list of all mapped values.
  static TaskEither<L, List<B>> traverse<L, A, B>(
    Iterable<A> items,
    TaskEither<L, B> Function(A item) mapper, {
    Concurrency mode = const .bounded(3),
  }) => sequence(items.map(mapper), mode: mode);
}
