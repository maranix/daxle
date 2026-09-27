import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';
import 'type_helper.dart';

/// Generates top-level functional serialization and deserialization for enums using [code_builder].
class EnumGenerator {
  final DartEmitter _emitter;

  EnumGenerator() : _emitter = DartEmitter(useNullSafetySyntax: true);

  /// Builds the [Spec] list (Field and Methods) for an enum.
  List<Spec> build(ParsedEnum parsedEnum) {
    final enumName = parsedEnum.name;
    final camelName = TypeHelper.toCamelCase(enumName);
    final specs = <Spec>[];

    // 1. Enum map constant field
    final mapEntries = StringBuffer();
    mapEntries.writeln('{');
    for (final constant in parsedEnum.constants) {
      final valueCode = constant.explicitValueCode ?? "'${constant.name}'";
      mapEntries.writeln('  $enumName.${constant.name}: $valueCode,');
    }
    mapEntries.write('}');

    specs.add(Field((b) => b
      ..name = '${camelName}EnumMap'
      ..modifier = FieldModifier.constant
      ..assignment = Code(mapEntries.toString())));

    // 2. toValue function
    specs.add(Method((b) => b
      ..name = '${camelName}ToValue'
      ..returns = refer('dynamic')
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'instance'
        ..type = refer(enumName)))
      ..lambda = true
      ..body = Code('${camelName}EnumMap[instance]!')));

    // 3. fromValue function
    final fromValueBody = StringBuffer()
      ..writeln('for (final entry in ${camelName}EnumMap.entries) {')
      ..writeln('  if (entry.value == value) return entry.key;')
      ..writeln('}')
      ..writeln("throw ArgumentError('Unknown $enumName value: \$value');");

    specs.add(Method((b) => b
      ..name = '${camelName}FromValue'
      ..returns = refer(enumName)
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'value'
        ..type = refer('Object?')))
      ..body = Code(fromValueBody.toString())));

    // 4. fromJson alias
    specs.add(Method((b) => b
      ..name = '${camelName}FromJson'
      ..returns = refer(enumName)
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'value'
        ..type = refer('Object?')))
      ..lambda = true
      ..body = Code('${camelName}FromValue(value)')));

    // 5. toJson alias
    specs.add(Method((b) => b
      ..name = '${camelName}ToJson'
      ..returns = refer('dynamic')
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'instance'
        ..type = refer(enumName)))
      ..lambda = true
      ..body = Code('${camelName}ToValue(instance)')));

    return specs;
  }

  /// Generates the enum serialization code as a formatted string.
  String generate(ParsedEnum parsedEnum) {
    final specs = build(parsedEnum);
    final buffer = StringBuffer();
    for (final spec in specs) {
      buffer.writeln(spec.accept(_emitter));
      buffer.writeln();
    }
    return buffer.toString();
  }
}
