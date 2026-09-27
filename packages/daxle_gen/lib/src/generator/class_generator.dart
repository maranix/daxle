import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';
import 'type_helper.dart';

/// Generates top-level functional serialization and deserialization for classes using [code_builder].
class ClassGenerator {
  final TypeHelper typeHelper;
  final DartEmitter _emitter;

  ClassGenerator(this.typeHelper)
      : _emitter = DartEmitter(useNullSafetySyntax: true);

  /// Builds the `fromJson` [Method] specification.
  Method buildFromJson(ParsedClass clazz) {
    final camelName = TypeHelper.toCamelCase(clazz.name);
    final explicitFromJson = clazz.deserialize?.explicitFromJson ?? true;

    final constructorName = clazz.constructorName.isEmpty
        ? clazz.name
        : '${clazz.name}.${clazz.constructorName}';

    final positionalArgs = <String>[];
    final namedArgs = <String>[];
    final handledFields = <String>{};

    for (final param in clazz.constructorParams) {
      handledFields.add(param.name);
      if (param.config.ignoreDeserialize) {
        if (!param.isNamed && param.hasDefault) {
          positionalArgs.add(param.defaultValueCode!);
        } else if (!param.isNamed) {
          positionalArgs.add('null as dynamic');
        }
        continue;
      }

      final jsonExpr = "json['${param.deserializeKey}']";
      final deserializeExpr = typeHelper.generateDeserialize(
        param.type,
        jsonExpr,
        config: param.config,
        parameterDefaultCode: param.defaultValueCode,
        explicitFromJson: explicitFromJson,
      );

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
          !f.config.ignoreDeserialize,
    );

    final bodyBuffer = StringBuffer();
    if (unhandledFields.isEmpty) {
      bodyBuffer.writeln('return $constructorName($allArgs);');
    } else {
      bodyBuffer.writeln('final instance = $constructorName($allArgs);');
      for (final field in unhandledFields) {
        final jsonExpr = "json['${field.deserializeKey}']";
        final deserializeExpr = typeHelper.generateDeserialize(
          field.type,
          jsonExpr,
          config: field.config,
          parameterDefaultCode: field.defaultValueCode,
          explicitFromJson: explicitFromJson,
        );
        bodyBuffer.writeln("if (json.containsKey('${field.deserializeKey}')) {");
        bodyBuffer.writeln('  instance.${field.name} = $deserializeExpr;');
        bodyBuffer.writeln('}');
      }
      bodyBuffer.writeln('return instance;');
    }

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
    final explicitToJson = clazz.serialize?.explicitToJson ?? true;

    final buffer = StringBuffer();
    buffer.writeln('<String, dynamic>{');

    for (final field in clazz.fields) {
      if (field.config.ignoreSerialize) continue;

      final fieldExpr = 'instance.${field.name}';
      final hasSerializeDefault = field.config.serializeDefaultValueCode != null;

      if (field.type.isNullable &&
          !field.type.isOption &&
          !hasSerializeDefault) {
        final serializeNonNullExpr = typeHelper.generateSerializeNonNull(
          field.type,
          fieldExpr,
          config: field.config,
          explicitToJson: explicitToJson,
        );
        buffer.writeln(
            "  if ($fieldExpr != null) '${field.serializeKey}': $serializeNonNullExpr,");
      } else {
        final serializeExpr = typeHelper.generateSerialize(
          field.type,
          fieldExpr,
          config: field.config,
          explicitToJson: explicitToJson,
        );
        buffer.writeln("  '${field.serializeKey}': $serializeExpr,");
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
