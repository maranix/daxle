import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';
import 'type_helper.dart';

/// Generates polymorphic switch serialization and deserialization for sealed class hierarchies using [code_builder].
class SealedGenerator {
  final DartEmitter _emitter;

  SealedGenerator() : _emitter = DartEmitter(useNullSafetySyntax: true);

  /// Builds the polymorphic `fromMap` [Method] specification.
  Method buildFromMap(
    ParsedClass sealedClass,
    List<ParsedClass> subclasses,
  ) {
    final camelName = TypeHelper.toCamelCase(sealedClass.name);
    final discriminator =
        sealedClass.deserialize?.discriminator ??
        sealedClass.serialize?.discriminator ??
        'type';
    final caseStyle =
        sealedClass.deserialize?.caseStyle ?? sealedClass.serialize?.caseStyle;

    final buffer = StringBuffer();
    buffer.writeln('return switch (json) {');

    for (final sub in subclasses) {
      final subCamel = TypeHelper.toCamelCase(sub.name);
      final defaultTag = caseStyle != null
          ? caseStyle.transform(sub.name)
          : sub.name;
      final tag = sub.customDiscriminatorName ?? defaultTag;
      buffer.writeln(
        "  {'$discriminator': '$tag'} => ${subCamel}FromMap(json),",
      );
    }

    buffer.writeln('  _ => () {');
    buffer.writeln("    if (!json.containsKey('$discriminator')) {");
    buffer.writeln(
      "      throw FormatException(\"Missing required discriminator '$discriminator' for ${sealedClass.name}\", json);",
    );
    buffer.writeln('    }');
    buffer.writeln(
      "    throw FormatException(\"Unknown ${sealedClass.name} discriminator: '\${json['$discriminator']}'\", json);",
    );
    buffer.writeln('  }(),');
    buffer.write('};');

    return Method(
      (b) => b
        ..name = '${camelName}FromMap'
        ..returns = refer(sealedClass.name)
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'json'
              ..type = refer('Map<String, dynamic>'),
          ),
        )
        ..body = Code(buffer.toString()),
    );
  }

  /// Builds the polymorphic `toMap` [Method] specification.
  Method buildToMap(
    ParsedClass sealedClass,
    List<ParsedClass> subclasses,
  ) {
    final camelName = TypeHelper.toCamelCase(sealedClass.name);
    final discriminator =
        sealedClass.serialize?.discriminator ??
        sealedClass.deserialize?.discriminator ??
        'type';
    final caseStyle =
        sealedClass.serialize?.caseStyle ?? sealedClass.deserialize?.caseStyle;

    final buffer = StringBuffer();
    buffer.writeln('return switch (instance) {');

    for (final sub in subclasses) {
      final subVar = TypeHelper.toCamelCase(sub.name);
      final defaultTag = caseStyle != null
          ? caseStyle.transform(sub.name)
          : sub.name;
      final tag = sub.customDiscriminatorName ?? defaultTag;
      buffer.writeln(
        "  final ${sub.name} $subVar => ${subVar}ToMap($subVar, excludeNull: excludeNull)..['$discriminator'] = '$tag',",
      );
    }

    buffer.write('};');

    return Method(
      (b) => b
        ..name = '${camelName}ToMap'
        ..returns = refer('Map<String, dynamic>')
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'instance'
              ..type = refer(sealedClass.name),
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
        ..body = Code(buffer.toString()),
    );
  }

  /// Generates the `fromMap` function as code string.
  String generateFromMap(
    ParsedClass sealedClass,
    List<ParsedClass> subclasses,
  ) {
    return buildFromMap(sealedClass, subclasses).accept(_emitter).toString();
  }

  /// Generates the `toMap` function as code string.
  String generateToMap(
    ParsedClass sealedClass,
    List<ParsedClass> subclasses,
  ) {
    return buildToMap(sealedClass, subclasses).accept(_emitter).toString();
  }
}
