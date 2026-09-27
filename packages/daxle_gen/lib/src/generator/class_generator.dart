import 'package:code_builder/code_builder.dart';

import '../models/annotation_info.dart';
import '../models/parsed_element.dart';
import '../models/parsed_type.dart';
import 'type_helper.dart';

/// Generates top-level functional serialization and deserialization for classes using [code_builder].
class ClassGenerator {
  final TypeHelper typeHelper;
  final DartEmitter _emitter;

  ClassGenerator(this.typeHelper)
      : _emitter = DartEmitter(useNullSafetySyntax: true);

  String _patternTypeFor(ParsedType type, FieldConfig? config) {
    if (config?.effectiveDeserializeConverter != null) {
      return 'Object';
    }
    if (type.isString) return 'String';
    if (type.isInt || type.isDouble || type.isNum) return 'num';
    if (type.isBool) return 'bool';
    if (type.isDateTime) return 'String';
    if (type.isUri || type.isBigInt) return 'String';
    if (type.isDuration) return 'num';
    if (type.isList || type.isSet) return 'List';
    if (type.isMap || type.isQueryMap) return 'Map';
    if (typeHelper.knownClasses.contains(type.baseName)) return 'Map';
    return 'Object';
  }

  String _patternArgExpr(ParsedType type, String varName, FieldConfig? config) {
    final converter = config?.effectiveDeserializeConverter;
    if (converter != null) {
      final prefix = converter.startsWith('const ') ? '' : 'const ';
      return '$prefix$converter.fromJson($varName)';
    }

    if (type.isString) {
      return varName;
    } else if (type.isInt) {
      return '$varName.toInt()';
    } else if (type.isDouble) {
      return '$varName.toDouble()';
    } else if (type.isNum) {
      return varName;
    } else if (type.isBool) {
      return varName;
    } else if (type.isDateTime) {
      return 'DateTime.parse($varName)';
    } else if (type.isUri) {
      return 'Uri.parse($varName)';
    } else if (type.isBigInt) {
      return 'BigInt.parse($varName)';
    } else if (type.isDuration) {
      return 'Duration(microseconds: $varName.toInt())';
    } else if (type.isQueryMap) {
      return 'QueryMap($varName.cast<Object?, Object?>())';
    } else if (typeHelper.knownEnums.contains(type.baseName)) {
      final fn = '${TypeHelper.toCamelCase(type.baseName)}FromValue';
      return '$fn($varName)';
    } else if (typeHelper.knownClasses.contains(type.baseName)) {
      final fn = '${TypeHelper.toCamelCase(type.baseName)}FromJson';
      return '$fn($varName as Map<String, dynamic>)';
    } else if (type.isList || type.isSet) {
      return typeHelper.generateDeserialize(
        type,
        varName,
        config: config,
        explicitFromJson: true,
      ).replaceFirst('($varName as List<dynamic>)', '$varName.cast<dynamic>()');
    } else if (type.isMap) {
      return typeHelper.generateDeserialize(
        type,
        varName,
        config: config,
        explicitFromJson: true,
      ).replaceFirst('($varName as Map<String, dynamic>)', '$varName.cast<String, dynamic>()');
    } else {
      return typeHelper.generateDeserialize(
        type,
        varName,
        config: config,
        explicitFromJson: true,
      );
    }
  }

