import 'package:meta/meta.dart';

import 'case_style.dart';

/// Marks a class, enum, or extension type for serialization generation (`toMap` / `toValue`).
@immutable
class const Serialize({
  /// Discriminator field name for sealed classes (defaults to `'type'`).
  final String? discriminator,

  /// Targeted property name for enhanced enums (e.g. `'code'`).
  final String? valueField,

  /// Case style for serializing field names unless overridden by [SerializedValue].
  final CaseStyle? caseStyle,

  /// Field names to ignore during serialization.
  final Iterable<String> ignoreFields = const [],
});

/// Constant instance of [Serialize] for concise `@serialize` annotation.
const serialize = Serialize();


/// Marks a class, enum, or extension type for deserialization generation (`fromJson` / `fromValue`).
@immutable
class const Deserialize({
  /// Discriminator field name for sealed classes (defaults to `'type'`).
  final String? discriminator,

  /// Targeted property name for enhanced enums (e.g. `'code'`).
  final String? valueField,

  /// Case style for deserializing field names unless overridden by [SerializedValue].
  final CaseStyle? caseStyle,

  /// Field names to ignore during deserialization.
  final Iterable<String> ignoreFields = const [],
});

/// Constant instance of [Deserialize] for concise `@deserialize` annotation.
const deserialize = Deserialize();
