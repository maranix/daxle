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
    } else if (typeHelper.knownExtensionTypes.contains(type.baseName)) {
      final fn = '${TypeHelper.toCamelCase(type.baseName)}FromMap';
      return '$fn($varName)';
    } else if (typeHelper.knownEnums.contains(type.baseName)) {
      final fn = '${TypeHelper.toCamelCase(type.baseName)}FromValue';
      return '$fn($varName)';
    } else if (typeHelper.knownClasses.contains(type.baseName)) {
      final fn = '${TypeHelper.toCamelCase(type.baseName)}FromMap';
      return '$fn($varName.cast<String, dynamic>())';
    } else if (type.isList || type.isSet) {
      return typeHelper
          .generateDeserialize(
            type,
            varName,
            config: config,
            explicitFromJson: true,
          )
          .replaceFirst(
            '($varName as List<dynamic>)',
            '$varName.cast<dynamic>()',
          );
    } else if (type.isMap) {
      return typeHelper
          .generateDeserialize(
            type,
            varName,
            config: config,
            explicitFromJson: true,
          )
          .replaceFirst(
            '($varName as Map<String, dynamic>)',
            '$varName.cast<String, dynamic>()',
          );
    } else {
      return typeHelper.generateDeserialize(
        type,
        varName,
        config: config,
        explicitFromJson: true,
      );
    }
  }

  String _dummyValueFor(ParsedType type) {
    if (type.isNullable) return 'null';
    if (type.isString) return "''";
    if (type.isInt) return '0';
    if (type.isDouble) return '0.0';
    if (type.isNum) return '0';
    if (type.isBool) return 'false';
    if (type.isList) return '[]';
    if (type.isSet) return '{}';
    if (type.isMap || type.isQueryMap) return '{}';
    if (type.baseName == 'Stopwatch') return 'Stopwatch()';
    if (type.baseName == 'Duration') return 'Duration.zero';
    if (type.baseName == 'DateTime') {
      return 'DateTime.fromMillisecondsSinceEpoch(0)';
    }
    return 'null as dynamic';
  }

  /// Builds the `fromMap` [Method] specification.
  Method buildFromMap(ParsedClass clazz) {
    final camelName = TypeHelper.toCamelCase(clazz.name);
    final caseStyle = clazz.deserialize?.caseStyle;

    final constructorName = clazz.constructorName.isEmpty
        ? clazz.name
        : '${clazz.name}.${clazz.constructorName}';

    final hasFlattenedOrAliases =
        clazz.fields.any(
          (f) => f.config.isFlattened || f.config.aliases.isNotEmpty,
        ) ||
        clazz.constructorParams.any(
          (p) => p.config.isFlattened || p.config.aliases.isNotEmpty,
        );

    if (hasFlattenedOrAliases) {
      final bodyBuffer = StringBuffer();
      final positionalArgs = <String>[];
      final namedArgs = <String>[];
      final handledFields = <String>{};

      for (final param in clazz.constructorParams) {
        handledFields.add(param.name);
        if (param.isIgnoredForDeserialize(clazz.deserialize)) {
          final dummyVal = param.hasDefault
              ? param.defaultValueCode!
              : _dummyValueFor(param.type);
          if (!param.isNamed) {
            positionalArgs.add(dummyVal);
          } else if (param.isRequired) {
            namedArgs.add('${param.name}: $dummyVal');
          }
          continue;
        }

        if (param.config.isFlattened) {
          final prefix = param.config.flattenPrefix;
          final jsonVar = '${param.name}Json';
          bodyBuffer.writeln(
            "  final $jsonVar = _daxleExtractPrefix(json, '$prefix');",
          );
          final childFn = typeHelper.knownClasses.contains(param.type.baseName)
              ? '${TypeHelper.toCamelCase(param.type.baseName)}FromMap'
              : '${param.type.baseName}.fromMap';
          final expr = param.type.isNullable
              ? '$jsonVar.isEmpty ? null : $childFn($jsonVar)'
              : '$childFn($jsonVar)';
          if (param.isNamed) {
            namedArgs.add('${param.name}: $expr');
          } else {
            positionalArgs.add(expr);
          }
          continue;
        }

        final key = param.resolvedDeserializeKey(caseStyle);
        final hasFallback = param.config.fallbackCode != null;
        final isRequiredInJson =
            !param.type.isNullable &&
            !param.type.isOption &&
            !hasFallback &&
            !param.hasDefault;

        String deserializeExpr;
        if (param.config.aliases.isNotEmpty) {
          final aliasesCode =
              "const [${param.config.aliases.map((a) => "'$a'").join(', ')}]";
          if (isRequiredInJson) {
            bodyBuffer.writeln(
              "  if (!_daxleHasKey(json, '$key', $aliasesCode)) {",
            );
            bodyBuffer.writeln(
              "    throw FormatException(\"Missing required field '$key' for ${clazz.name}\", json);",
            );
            bodyBuffer.writeln('  }');
          }
          final rawVar = '${param.name}Raw';
          bodyBuffer.writeln(
            "  final $rawVar = _daxleResolveKey(json, '$key', $aliasesCode);",
          );
          deserializeExpr = typeHelper.generateDeserialize(
            param.type,
            rawVar,
            config: param.config,
            parameterDefaultCode: param.defaultValueCode,
            explicitFromJson: true,
          );
        } else {
          if (isRequiredInJson) {
            bodyBuffer.writeln("  if (!json.containsKey('$key')) {");
            bodyBuffer.writeln(
              "    throw FormatException(\"Missing required field '$key' for ${clazz.name}\", json);",
            );
            bodyBuffer.writeln('  }');
            final rawVar = '${param.name}Raw';
            bodyBuffer.writeln("  final $rawVar = json['$key'];");
            deserializeExpr = typeHelper.generateDeserialize(
              param.type,
              rawVar,
              config: param.config,
              parameterDefaultCode: param.defaultValueCode,
              explicitFromJson: true,
            );
          } else {
            deserializeExpr = typeHelper.generateDeserialize(
              param.type,
              "json['$key']",
              config: param.config,
              parameterDefaultCode: param.defaultValueCode,
              explicitFromJson: true,
            );
          }
        }

        if (param.isNamed) {
          namedArgs.add('${param.name}: $deserializeExpr');
        } else {
          positionalArgs.add(deserializeExpr);
        }
      }

      final allArgs = [...positionalArgs, ...namedArgs].join(', ');
      final unhandledFields = clazz.fields.where(
        (f) =>
            !handledFields.contains(f.name) &&
            !f.isFinal &&
            !f.isIgnoredForDeserialize(clazz.deserialize),
      );

      if (unhandledFields.isEmpty) {
        bodyBuffer.writeln('  return $constructorName($allArgs);');
      } else {
        bodyBuffer.writeln('  final instance = $constructorName($allArgs);');
        for (final field in unhandledFields) {
          if (field.config.isFlattened) {
            final prefix = field.config.flattenPrefix;
            final jsonVar = '${field.name}Json';
            bodyBuffer.writeln(
              "  final $jsonVar = _daxleExtractPrefix(json, '$prefix');",
            );
            final childFn =
                typeHelper.knownClasses.contains(field.type.baseName)
                ? '${TypeHelper.toCamelCase(field.type.baseName)}FromMap'
                : '${field.type.baseName}.fromMap';
            final expr = field.type.isNullable
                ? '$jsonVar.isEmpty ? null : $childFn($jsonVar)'
                : '$childFn($jsonVar)';
            bodyBuffer.writeln('  instance.${field.name} = $expr;');
            continue;
          }

          final key = field.resolvedDeserializeKey(caseStyle);
          if (field.config.aliases.isNotEmpty) {
            final aliasesCode =
                "const [${field.config.aliases.map((a) => "'$a'").join(', ')}]";
            final rawVar = '${field.name}Raw';
            bodyBuffer.writeln(
              "  if (_daxleHasKey(json, '$key', $aliasesCode)) {",
            );
            bodyBuffer.writeln(
              "    final $rawVar = _daxleResolveKey(json, '$key', $aliasesCode);",
            );
            final deserializeExpr = typeHelper.generateDeserialize(
              field.type,
              rawVar,
              config: field.config,
              parameterDefaultCode: field.defaultValueCode,
              explicitFromJson: true,
            );
            bodyBuffer.writeln(
              '    instance.${field.name} = $deserializeExpr;',
            );
            bodyBuffer.writeln('  }');
          } else {
            bodyBuffer.writeln("  if (json.containsKey('$key')) {");
            final deserializeExpr = typeHelper.generateDeserialize(
              field.type,
              "json['$key']",
              config: field.config,
              parameterDefaultCode: field.defaultValueCode,
              explicitFromJson: true,
            );
            bodyBuffer.writeln(
              '    instance.${field.name} = $deserializeExpr;',
            );
            bodyBuffer.writeln('  }');
          }
        }
        bodyBuffer.writeln('  return instance;');
      }

      return Method(
        (b) => b
          ..name = '${camelName}FromMap'
          ..returns = refer(clazz.name)
          ..requiredParameters.add(
            Parameter(
              (p) => p
                ..name = 'json'
                ..type = refer('Map<String, dynamic>'),
            ),
          )
          ..body = Code(bodyBuffer.toString()),
      );
    }

    final positionalArgs = <String>[];
    final namedArgs = <String>[];
    final handledFields = <String>{};
    final mapPatternEntries = <String>[];
    final requiredChecks = <({String key, String patternType})>[];

    for (final param in clazz.constructorParams) {
      handledFields.add(param.name);
      if (param.isIgnoredForDeserialize(clazz.deserialize)) {
        final dummyVal = param.hasDefault
            ? param.defaultValueCode!
            : _dummyValueFor(param.type);
        if (!param.isNamed) {
          positionalArgs.add(dummyVal);
        } else if (param.isRequired) {
          namedArgs.add('${param.name}: $dummyVal');
        }
        continue;
      }

      final key = param.resolvedDeserializeKey(caseStyle);
      final hasFallback = param.config.fallbackCode != null;
      final isRequiredInJson =
          !param.type.isNullable &&
          !param.type.isOption &&
          !hasFallback &&
          !param.hasDefault;

      final String deserializeExpr;
      if (isRequiredInJson) {
        final varName = '${param.name}Raw';
        final patternType = _patternTypeFor(param.type, param.config);
        mapPatternEntries.add("'$key': final $patternType $varName");
        requiredChecks.add((key: key, patternType: patternType));
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

    if (mapPatternEntries.isEmpty) {
      if (unhandledFields.isEmpty) {
        return Method(
          (b) => b
            ..name = '${camelName}FromMap'
            ..returns = refer(clazz.name)
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'json'
                  ..type = refer('Map<String, dynamic>'),
              ),
            )
            ..lambda = true
            ..body = Code('$constructorName($allArgs)'),
        );
      } else {
        final bodyBuffer = StringBuffer();
        bodyBuffer.writeln('final instance = $constructorName($allArgs);');
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
          bodyBuffer.writeln("if (json.containsKey('$key')) {");
          bodyBuffer.writeln(
            '  instance.${field.name} = $deserializeExpr;',
          );
          bodyBuffer.writeln('}');
        }
        bodyBuffer.writeln('return instance;');

        return Method(
          (b) => b
            ..name = '${camelName}FromMap'
            ..returns = refer(clazz.name)
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'json'
                  ..type = refer('Map<String, dynamic>'),
              ),
            )
            ..body = Code(bodyBuffer.toString()),
        );
      }
    }

    final bodyBuffer = StringBuffer();
    bodyBuffer.writeln('return switch (json) {');
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
        bodyBuffer.writeln(
          '      instance.${field.name} = $deserializeExpr;',
        );
        bodyBuffer.writeln('    }');
      }
      bodyBuffer.writeln('    return instance;');
      bodyBuffer.writeln('  }(),');
    }
    bodyBuffer.writeln('  _ => () {');
    for (final check in requiredChecks) {
      bodyBuffer.writeln("    if (!json.containsKey('${check.key}')) {");
      bodyBuffer.writeln(
        "      throw FormatException(\"Missing required field '${check.key}' for ${clazz.name}\", json);",
      );
      bodyBuffer.writeln('    }');
      if (check.patternType != 'Object') {
        bodyBuffer.writeln(
          "    if (json['${check.key}'] is! ${check.patternType}) {",
        );
        bodyBuffer.writeln(
          "      throw FormatException(\"Invalid type for field '${check.key}' on ${clazz.name}: expected ${check.patternType}, got \${json['${check.key}'].runtimeType}\", json);",
        );
        bodyBuffer.writeln('    }');
      } else {
        bodyBuffer.writeln("    if (json['${check.key}'] == null) {");
        bodyBuffer.writeln(
          "      throw FormatException(\"Invalid type for field '${check.key}' on ${clazz.name}: expected non-null value, got Null\", json);",
        );
        bodyBuffer.writeln('    }');
      }
    }
    final expectedKeys = requiredChecks.map((c) => c.key).join(', ');
    bodyBuffer.writeln(
      "    throw FormatException('Invalid JSON shape for ${clazz.name}: missing or invalid required keys (expected: $expectedKeys)', json);",
    );
    bodyBuffer.writeln('  }(),');
    bodyBuffer.write('};');

    return Method(
      (b) => b
        ..name = '${camelName}FromMap'
        ..returns = refer(clazz.name)
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'json'
              ..type = refer('Map<String, dynamic>'),
          ),
        )
        ..body = Code(bodyBuffer.toString()),
    );
  }

  /// Builds the `toMap` [Method] specification.
  Method buildToMap(ParsedClass clazz) {
    final camelName = TypeHelper.toCamelCase(clazz.name);
    final caseStyle = clazz.serialize?.caseStyle;

    final buffer = StringBuffer();
    buffer.writeln('<String, dynamic>{');

    for (final field in clazz.fields) {
      if (field.isIgnoredForSerialize(clazz.serialize)) continue;

      final fieldExpr = 'instance.${field.name}';

      if (field.config.isFlattened) {
        final childToMapCall =
            typeHelper.knownClasses.contains(field.type.baseName)
            ? '${TypeHelper.toCamelCase(field.type.baseName)}ToMap($fieldExpr${field.type.isNullable ? '!' : ''}, excludeNull: excludeNull)'
            : '$fieldExpr${field.type.isNullable ? '!' : ''}.toMap(excludeNull: excludeNull)';

        if (field.type.isNullable) {
          buffer.writeln('  if ($fieldExpr != null)');
        }
        buffer.writeln('    for (final entry in $childToMapCall.entries)');
        if (field.config.flattenPrefix.isNotEmpty) {
          buffer.writeln(
            "      '${field.config.flattenPrefix}\${entry.key}': entry.value,",
          );
        } else {
          buffer.writeln('      entry.key: entry.value,');
        }
        continue;
      }

      final key = field.resolvedSerializeKey(caseStyle);
      final hasSerializeFallback = field.config.fallbackCode != null;

      if (field.type.isNullable &&
          !field.type.isOption &&
          !hasSerializeFallback) {
        final serializeNonNullExpr = typeHelper.generateSerializeNonNull(
          field.type,
          fieldExpr,
          config: field.config,
          explicitToJson: true,
        );
        buffer.writeln(
          "  if (!excludeNull || $fieldExpr != null) '$key': $fieldExpr == null ? null : $serializeNonNullExpr,",
        );
      } else if (field.type.isOption) {
        final innerType =
            field.type.singleTypeArgument ??
            const ParsedType(
              rawType: 'Object',
              baseName: 'Object',
              isNullable: false,
            );
        final innerSerialize = typeHelper.generateSerialize(
          innerType,
          'value',
          explicitToJson: true,
        );
        buffer.writeln(
          "  if (!excludeNull || $fieldExpr.isSome) '$key': switch ($fieldExpr) { Some(:final value) => $innerSerialize, None() => null },",
        );
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

    return Method(
      (b) => b
        ..name = '${camelName}ToMap'
        ..returns = refer('Map<String, dynamic>')
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'instance'
              ..type = refer(clazz.name),
          ),
        )
        ..optionalParameters.add(
          Parameter(
            (p) => p
              ..name = 'excludeNull'
              ..type = refer('bool')
              ..named = true
              ..defaultTo = const Code('false'),
          ),
        )
        ..lambda = true
        ..body = Code(buffer.toString()),
    );
  }

  /// Generates the `fromMap` function as code string.
  String generateFromMap(ParsedClass clazz) {
    return buildFromMap(clazz).accept(_emitter).toString();
  }

  /// Generates the `toMap` function as code string.
  String generateToMap(ParsedClass clazz) {
    return buildToMap(clazz).accept(_emitter).toString();
  }
}
