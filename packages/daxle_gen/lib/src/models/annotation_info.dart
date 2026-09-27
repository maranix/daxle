import 'package:daxle/daxle.dart';

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

/// Field-level or parameter-level configuration from `@SerializeValue` and `@DeserializeValue`.
class FieldConfig {
  final String? serializeKey;
  final String? deserializeKey;
  final CaseStyle? serializeCaseStyle;
  final CaseStyle? deserializeCaseStyle;
  final String? fallbackCode;
  final String? serializeFallbackCode;
  final String? converterCode;
  final String? serializeConverterCode;
  final bool ignoreSerialize;
  final bool ignoreDeserialize;

  const FieldConfig({
    this.serializeKey,
    this.deserializeKey,
    this.serializeCaseStyle,
    this.deserializeCaseStyle,
    this.fallbackCode,
    this.serializeFallbackCode,
    this.converterCode,
    this.serializeConverterCode,
    this.ignoreSerialize = false,
    this.ignoreDeserialize = false,
  });

  String? get effectiveSerializeKey => serializeKey;
  String? get effectiveDeserializeKey => deserializeKey;
  String? get effectiveSerializeConverter =>
      serializeConverterCode ?? converterCode;
  String? get effectiveDeserializeConverter => converterCode;

  FieldConfig merge(FieldConfig other) {
    return FieldConfig(
      serializeKey: other.serializeKey ?? serializeKey,
      deserializeKey: other.deserializeKey ?? deserializeKey,
      serializeCaseStyle: other.serializeCaseStyle ?? serializeCaseStyle,
      deserializeCaseStyle: other.deserializeCaseStyle ?? deserializeCaseStyle,
      fallbackCode: other.fallbackCode ?? fallbackCode,
      serializeFallbackCode:
          other.serializeFallbackCode ?? serializeFallbackCode,
      converterCode: other.converterCode ?? converterCode,
      serializeConverterCode:
          other.serializeConverterCode ?? serializeConverterCode,
      ignoreSerialize: ignoreSerialize || other.ignoreSerialize,
      ignoreDeserialize: ignoreDeserialize || other.ignoreDeserialize,
    );
  }
}
