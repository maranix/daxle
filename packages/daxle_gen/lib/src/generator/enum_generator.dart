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
    final serializeCaseStyle =
        parsedEnum.serialize?.caseStyle ?? parsedEnum.deserialize?.caseStyle;
    final deserializeCaseStyle =
        parsedEnum.deserialize?.caseStyle ?? parsedEnum.serialize?.caseStyle;
    final specs = <Spec>[];

    // 1. Enum map constant field
    final mapEntries = StringBuffer();
    mapEntries.writeln('{');
    for (final constant in parsedEnum.constants) {
      if (constant.isIgnored) continue;
      final valueCode = constant.resolvedSerializeValue(serializeCaseStyle);
      mapEntries.writeln('  $enumName.${constant.name}: $valueCode,');
    }
    mapEntries.write('}');

    specs.add(
      Field(
        (b) => b
          ..name = '_${camelName}EnumMap'
          ..modifier = FieldModifier.constant
          ..assignment = Code(mapEntries.toString()),
      ),
    );

    // 2. toValue function
    specs.add(
      Method(
        (b) => b
          ..name = '${camelName}ToValue'
          ..returns = refer('dynamic')
          ..requiredParameters.add(
            Parameter(
              (p) => p
                ..name = 'instance'
                ..type = refer(enumName),
            ),
          )
          ..lambda = true
          ..body = Code('_${camelName}EnumMap[instance]!'),
      ),
    );

    // 3. fromValue function (switch pattern matching)
    final fromValueBody = StringBuffer();
    fromValueBody.writeln('switch (value) {');
    for (final constant in parsedEnum.constants) {
      if (constant.isIgnored) continue;
      final matchValue = constant.resolvedDeserializeValue(
        deserializeCaseStyle,
      );
      final patterns = [
        matchValue,
        ...constant.aliases.map((a) => "'$a'"),
      ];
      fromValueBody.writeln(
        '  ${patterns.join(' || ')} => $enumName.${constant.name},',
      );
    }

    if (parsedEnum.fallbackCaseCode != null) {
      fromValueBody.writeln('  _ => ${parsedEnum.fallbackCaseCode},');
    } else {
      fromValueBody.writeln(
        "  _ => throw ArgumentError('Unknown $enumName value: \$value'),",
      );
    }
    fromValueBody.write('}');

    specs.add(
      Method(
        (b) => b
          ..name = '${camelName}FromValue'
          ..returns = refer(enumName)
          ..requiredParameters.add(
            Parameter(
              (p) => p
                ..name = 'value'
                ..type = refer('Object?'),
            ),
          )
          ..lambda = true
          ..body = Code(fromValueBody.toString()),
      ),
    );

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
