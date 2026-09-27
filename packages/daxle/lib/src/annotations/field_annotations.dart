import 'package:meta/meta.dart';

/// Overrides the field or enum case name when serializing to or deserializing from external payloads.
@immutable
class const SerializedValue(
  /// The canonical wire key or value for serialization and deserialization.
  final Object value, {

  /// Alternative wire keys recognized during deserialization.
  final List<String> aliases = const [],

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

/// Inlines nested object fields directly into the parent JSON map,
/// optionally prepending [prefix] to keys.
@immutable
class const Flatten({
  /// Optional string prepended to all child keys in the parent map.
  final String prefix = '',
});

/// Constant instance of [Flatten] for concise `@flatten` annotation.
const flatten = Flatten();

/// Completely strips the member from all generated logic
/// (serialization, deserialization, ==, hashCode, copyWith, toString).
@immutable
class const Ignore();

/// Constant instance of [Ignore] for concise `@ignore` annotation.
const ignore = Ignore();
