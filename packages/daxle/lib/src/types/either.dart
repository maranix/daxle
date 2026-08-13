import 'package:meta/meta.dart';

/// {@template either}
/// Represents a value of one of two possible types.
///
/// An instance of [Either] is either an instance of [Left] or [Right].
/// By convention, [Left] is used for failure/error and [Right] is used for success.
/// {@endtemplate}
@immutable
sealed class const Either<L, R>() {
  /// {@template either_left}
  /// Creates a [Left] instance of [Either].
  ///
  /// This is equivalent to constructing a `Left(value)`.
  ///
  /// Example:
  /// ```dart
  /// Either<String, int> x = Either.left('error'); // Left('error')
  /// print(x.isLeft); // true
  /// ```
  /// {@endtemplate}
  const factory left(L value) = Left<L, R>;

  /// {@template either_right}
  /// Creates a [Right] instance of [Either].
  ///
  /// This is equivalent to constructing a `Right(value)`.
  ///
  /// Example:
  /// ```dart
  /// Either<String, int> y = Either.right(42); // Right(42)
  /// print(y.isRight); // true
  /// ```
  /// {@endtemplate}
  const factory right(R value) = Right<L, R>;

  /// Creates an [Either] based on a boolean [condition].
  ///
  /// Returns [Right] with [right] if true, otherwise [Left] with [left].
  factory cond(bool condition, R Function() right, L Function() left) =>
      switch (condition) {
        true => Right<L, R>(right()),
        false => Left<L, R>(left()),
      };

  /// Returns `true` if this is a [Left] instance.
  bool get isLeft => this is Left<L, R>;

  /// Returns `true` if this is a [Right] instance.
  bool get isRight => this is Right<L, R>;

  /// Projects this [Either] into a value of type [B] by applying [ifLeft]
  /// if this is a [Left], or [ifRight] if this is a [Right].
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight);

  /// Applies [f] to the value inside [Right], returning a new [Either] containing the result.
  ///
  /// Returns the current [Left] unchanged if this is a [Left].
  Either<L, B> map<B>(B Function(R right) f);

  /// Applies [f] to the value inside [Left], returning a new [Either] containing the result.
  ///
  /// Returns the current [Right] unchanged if this is a [Right].
  Either<B, R> mapLeft<B>(B Function(L left) f);

  /// Applies [mapLeft] to the error value if this is a [Left], or [mapRight]
  /// to the success value if this is a [Right].
  Either<L2, R2> bimap<L2, R2>(
    L2 Function(L left) mapLeft,
    R2 Function(R right) mapRight,
  );

  /// Applies [f] to the value inside [Right], returning the resulting [Either].
  ///
  /// Returns the current [Left] unchanged if this is a [Left].
  Either<L, B> flatMap<B>(Either<L, B> Function(R right) f);

  /// Runs the provided [callback] on the [Right] value of this [Either] without modifying it.
  ///
  /// The callback is executed only if this [Either] is a [Right].
  Either<L, R> tap(void Function(R value) callback);

  /// Runs the provided [callback] on the [Left] value of this [Either] without modifying it.
  ///
  /// The callback is executed only if this [Either] is a [Left].
  Either<L, R> tapLeft(void Function(L error) callback);

  /// Ensures that the [Right] value of this [Either] satisfies the [predicate].
  ///
  /// If this [Either] is a [Right] and the [predicate] returns `true`, the value continues unchanged.
  /// If it returns `false`, the result is a [Left] with the value returned by [onFailure].
  /// If this [Either] is a [Left], it is returned unchanged.
  Either<L, R> ensure(
    bool Function(R value) predicate,
    L Function() onFailure,
  );

  /// Recovers from a [Left] failure by returning the result of [f].
  Either<L, R> orElse(Either<L, R> Function(L left) f);

  /// Returns the value inside [Right], or the result of [dflt] if this is a [Left].
  R getOrElse(R Function(L left) dflt);

  /// Executes an [Iterable] of [Either]s sequentially, collecting their successful results.
  ///
  /// If any value is a [Left], execution stops immediately and that error is returned.
  /// Otherwise, returns a [Right] containing a list of all successful values.
  static Either<L, List<R>> sequence<L, R>(Iterable<Either<L, R>> items) {
    final results = <R>[];
    for (final item in items) {
      switch (item) {
        case Left(value: final l):
          return Left<L, List<R>>(l);
        case Right(value: final r):
          results.add(r);
      }
    }
    return Right<L, List<R>>(results);
  }

  /// Maps each element of [items] to an [Either] using [mapper], and collects the results.
  ///
  /// If any mapped value is a [Left], execution stops immediately and that error is returned.
  /// Otherwise, returns a [Right] containing a list of all mapped values.
  static Either<L, List<B>> traverse<L, A, B>(
    Iterable<A> items,
    Either<L, B> Function(A item) mapper,
  ) {
    final results = <B>[];
    for (final item in items) {
      final either = mapper(item);
      switch (either) {
        case Left(value: final l):
          return Left<L, List<B>>(l);
        case Right(value: final r):
          results.add(r);
      }
    }
    return Right<L, List<B>>(results);
  }

  /// Executes [run] synchronously and catches any exceptions.
  ///
  /// If [run] completes successfully, returns [Right].
  /// If [run] throws an exception, passes it to [onError] and returns [Left].
  static Either<L, R> tryCatch<L, R>(
    R Function() run,
    L Function(Object error, StackTrace stackTrace) onError,
  ) {
    try {
      return Right<L, R>(run());
    } catch (e, st) {
      return Left<L, R>(onError(e, st));
    }
  }
}

