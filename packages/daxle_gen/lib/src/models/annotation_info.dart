/// Parsed metadata for `@Serialize` and `@serialize`.
class SerializeInfo {
  final String? valueField;
  final String? discriminator;
  final bool explicitToJson;

  const SerializeInfo({
    this.valueField,
    this.discriminator,
    this.explicitToJson = true,
  });
}

/// Parsed metadata for `@Deserialize` and `@deserialize`.
class DeserializeInfo {
  final String? valueField;
  final String? discriminator;
  final bool explicitFromJson;

  const DeserializeInfo({
    this.valueField,
    this.discriminator,
    this.explicitFromJson = true,
  });
}

/// Field-level or parameter-level configuration from `@SerializeValue` and `@DeserializeValue`.
class FieldConfig {
  final String? serializeKey;
  final String? deserializeKey;
  final String? defaultValueCode;
  final String? serializeDefaultValueCode;
  final String? converterCode;
  final String? serializeConverterCode;
  final bool ignoreSerialize;
  final bool ignoreDeserialize;

  const FieldConfig({
    String? jsonKey,
    this.serializeKey,
    this.deserializeKey,
    this.defaultValueCode,
    this.serializeDefaultValueCode,
    this.converterCode,
    this.serializeConverterCode,
    this.ignoreSerialize = false,
    this.ignoreDeserialize = false,
  })  : _legacyJsonKey = jsonKey;

  final String? _legacyJsonKey;

  String? get jsonKey => _legacyJsonKey ?? deserializeKey ?? serializeKey;
  String? get effectiveSerializeKey => serializeKey ?? _legacyJsonKey;
  String? get effectiveDeserializeKey => deserializeKey ?? _legacyJsonKey;
  String? get effectiveSerializeConverter => serializeConverterCode ?? converterCode;
  String? get effectiveDeserializeConverter => converterCode;

  FieldConfig merge(FieldConfig other) {
    return FieldConfig(
      serializeKey: other.serializeKey ?? serializeKey ?? other._legacyJsonKey ?? _legacyJsonKey,
      deserializeKey: other.deserializeKey ?? deserializeKey ?? other._legacyJsonKey ?? _legacyJsonKey,
      defaultValueCode: other.defaultValueCode ?? defaultValueCode,
      serializeDefaultValueCode: other.serializeDefaultValueCode ?? serializeDefaultValueCode,
      converterCode: other.converterCode ?? converterCode,
      serializeConverterCode: other.serializeConverterCode ?? serializeConverterCode,
      ignoreSerialize: ignoreSerialize || other.ignoreSerialize,
      ignoreDeserialize: ignoreDeserialize || other.ignoreDeserialize,
    );
  }
}

