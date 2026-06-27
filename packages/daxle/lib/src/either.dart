import 'package:meta/meta.dart';

/// Represents a value of one of two possible types.
///
/// An instance of [Either] is either an instance of [Left] or [Right].
/// By convention, [Left] is used for failure/error and [Right] is used for success.
@immutable
sealed class Either<L, R> {
  const Either();

  /// Creates a [Left] instance of [Either].
  const factory Either.left(L value) = Left<L, R>;

  /// Creates a [Right] instance of [Either].
  const factory Either.right(R value) = Right<L, R>;

  /// Creates an [Either] based on a boolean [condition].
  ///
  /// Returns [Right] with [right] if true, otherwise [Left] with [left].
  factory Either.cond(bool condition, R right, L left) =>
      condition ? Right<L, R>(right) : Left<L, R>(left);

  /// Returns `true` if this is a [Left] instance.
  bool get isLeft => this is Left<L, R>;

  /// Returns `true` if this is a [Right] instance.
  bool get isRight => this is Right<L, R>;

  /// Projects this [Either] into a value of type [B] by applying [ifLeft]
  /// if this is a [Left], or [ifRight] if this is a [Right].
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) {
    return switch (this) {
      Left(value: final l) => ifLeft(l),
      Right(value: final r) => ifRight(r),
    };
  }

  /// Applies [f] to the value inside [Right], returning a new [Either] containing the result.
  ///
  /// Returns the current [Left] unchanged if this is a [Left].
  Either<L, B> map<B>(B Function(R right) f) {
    return fold((l) => Left<L, B>(l), (r) => Right<L, B>(f(r)));
  }

  /// Applies [f] to the value inside [Left], returning a new [Either] containing the result.
  ///
  /// Returns the current [Right] unchanged if this is a [Right].
  Either<B, R> mapLeft<B>(B Function(L left) f) {
    return fold((l) => Left<B, R>(f(l)), (r) => Right<B, R>(r));
  }

  /// Applies [f] to the value inside [Right], returning the resulting [Either].
  ///
  /// Returns the current [Left] unchanged if this is a [Left].
  Either<L, B> flatMap<B>(Either<L, B> Function(R right) f) {
    return fold((l) => Left<L, B>(l), (r) => f(r));
  }

  /// Returns the value inside [Right], or the result of [dflt] if this is a [Left].
  R getOrElse(R Function(L left) dflt) {
    return fold(dflt, (r) => r);
  }
}

/// Represents the Left side of [Either], usually holding an error/failure value.
final class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Represents the Right side of [Either], usually holding a success value.
final class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
