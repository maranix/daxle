import 'package:daxle/daxle.dart';

import '../parser/generation_error.dart';

/// Parsed metadata for `@Serialize` / `@SerializeClass`.
class SerializeInfo {
  final String? discriminator;
  final CaseStyle? caseStyle;
  final Set<String> ignoreFields;

  const SerializeInfo({
    this.discriminator,
    this.caseStyle,
    this.ignoreFields = const {},
  });
}

/// Parsed metadata for `@Deserialize` / `@DeserializeClass`.
class DeserializeInfo {
  final String? discriminator;
  final CaseStyle? caseStyle;
  final Set<String> ignoreFields;

  const DeserializeInfo({
    this.discriminator,
    this.caseStyle,
    this.ignoreFields = const {},
  });
}

/// Parsed metadata for `@EqualsAndHashCode`.
class EqualsAndHashCodeInfo {
  final Set<String> ignoreFields;

  const EqualsAndHashCodeInfo({
    this.ignoreFields = const {},
  });
}

/// Parsed metadata for `@Stringify`.
class StringifyInfo {
  final Set<String> ignoreFields;

  const StringifyInfo({
    this.ignoreFields = const {},
  });
}

/// Parsed metadata for `@CopyWith`.
class CopyWithInfo {
  final Set<String> ignoreFields;

  const CopyWithInfo({
    this.ignoreFields = const {},
  });
}

/// Parsed metadata for `@SerializeEnum`.
class SerializeEnumInfo {
  final String? valueField;
  final CaseStyle? caseStyle;

  const SerializeEnumInfo({
    this.valueField,
    this.caseStyle,
  });
}

/// Parsed metadata for `@DeserializeEnum`.
class DeserializeEnumInfo {
  final String? valueField;
  final CaseStyle? caseStyle;

  const DeserializeEnumInfo({
    this.valueField,
    this.caseStyle,
  });
}

/// Field-level or parameter-level configuration from `@SerializedValue`, `@Fallback`, and `@ignore`.
class FieldConfig {
  final String? serializedKey;
  final String? fallbackCode;
  final String? converterCode;
  final bool isIgnored;

  const FieldConfig({
    this.serializedKey,
    this.fallbackCode,
    this.converterCode,
    this.isIgnored = false,
  });

  String? get effectiveSerializeKey => serializedKey;
  String? get effectiveDeserializeKey => serializedKey;
  String? get effectiveSerializeConverter => converterCode;
  String? get effectiveDeserializeConverter => converterCode;
  bool get ignoreSerialize => isIgnored;
  bool get ignoreDeserialize => isIgnored;

  FieldConfig merge(FieldConfig other, [String memberName = 'member']) {
    final mergedIgnored = isIgnored || other.isIgnored;
    final mergedKey = other.serializedKey ?? serializedKey;
    final mergedFallback = other.fallbackCode ?? fallbackCode;
    final mergedConverter = other.converterCode ?? converterCode;

    if (mergedIgnored && (mergedKey != null || mergedFallback != null)) {
      throw InvalidGenerationSourceError(
        '@ignore cannot coexist with @SerializedValue or @Fallback on "$memberName".',
        todo:
            'Remove either @ignore or @SerializedValue/@Fallback from "$memberName".',
      );
    }

    return FieldConfig(
      serializedKey: mergedKey,
      fallbackCode: mergedFallback,
      converterCode: mergedConverter,
      isIgnored: mergedIgnored,
    );
  }
}
