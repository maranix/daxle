import 'package:meta/meta.dart';

import 'case_style.dart';

/// Marks an enum for serialization generation (`enumMap` / `toValue`).
@Deprecated('Use @Serialize or @serialize instead')
@immutable
class const SerializeEnum({
  /// Targeted property name for enhanced enums (e.g. `code`).
  final String? valueField,

  /// Case style for serializing enum values when [valueField] is omitted.
  final CaseStyle? caseStyle,
});

/// Constant instance of [SerializeEnum] for concise `@serializeEnum` annotation.
@Deprecated('Use @Serialize or @serialize instead')
const serializeEnum = SerializeEnum();

/// Marks an enum for deserialization generation (`fromValue`).
@Deprecated('Use @Deserialize or @deserialize instead')
@immutable
class const DeserializeEnum({
  /// Targeted property name for enhanced enums (e.g. `code`).
  final String? valueField,

  /// Case style for deserializing enum values when [valueField] is omitted.
  final CaseStyle? caseStyle,
});

/// Constant instance of [DeserializeEnum] for concise `@deserializeEnum` annotation.
@Deprecated('Use @Deserialize or @deserialize instead')
const deserializeEnum = DeserializeEnum();
