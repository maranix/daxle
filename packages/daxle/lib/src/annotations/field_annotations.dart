import 'package:meta/meta.dart';

/// Overrides the field or enum case name when serializing to or deserializing from external payloads.
@immutable
class const SerializedValue(
  /// The wire key or value for serialization and deserialization.
  final Object value, {

  /// Custom converter instance or type implementing [DaxleJsonConverter].
  final Object? converter,
});

/// Injects a fallback value for an enum declaration or class field.
///
/// - **On Enum Declarations**: Replaces the default fail-fast parse failure with
///   the fallback case when incoming strings are unrecognized.
/// - **On Class Fields**: Injects the default value if the incoming key is missing or null.
@immutable
class const Fallback(
  /// The fallback value to use when missing, null, or unrecognized.
  final Object? value,
);

/// Completely strips the member from all generated logic
/// (serialization, deserialization, ==, hashCode, copyWith, toString).
@immutable
class const Ignore();

/// Constant instance of [Ignore] for concise `@ignore` annotation.
const ignore = Ignore();