/// {@template left}
/// Represents the Left side of [Either], usually holding an error/failure value.
/// {@endtemplate}
final class const Left<L, R>(final L value) extends Either<L, R> {
  @override
  @pragma('vm:prefer-inline')
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) =>
      ifLeft(value);

  @override
  @pragma('vm:prefer-inline')
  Either<L, B> map<B>(B Function(R right) f) => Left<L, B>(value);

  @override
  @pragma('vm:prefer-inline')
  Either<B, R> mapLeft<B>(B Function(L left) f) => Left<B, R>(f(value));

  @override
  @pragma('vm:prefer-inline')
  Either<L2, R2> bimap<L2, R2>(
    L2 Function(L left) mapLeft,
    R2 Function(R right) mapRight,
  ) => Left<L2, R2>(mapLeft(value));

  @override
  @pragma('vm:prefer-inline')
  Either<L, B> flatMap<B>(Either<L, B> Function(R right) f) =>
      Left<L, B>(value);

  @override
  Either<L, R> tap(void Function(R value) callback) => this;

  @override
  Either<L, R> tapLeft(void Function(L error) callback) {
    callback(value);
    return this;
  }

  @override
  Either<L, R> ensure(
    bool Function(R value) predicate,
    L Function() onFailure,
  ) => this;

  @override
  Either<L, R> orElse(Either<L, R> Function(L left) f) => f(value);

  @override
  R getOrElse(R Function(L left) dflt) => dflt(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// {@template right}
/// Represents the Right side of [Either], usually holding a success value.
/// {@endtemplate}
final class const Right<L, R>(final R value) extends Either<L, R> {
  @override
  @pragma('vm:prefer-inline')
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) =>
      ifRight(value);

  @override
  @pragma('vm:prefer-inline')
  Either<L, B> map<B>(B Function(R right) f) => Right<L, B>(f(value));

  @override
  @pragma('vm:prefer-inline')
  Either<B, R> mapLeft<B>(B Function(L left) f) => Right<B, R>(value);

  @override
  @pragma('vm:prefer-inline')
  Either<L2, R2> bimap<L2, R2>(
    L2 Function(L left) mapLeft,
    R2 Function(R right) mapRight,
  ) => Right<L2, R2>(mapRight(value));

  @override
  @pragma('vm:prefer-inline')
  Either<L, B> flatMap<B>(Either<L, B> Function(R right) f) => f(value);

  @override
  Either<L, R> tap(void Function(R value) callback) {
    callback(value);
    return this;
  }

  @override
  Either<L, R> tapLeft(void Function(L error) callback) => this;

  @override
  Either<L, R> ensure(
    bool Function(R value) predicate,
    L Function() onFailure,
  ) => predicate(value) ? this : Left<L, R>(onFailure());

  @override
  Either<L, R> orElse(Either<L, R> Function(L left) f) => this;

  @override
  R getOrElse(R Function(L left) dflt) => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
