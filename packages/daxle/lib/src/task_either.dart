import 'either.dart';

/// {@template task_either}
/// Represents an asynchronous computation that can fail.
///
/// It wraps a lazy [Future] (a function returning a [Future<Either<L, R>>])
/// allowing safe, declarative chaining of async operations.
/// {@endtemplate}
class TaskEither<L, R> {
  final Future<Either<L, R>> Function() _run;

  /// {@macro task_either}
  const TaskEither(this._run);

  /// {@template task_either_from_either}
  /// Creates a [TaskEither] that immediately returns the provided [either].
  /// {@endtemplate}
  factory TaskEither.fromEither(Either<L, R> either) =>
      TaskEither(() => Future.value(either));

  /// Creates a [TaskEither] from an eager [Future].
  ///
  /// Catching any exceptions thrown by the future and mapping them to a Left
  /// using the provided [onError] function.
  factory TaskEither.fromFuture(
    Future<R> Function() future,
    L Function(Object error, StackTrace stackTrace) onError,
  ) {
    return TaskEither(() async {
      try {
        final res = await future();
        return Right<L, R>(res);
      } catch (e, st) {
        return Left<L, R>(onError(e, st));
      }
    });
  }

  /// {@template task_either_left}
  /// Creates a [TaskEither] that resolves to a [Left] with the given [left] value.
  /// {@endtemplate}
  factory TaskEither.left(L left) =>
      TaskEither(() => Future.value(Left<L, R>(left)));

  /// {@template task_either_right}
  /// Creates a [TaskEither] that resolves to a [Right] with the given [right] value.
  /// {@endtemplate}
  factory TaskEither.right(R right) =>
      TaskEither(() => Future.value(Right<L, R>(right)));

  /// Runs the underlying asynchronous computation.
  Future<Either<L, R>> run() => _run();

  /// Applies [f] to the success value inside the [Right] of this [TaskEither].
  ///
  /// Catching any exceptions thrown during upstream computation or by [f],
  /// mapping them to a Left if [onError] is provided, or if the thrown error
  /// is of type [L].
  TaskEither<L, B> map<B>(
    B Function(R right) f, {
    L Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return TaskEither(() async {
      try {
        final either = await run();
        return either.map(f);
      } catch (e, st) {
        if (onError != null) {
          return Left<L, B>(onError(e, st));
        }
        if (e is L) {
          return Left<L, B>(e as L);
        }
        rethrow;
      }
    });
  }

  /// Chains another [TaskEither] computation onto this one if this one succeeds.
  ///
  /// If this [TaskEither] resolves to a [Left], the failure is propagated and [f]
  /// is not executed.
  ///
  /// Catching any exceptions thrown during upstream computation, by [f], or
  /// by the chained TaskEither, mapping them to a Left if [onError] is provided,
  /// or if the thrown error is of type [L].
  TaskEither<L, B> flatMap<B>(
    TaskEither<L, B> Function(R right) f, {
    L Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return TaskEither(() async {
      try {
        final either = await run();
        return await switch (either) {
          Left(value: final l) => Left<L, B>(l),
          Right(value: final r) => f(r).run(),
        };
      } catch (e, st) {
        if (onError != null) {
          return Left<L, B>(onError(e, st));
        }
        if (e is L) {
          return Left<L, B>(e as L);
        }
        rethrow;
      }
    });
  }

  /// Recovers from a [Left] failure by returning the result of [f].
  ///
  /// Catching any exceptions thrown during upstream computation, by [f], or
  /// by the fallback TaskEither, mapping them to a Left if [onError] is provided,
  /// or if the thrown error is of type [L].
  TaskEither<L, R> orElse(
    TaskEither<L, R> Function(L left) f, {
    L Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return TaskEither(() async {
      try {
        final either = await run();
        return await switch (either) {
          Left(value: final l) => f(l).run(),
          Right(value: final r) => Right<L, R>(r),
        };
      } catch (e, st) {
        if (onError != null) {
          return Left<L, R>(onError(e, st));
        }
        if (e is L) {
          return Left<L, R>(e as L);
        }
        rethrow;
      }
    });
  }

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
}
