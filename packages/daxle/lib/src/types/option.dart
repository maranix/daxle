import 'package:meta/meta.dart';

/// {@template option}
/// Represents either the presence [Some] or absence [None] of a value of type [T].
///
/// [Option] is an alternative to using nullable types (`T?`) that allows for
/// fluent chaining of operations.
/// {@endtemplate}
@immutable
sealed class Option<T> {
  /// {@macro option}
  const Option();

  /// {@template option_some}
  /// Creates an [Option] containing a value of type [T].
  ///
  /// This is equivalent to constructing a `Some(value)`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> x = Option.some(5); // Some(5)
  /// print(x.isSome); // true
  /// ```
  /// {@endtemplate}
  const factory Option.some(T value) = Some<T>;

  /// {@template option_none}
  /// Creates an [Option] representing the absence of a value.
  ///
  /// This is equivalent to constructing a `const None()`.
  ///
  /// Example:
  /// ```dart
  /// Option<int> y = const Option.none(); // None
  /// print(y.isNone); // true
  /// ```
  /// {@endtemplate}
  const factory Option.none() = None<T>;

  /// Creates an [Option] from a nullable [value].
  ///
  /// Returns [Some] if the value is not null, otherwise [None].
  factory Option.fromNullable(T? value) =>
      value != null ? Some(value) : None<T>();

  /// Creates an [Option] wrapping [value] in [Some] if it matches [predicate], otherwise returning [None].
  factory Option.fromPredicate(T value, bool Function(T value) predicate) =>
      predicate(value) ? Some(value) : None<T>();

  /// Returns `true` if this is a [Some] instance.
  bool get isSome => this is Some<T>;

  /// Returns `true` if this is a [None] instance.
  bool get isNone => this is None<T>;

  /// Projects this [Option] into a value of type [B] by applying [ifSome]
  /// if a value is present, or [ifNone] if it is not.
  B fold<B>(B Function() ifNone, B Function(T value) ifSome) {
    return switch (this) {
      Some(value: final v) => ifSome(v),
      None() => ifNone(),
    };
  }

  /// Applies [f] to the value inside [Some], returning a new [Option] containing the result.
  ///
  /// Returns [None] if this is a [None].
  Option<B> map<B>(B Function(T value) f) {
    return fold(() => None<B>(), (v) => Some(f(v)));
  }

  /// Applies [f] to the value inside [Some], returning the resulting [Option].
  ///
  /// Returns [None] if this is a [None].
  Option<B> flatMap<B>(Option<B> Function(T value) f) {
    return fold(() => None<B>(), (v) => f(v));
  }

  /// Returns the value if this is a [Some], otherwise throws [StateError].
  T get() => switch (this) {
    Some(:final value) => value,
    None() => throw StateError('Cannot retrieve value from a None instance'),
  };

  /// Returns the value if this is a [Some], otherwise returns [dflt].
  T getOrElse(T dflt) => switch (this) {
    Some(:final value) => value,
    None() => dflt,
  };

  /// Converts this [Option] to a nullable type.
  T? toNullable() => switch (this) {
    Some(:final value) => value,
    None() => null,
  };

  /// Filters this [Option], returning [Some] if the value matches [predicate], otherwise returning [None].
  Option<T> filter(bool Function(T value) predicate) => fold(
    () => const .none(),
    (value) => predicate(value) ? this : None<T>(),
  );
}

/// {@template some}
/// Represents the presence of a value of type [T].
/// {@endtemplate}
final class Some<T> extends Option<T> {
  final T value;

  /// {@macro some}
  const Some(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Some<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some($value)';
}

/// {@template none}
/// Represents the absence of a value.
/// {@endtemplate}
final class None<T> extends Option<T> {
  /// {@macro none}
  const None();

  @override
  bool operator ==(Object other) => other is None<T>;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None';
}
