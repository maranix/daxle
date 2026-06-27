/// Represents a type with a single value. Used in functional programming
/// to represent the absence of a meaningful value (similar to void but usable
/// as a generic type parameter).
final class Unit {
  const Unit._();

  @override
  String toString() => '()';
}

/// The single value of the [Unit] type.
const Unit unit = Unit._();
