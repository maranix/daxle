import 'package:meta/meta.dart';

/// Marks a class or enum for serialization generation (`toMap` / enum mappings).
@immutable
class Serialize {
  /// Targeted property name for enhanced enums (e.g. `code`).
  final String? valueField;

  /// Discriminator field name for sealed classes (defaults to `'type'`).
  final String? discriminator;

  /// Whether nested complex objects and collections should be explicitly serialized.
  final bool explicitToJson;

  const Serialize({
    this.valueField,
    this.discriminator,
    this.explicitToJson = true,
  });
}

/// Constant instance of [Serialize] for concise `@serialize` annotation.
const serialize = Serialize();

/// Marks a class or enum for deserialization generation (`fromJson` / enum mappings).
@immutable
class Deserialize {
  /// Targeted property name for enhanced enums (e.g. `code`).
  final String? valueField;

  /// Discriminator field name for sealed classes (defaults to `'type'`).
  final String? discriminator;

  /// Whether nested complex objects and collections should be explicitly deserialized.
  final bool explicitFromJson;

  const Deserialize({
    this.valueField,
    this.discriminator,
    this.explicitFromJson = true,
  });
}

/// Constant instance of [Deserialize] for concise `@deserialize` annotation.
const deserialize = Deserialize();

/// Customizes serialization behavior for an individual field or enum entry.
@immutable
class SerializeValue {
  /// Custom JSON key name. If omitted, defaults to the Dart field name.
  final String? name;

  /// Default fallback value expression or literal.
  final Object? defaultValue;

  /// Custom converter instance or type implementing [DaxleJsonConverter].
  final Object? converter;

  /// Whether to ignore this field during serialization.
  final bool ignore;

  const SerializeValue({
    this.name,
    this.defaultValue,
    this.converter,
    this.ignore = false,
  });
}

/// Customizes deserialization behavior for an individual field or parameter.
@immutable
class DeserializeValue {
  /// Custom JSON key name. If omitted, defaults to the Dart field name.
  final String? name;

  /// Default fallback value to use when the JSON key is missing or null.
  final Object? defaultValue;

  /// Custom converter instance or type implementing [DaxleJsonConverter].
  final Object? converter;

  /// Whether to ignore this field during deserialization.
  final bool ignore;

  const DeserializeValue({
    this.name,
    this.defaultValue,
    this.converter,
    this.ignore = false,
  });
}

/// Base contract for custom JSON converters.
abstract interface class DaxleJsonConverter<T, S> {
  const DaxleJsonConverter();

  /// Converts from JSON representation [json] of type [S] to Dart object [T].
  T fromJson(S json);

  /// Converts Dart object [object] of type [T] to JSON representation [S].
  S toJson(T object);
}
