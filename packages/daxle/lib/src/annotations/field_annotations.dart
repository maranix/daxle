import 'package:meta/meta.dart';
import 'case_style.dart';

/// Customizes serialization behavior for an individual field or enum entry.
@immutable
class const SerializeValue({
  /// Custom JSON key name. If omitted, defaults to the field name (or transformed by [CaseStyle]).
  final String? name,

  /// Field-specific case style override.
  final CaseStyle? caseStyle,

  /// Fallback value expression or literal when value is null or omitted.
  final Object? fallback,

  /// Custom converter instance or type implementing [DaxleJsonConverter].
  final Object? converter,

  /// Whether to ignore this field or enum entry during serialization.
  final bool ignore = false,
});

/// Customizes deserialization behavior for an individual field, parameter, or enum entry.
@immutable
class const DeserializeValue({
  /// Custom JSON key name. If omitted, defaults to the field name (or transformed by [CaseStyle]).
  final String? name,

  /// Field-specific case style override.
  final CaseStyle? caseStyle,

  /// Fallback value to use when the JSON key is missing or null.
  final Object? fallback,

  /// Custom converter instance or type implementing [DaxleJsonConverter].
  final Object? converter,

  /// Whether to ignore this field or enum entry during deserialization.
  final bool ignore = false,
});
