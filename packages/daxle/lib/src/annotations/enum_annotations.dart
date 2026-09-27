import 'package:meta/meta.dart';
import 'case_style.dart';

/// Marks an enum for serialization generation (`enumMap` / `toValue`).
@immutable
class const SerializeEnum({
  /// Targeted property name for enhanced enums (e.g. `code`).
  final String? valueField,

  /// Case style for serializing enum values when [valueField] is omitted.
  final CaseStyle? caseStyle,
});

/// Constant instance of [SerializeEnum] for concise `@serializeEnum` annotation.
const serializeEnum = SerializeEnum();

/// Marks an enum for deserialization generation (`fromValue`).
@immutable
class const DeserializeEnum({
  /// Targeted property name for enhanced enums (e.g. `code`).
  final String? valueField,

  /// Case style for deserializing enum values when [valueField] is omitted.
  final CaseStyle? caseStyle,
});

/// Constant instance of [DeserializeEnum] for concise `@deserializeEnum` annotation.
const deserializeEnum = DeserializeEnum();