  /// Builds the `fromJson` [Method] specification.
  Method buildFromJson(ParsedClass clazz) {
    final camelName = TypeHelper.toCamelCase(clazz.name);
    final caseStyle = clazz.deserialize?.caseStyle;

    final constructorName = clazz.constructorName.isEmpty
        ? clazz.name
        : '${clazz.name}.${clazz.constructorName}';

    final positionalArgs = <String>[];
    final namedArgs = <String>[];
    final handledFields = <String>{};
    final mapPatternEntries = <String>[];

    for (final param in clazz.constructorParams) {
      handledFields.add(param.name);
      if (param.isIgnoredForDeserialize(clazz.deserialize)) {
        if (!param.isNamed && param.hasDefault) {
          positionalArgs.add(param.defaultValueCode!);
        } else if (!param.isNamed) {
          positionalArgs.add('null as dynamic');
        }
        continue;
      }

      final key = param.resolvedDeserializeKey(caseStyle);
      final isRequiredInJson = !param.type.isNullable &&
          !param.type.isOption &&
          param.config.fallbackCode == null &&
          !param.hasDefault;

      final String deserializeExpr;
      if (isRequiredInJson) {
        final varName = '${param.name}Raw';
        final patternType = _patternTypeFor(param.type, param.config);
        mapPatternEntries.add("'$key': final $patternType $varName");
        deserializeExpr = _patternArgExpr(param.type, varName, param.config);
      } else {
        final jsonExpr = "json['$key']";
        deserializeExpr = typeHelper.generateDeserialize(
          param.type,
          jsonExpr,
          config: param.config,
          parameterDefaultCode: param.defaultValueCode,
          explicitFromJson: true,
        );
      }

      if (param.isNamed) {
        namedArgs.add('${param.name}: $deserializeExpr');
      } else {
        positionalArgs.add(deserializeExpr);
      }
    }

    final allArgs = [
      ...positionalArgs,
      ...namedArgs,
    ].join(', ');

    final unhandledFields = clazz.fields.where(
      (f) =>
          !handledFields.contains(f.name) &&
          !f.isFinal &&
          !f.isIgnoredForDeserialize(clazz.deserialize),
    );

    final bodyBuffer = StringBuffer();
    bodyBuffer.writeln('return switch (json) {');

    if (mapPatternEntries.isEmpty) {
      if (unhandledFields.isEmpty) {
        bodyBuffer.writeln('  _ => $constructorName($allArgs),');
      } else {
        bodyBuffer.writeln('  _ => () {');
        bodyBuffer.writeln('    final instance = $constructorName($allArgs);');
        for (final field in unhandledFields) {
          final key = field.resolvedDeserializeKey(caseStyle);
          final jsonExpr = "json['$key']";
          final deserializeExpr = typeHelper.generateDeserialize(
            field.type,
            jsonExpr,
            config: field.config,
            parameterDefaultCode: field.defaultValueCode,
            explicitFromJson: true,
          );
          bodyBuffer.writeln("    if (json.containsKey('$key')) {");
          bodyBuffer.writeln('      instance.${field.name} = $deserializeExpr;');
          bodyBuffer.writeln('    }');
        }
        bodyBuffer.writeln('    return instance;');
        bodyBuffer.writeln('  }(),');
      }
    } else {
      bodyBuffer.writeln('  {');
      for (final entry in mapPatternEntries) {
        bodyBuffer.writeln('    $entry,');
      }
      if (unhandledFields.isEmpty) {
        bodyBuffer.writeln('  } => $constructorName($allArgs),');
      } else {
        bodyBuffer.writeln('  } => () {');
        bodyBuffer.writeln('    final instance = $constructorName($allArgs);');
        for (final field in unhandledFields) {
          final key = field.resolvedDeserializeKey(caseStyle);
          final jsonExpr = "json['$key']";
          final deserializeExpr = typeHelper.generateDeserialize(
            field.type,
            jsonExpr,
            config: field.config,
            parameterDefaultCode: field.defaultValueCode,
            explicitFromJson: true,
          );
          bodyBuffer.writeln("    if (json.containsKey('$key')) {");
          bodyBuffer.writeln('      instance.${field.name} = $deserializeExpr;');
          bodyBuffer.writeln('    }');
        }
        bodyBuffer.writeln('    return instance;');
        bodyBuffer.writeln('  }(),');
      }
      bodyBuffer.writeln(
          "  _ => throw FormatException('Invalid JSON shape for ${clazz.name}: \$json'),");
    }

    bodyBuffer.write('};');

    return Method((b) => b
      ..name = '${camelName}FromJson'
      ..returns = refer(clazz.name)
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'json'
        ..type = refer('Map<String, dynamic>')))
      ..body = Code(bodyBuffer.toString()));
  }

  /// Builds the `toMap` [Method] specification.
  Method buildToMap(ParsedClass clazz) {
    final camelName = TypeHelper.toCamelCase(clazz.name);
    final caseStyle = clazz.serialize?.caseStyle;

    final buffer = StringBuffer();
    buffer.writeln('<String, dynamic>{');

    for (final field in clazz.fields) {
      if (field.isIgnoredForSerialize(clazz.serialize)) continue;

      final key = field.resolvedSerializeKey(caseStyle);
      final fieldExpr = 'instance.${field.name}';
      final hasSerializeDefault = field.config.serializeDefaultValueCode != null;

      if (field.type.isNullable &&
          !field.type.isOption &&
          !hasSerializeDefault) {
        final serializeNonNullExpr = typeHelper.generateSerializeNonNull(
          field.type,
          fieldExpr,
          config: field.config,
          explicitToJson: true,
        );
        buffer.writeln(
            "  if ($fieldExpr != null) '$key': $serializeNonNullExpr,");
      } else {
        final serializeExpr = typeHelper.generateSerialize(
          field.type,
          fieldExpr,
          config: field.config,
          explicitToJson: true,
        );
        buffer.writeln("  '$key': $serializeExpr,");
      }
    }

    buffer.write('}');

    return Method((b) => b
      ..name = '${camelName}ToMap'
      ..returns = refer('Map<String, dynamic>')
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'instance'
        ..type = refer(clazz.name)))
      ..lambda = true
      ..body = Code(buffer.toString()));
  }

  /// Generates the `fromJson` function as code string.
  String generateFromJson(ParsedClass clazz) {
    return buildFromJson(clazz).accept(_emitter).toString();
  }

  /// Generates the `toMap` function as code string.
  String generateToMap(ParsedClass clazz) {
    return buildToMap(clazz).accept(_emitter).toString();
  }
}
