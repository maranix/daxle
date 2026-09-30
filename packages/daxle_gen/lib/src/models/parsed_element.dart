import 'case_style.dart';

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
  final String? partOfPath;

  const ParsedField({
    required this.name,
    required this.type,
    required this.config,
    this.isFinal = true,
    this.hasDefaultValue = false,
    this.defaultValueCode,
    this.partOfPath,
  });

  String resolvedWireKey(CaseStyle? classCaseStyle) {
    if (config.serializedKey != null) return config.serializedKey!;
    if (classCaseStyle != null) {
      return classCaseStyle.transform(name);
    }
    return name;
  }

  String resolvedSerializeKey(CaseStyle? classCaseStyle) =>
      resolvedWireKey(classCaseStyle);

  String resolvedDeserializeKey(CaseStyle? classCaseStyle) =>
      resolvedWireKey(classCaseStyle);

  bool isIgnoredForSerialize(SerializeInfo? classSerialize) =>
      config.isIgnored ||
      (classSerialize?.ignoreFields.contains(name) ?? false);

  bool isIgnoredForDeserialize(DeserializeInfo? classDeserialize) =>
      config.isIgnored ||
      (classDeserialize?.ignoreFields.contains(name) ?? false);

  bool isIgnoredForEquals(EqualsAndHashCodeInfo? info) =>
      config.isIgnored || (info?.ignoreFields.contains(name) ?? false);

  bool isIgnoredForStringify(StringifyInfo? info) =>
      config.isIgnored || (info?.ignoreFields.contains(name) ?? false);

  bool isIgnoredForCopyWith(CopyWithInfo? info) =>
      config.isIgnored || (info?.ignoreFields.contains(name) ?? false);

  String get jsonKey => config.serializedKey ?? name;
  String get serializeKey => config.serializedKey ?? name;
  String get deserializeKey => config.serializedKey ?? name;
  List<String> get aliases => config.aliases;
  bool get isFlattened => config.isFlattened;
  String get flattenPrefix => config.flattenPrefix;
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
    if (config.serializedKey != null) return config.serializedKey!;
    if (classCaseStyle != null) {
      return classCaseStyle.transform(name);
    }
    return name;
  }

  bool isIgnoredForDeserialize(DeserializeInfo? classDeserialize) =>
      config.isIgnored ||
      (classDeserialize?.ignoreFields.contains(name) ?? false);

  bool isIgnoredForCopyWith(CopyWithInfo? info) =>
      config.isIgnored || (info?.ignoreFields.contains(name) ?? false);

  String get jsonKey => config.serializedKey ?? name;
  String get deserializeKey => config.serializedKey ?? name;
  List<String> get aliases => config.aliases;
  bool get isFlattened => config.isFlattened;
  String get flattenPrefix => config.flattenPrefix;
}

/// Represents a parsed class definition.
class ParsedClass {
  final String name;
  final bool isSealed;
  final String? superclass;
  final List<String> interfaces;
  final SerializeInfo? serialize;
  final DeserializeInfo? deserialize;
  final EqualsAndHashCodeInfo? equalsAndHashCode;
  final StringifyInfo? stringify;
  final CopyWithInfo? copyWith;
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
    this.equalsAndHashCode,
    this.stringify,
    this.copyWith,
    this.customDiscriminatorName,
    required this.fields,
    required this.constructorParams,
    this.constructorName = '',
    this.isPrimaryConstructor = false,
  });

  bool get shouldSerialize => serialize != null;
  bool get shouldDeserialize => deserialize != null;
  bool get shouldEqualsAndHashCode => equalsAndHashCode != null;
  bool get shouldStringify => stringify != null;
  bool get shouldCopyWith => copyWith != null;

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

  bool get isIgnored => config.isIgnored;
  List<String> get aliases => config.aliases;

  String resolvedValue(CaseStyle? enumCaseStyle) =>
      resolvedWireValue(enumCaseStyle);

  String resolvedWireValue(CaseStyle? enumCaseStyle) {
    if (config.serializedKey != null) {
      final key = config.serializedKey!;
      if (key.startsWith("'") ||
          key.startsWith('"') ||
          int.tryParse(key) != null) {
        return key;
      }
      return "'$key'";
    }
    if (explicitValueCode != null) return explicitValueCode!;
    if (enumCaseStyle != null) {
      return "'${enumCaseStyle.transform(name)}'";
    }
    return "'$name'";
  }

  String resolvedSerializeValue(CaseStyle? enumCaseStyle) =>
      resolvedWireValue(enumCaseStyle);

  String resolvedDeserializeValue(CaseStyle? enumCaseStyle) =>
      resolvedWireValue(enumCaseStyle);
}

/// Represents a parsed enum definition.
class ParsedEnum {
  final String name;
  final SerializeInfo? serialize;
  final DeserializeInfo? deserialize;
  final StringifyInfo? stringify;
  final String? valueFieldName;
  final ParsedType? valueFieldType;
  final List<ParsedEnumConstant> constants;
  final String? fallbackCaseCode;

  const ParsedEnum({
    required this.name,
    this.serialize,
    this.deserialize,
    this.stringify,
    this.valueFieldName,
    this.valueFieldType,
    required this.constants,
    this.fallbackCaseCode,
  });

  bool get shouldSerialize => serialize != null;
  bool get shouldDeserialize => deserialize != null;
  bool get shouldStringify => stringify != null;
}

/// Represents a parsed extension type definition.
class ParsedExtensionType {
  final String name;
  final String representationFieldName;
  final ParsedType representationType;
  final SerializeInfo? serialize;
  final DeserializeInfo? deserialize;

  const ParsedExtensionType({
    required this.name,
    required this.representationFieldName,
    required this.representationType,
    this.serialize,
    this.deserialize,
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
  final List<ParsedExtensionType> extensionTypes;
  final List<String> partDirectives;
  final Map<String, List<BundledAnnotation>> bundleDeclarations;
  String? partOfPath;

  ParsedFile({
    required this.filePath,
    required this.fileName,
    required this.classes,
    required this.enums,
    this.extensionTypes = const [],
    this.partDirectives = const [],
    this.bundleDeclarations = const {},
    this.partOfPath,
  });

  bool get hasDaxleAnnotations =>
      classes.any(
        (c) =>
            c.shouldSerialize ||
            c.shouldDeserialize ||
            c.shouldEqualsAndHashCode ||
            c.shouldStringify ||
            c.shouldCopyWith,
      ) ||
      enums.any(
        (e) => e.shouldSerialize || e.shouldDeserialize || e.shouldStringify,
      ) ||
      extensionTypes.any((e) => e.shouldSerialize || e.shouldDeserialize);

  bool get hasDaxlePartDirective =>
      partDirectives.any((p) => p.endsWith('.daxle.dart'));
}
