import 'package:daxle/daxle.dart';
import 'annotation_info.dart';
import 'parsed_type.dart';

/// Represents a class field.
class ParsedField {
  final String name;
  final ParsedType type;
  final FieldConfig config;
  final bool isFinal;
  final bool hasDefaultValue;
  final String? defaultValueCode;

  const ParsedField({
    required this.name,
    required this.type,
    required this.config,
    this.isFinal = true,
    this.hasDefaultValue = false,
    this.defaultValueCode,
  });

  String resolvedSerializeKey(CaseStyle? classCaseStyle) {
    if (config.serializeKey != null) return config.serializeKey!;
    if (config.serializeCaseStyle != null) {
      return config.serializeCaseStyle!.transform(name);
    }
    if (classCaseStyle != null) {
      return classCaseStyle.transform(name);
    }
    return name;
  }

  String resolvedDeserializeKey(CaseStyle? classCaseStyle) {
    if (config.deserializeKey != null) return config.deserializeKey!;
    if (config.deserializeCaseStyle != null) {
      return config.deserializeCaseStyle!.transform(name);
    }
    if (classCaseStyle != null) {
      return classCaseStyle.transform(name);
    }
    return name;
  }

  bool isIgnoredForSerialize(SerializeInfo? classSerialize) =>
      config.ignoreSerialize ||
      (classSerialize?.ignoreFields.contains(name) ?? false);

  bool isIgnoredForDeserialize(DeserializeInfo? classDeserialize) =>
      config.ignoreDeserialize ||
      (classDeserialize?.ignoreFields.contains(name) ?? false);

  String get jsonKey => config.serializeKey ?? config.deserializeKey ?? name;
  String get serializeKey => config.effectiveSerializeKey ?? name;
  String get deserializeKey => config.effectiveDeserializeKey ?? name;
}

/// Represents a constructor parameter.
class ParsedConstructorParam {
  final String name;
  final ParsedType type;
  final bool isNamed;
  final bool isRequired;
  final bool hasDefault;
  final String? defaultValueCode;
  final FieldConfig config;

  const ParsedConstructorParam({
    required this.name,
    required this.type,
    required this.isNamed,
    required this.isRequired,
    this.hasDefault = false,
    this.defaultValueCode,
    this.config = const FieldConfig(),
  });

  String resolvedDeserializeKey(CaseStyle? classCaseStyle) {
    if (config.deserializeKey != null) return config.deserializeKey!;
    if (config.deserializeCaseStyle != null) {
      return config.deserializeCaseStyle!.transform(name);
    }
    if (classCaseStyle != null) {
      return classCaseStyle.transform(name);
    }
    return name;
  }

  bool isIgnoredForDeserialize(DeserializeInfo? classDeserialize) =>
      config.ignoreDeserialize ||
      (classDeserialize?.ignoreFields.contains(name) ?? false);

  String get jsonKey => config.deserializeKey ?? config.serializeKey ?? name;
  String get deserializeKey => config.effectiveDeserializeKey ?? name;
}

/// Represents a parsed class definition.
class ParsedClass {
  final String name;
  final bool isSealed;
  final String? superclass;
  final List<String> interfaces;
  final SerializeInfo? serialize;
  final DeserializeInfo? deserialize;
  final String? customDiscriminatorName;
  final List<ParsedField> fields;
  final List<ParsedConstructorParam> constructorParams;
  final String constructorName;
  final bool isPrimaryConstructor;

  const ParsedClass({
    required this.name,
    required this.isSealed,
    this.superclass,
    this.interfaces = const [],
    this.serialize,
    this.deserialize,
    this.customDiscriminatorName,
    required this.fields,
    required this.constructorParams,
    this.constructorName = '',
    this.isPrimaryConstructor = false,
  });

  bool get shouldSerialize => serialize != null;
  bool get shouldDeserialize => deserialize != null;

  bool isSubclassOf(String parentName) =>
      superclass == parentName || interfaces.contains(parentName);
}

/// Represents an individual constant entry of an enum.
class ParsedEnumConstant {
  final String name;
  final String? explicitValueCode;
  final FieldConfig config;

  const ParsedEnumConstant({
    required this.name,
    this.explicitValueCode,
    this.config = const FieldConfig(),
  });

  String resolvedValue(CaseStyle? enumCaseStyle) =>
      resolvedSerializeValue(enumCaseStyle);

  String resolvedSerializeValue(CaseStyle? enumCaseStyle) {
    if (config.serializeKey != null) return "'${config.serializeKey}'";
    final customVal = config.serializeFallbackCode ?? config.fallbackCode;
    if (customVal != null) return customVal;
    if (config.serializeCaseStyle != null) {
      return "'${config.serializeCaseStyle!.transform(name)}'";
    }
    if (config.deserializeKey != null) return "'${config.deserializeKey}'";
    if (explicitValueCode != null) return explicitValueCode!;
    if (enumCaseStyle != null) {
      return "'${enumCaseStyle.transform(name)}'";
    }
    return "'$name'";
  }

  String resolvedDeserializeValue(CaseStyle? enumCaseStyle) {
    if (config.deserializeKey != null) return "'${config.deserializeKey}'";
    final customVal = config.fallbackCode ?? config.serializeFallbackCode;
    if (customVal != null) return customVal;
    if (config.deserializeCaseStyle != null) {
      return "'${config.deserializeCaseStyle!.transform(name)}'";
    }
    if (config.serializeKey != null) return "'${config.serializeKey}'";
    if (explicitValueCode != null) return explicitValueCode!;
    if (enumCaseStyle != null) {
      return "'${enumCaseStyle.transform(name)}'";
    }
    return "'$name'";
  }
}

/// Represents a parsed enum definition.
class ParsedEnum {
  final String name;
  final SerializeEnumInfo? serialize;
  final DeserializeEnumInfo? deserialize;
  final String? valueFieldName;
  final ParsedType? valueFieldType;
  final List<ParsedEnumConstant> constants;

  const ParsedEnum({
    required this.name,
    this.serialize,
    this.deserialize,
    this.valueFieldName,
    this.valueFieldType,
    required this.constants,
  });

  bool get shouldSerialize => serialize != null;
  bool get shouldDeserialize => deserialize != null;
}

/// Represents an entire parsed Dart file.
class ParsedFile {
  final String filePath;
  final String fileName;
  final List<ParsedClass> classes;
  final List<ParsedEnum> enums;
  final List<String> partDirectives;

  const ParsedFile({
    required this.filePath,
    required this.fileName,
    required this.classes,
    required this.enums,
    this.partDirectives = const [],
  });

  bool get hasDaxleAnnotations =>
      classes.any((c) => c.shouldSerialize || c.shouldDeserialize) ||
      enums.any((e) => e.shouldSerialize || e.shouldDeserialize);

  bool get hasDaxlePartDirective =>
      partDirectives.any((p) => p.endsWith('.daxle.dart'));
}
