import 'package:meta/meta.dart';
import 'case_style.dart';

/// Customizes serialization behavior for an individual field.
@immutable
class const SerializeValue({
  /// Custom JSON key name. If omitted, defaults to the field name (or transformed by [CaseStyle]).
  final String? name,

  /// Field-specific case style override.
  final CaseStyle? caseStyle,

  /// Default fallback value expression or literal.
  final Object? defaultValue,

  /// Custom converter instance or type implementing [DaxleJsonConverter].
  final Object? converter,

  /// Whether to ignore this field during serialization.
  final bool ignore = false,
});

/// Customizes deserialization behavior for an individual field or parameter.
@immutable
class const DeserializeValue({
  /// Custom JSON key name. If omitted, defaults to the field name (or transformed by [CaseStyle]).
  final String? name,

  /// Field-specific case style override.
  final CaseStyle? caseStyle,

  /// Default fallback value to use when the JSON key is missing or null.
  final Object? defaultValue,

  /// Custom converter instance or type implementing [DaxleJsonConverter].
  final Object? converter,

  /// Whether to ignore this field during deserialization.
  final bool ignore = false,
});
