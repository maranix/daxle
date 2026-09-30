import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';
import 'type_helper.dart';

/// Generates model delta diffing (`.diff()`) functions and methods.
class DiffGenerator {
  final TypeHelper typeHelper;
  final DartEmitter _emitter;

  DiffGenerator(this.typeHelper)
      : _emitter = DartEmitter(useNullSafetySyntax: true);

  /// Builds the `${camelName}Diff` top-level [Method] specification.
  Method buildDiff(ParsedClass clazz) {
    final camelName = TypeHelper.toCamelCase(clazz.name);
    final caseStyle = clazz.serialize?.caseStyle;

    final buffer = StringBuffer();
    buffer.writeln(
      'if (identical(current, other)) return const <String, dynamic>{};',
    );
    buffer.writeln('final delta = <String, dynamic>{};');

    for (final field in clazz.fields) {
      if (field.isIgnoredForSerialize(clazz.serialize)) continue;

      final key = field.resolvedSerializeKey(caseStyle);
      final currentExpr = 'current.${field.name}';
      final otherExpr = 'other.${field.name}';

      if (field.config.isFlattened) {
        final childCamel = TypeHelper.toCamelCase(field.type.baseName);
        final prefix = field.config.flattenPrefix;
        if (field.type.isNullable) {
          buffer.writeln('if ($currentExpr == null && $otherExpr != null) {');
          buffer.writeln('  final added = ${childCamel}ToMap($otherExpr!);');
          buffer.writeln('  for (final entry in added.entries) {');
          buffer.writeln("    delta['$prefix\${entry.key}'] = entry.value;");
          buffer.writeln('  }');
          buffer.writeln(
            '} else if ($currentExpr != null && $otherExpr == null) {',
          );
          buffer.writeln(
            '  final removed = ${childCamel}ToMap($currentExpr!);',
          );
          buffer.writeln('  for (final entry in removed.entries) {');
          buffer.writeln("    delta['$prefix\${entry.key}'] = null;");
          buffer.writeln('  }');
          buffer.writeln(
            '} else if ($currentExpr != null && $otherExpr != null) {',
          );
          buffer.writeln(
            '  final childDiff = ${childCamel}Diff($currentExpr!, $otherExpr!, deep: deep);',
          );
          buffer.writeln('  for (final entry in childDiff.entries) {');
          buffer.writeln("    delta['$prefix\${entry.key}'] = entry.value;");
          buffer.writeln('  }');
          buffer.writeln('}');
        } else {
          buffer.writeln(
            'final childDiff = ${childCamel}Diff($currentExpr, $otherExpr, deep: deep);',
          );
          buffer.writeln('for (final entry in childDiff.entries) {');
          buffer.writeln("  delta['$prefix\${entry.key}'] = entry.value;");
          buffer.writeln('}');
        }
        continue;
      }

      if (typeHelper.knownClasses.contains(field.type.baseName)) {
        final childCamel = TypeHelper.toCamelCase(field.type.baseName);
        final childSerializeExpr = typeHelper.generateSerialize(
          field.type,
          otherExpr,
          config: field.config,
          explicitToJson: true,
        );

        if (field.type.isNullable) {
          buffer.writeln('if ($currentExpr == null && $otherExpr != null) {');
          buffer.writeln("  delta['$key'] = $childSerializeExpr;");
          buffer.writeln(
            '} else if ($currentExpr != null && $otherExpr == null) {',
          );
          buffer.writeln("  delta['$key'] = null;");
          buffer.writeln(
            '} else if ($currentExpr != null && $otherExpr != null) {',
          );
          buffer.writeln('  if (deep) {');
          buffer.writeln(
            '    final childDiff = ${childCamel}Diff($currentExpr!, $otherExpr!, deep: true);',
          );
          buffer.writeln('    if (childDiff.isNotEmpty) {');
          buffer.writeln("      delta['$key'] = childDiff;");
          buffer.writeln('    }');
          buffer.writeln('  } else {');
          buffer.writeln(
            '    final childDiff = ${childCamel}Diff($currentExpr!, $otherExpr!, deep: false);',
          );
          buffer.writeln('    if (childDiff.isNotEmpty) {');
          buffer.writeln("      delta['$key'] = $childSerializeExpr;");
          buffer.writeln('    }');
          buffer.writeln('  }');
          buffer.writeln('}');
        } else {
          buffer.writeln('if (deep) {');
          buffer.writeln(
            '  final childDiff = ${childCamel}Diff($currentExpr, $otherExpr, deep: true);',
          );
          buffer.writeln('  if (childDiff.isNotEmpty) {');
          buffer.writeln("    delta['$key'] = childDiff;");
          buffer.writeln('  }');
          buffer.writeln('} else {');
          buffer.writeln(
            '  final childDiff = ${childCamel}Diff($currentExpr, $otherExpr, deep: false);',
          );
          buffer.writeln('  if (childDiff.isNotEmpty) {');
          buffer.writeln("    delta['$key'] = $childSerializeExpr;");
          buffer.writeln('  }');
          buffer.writeln('}');
        }
        continue;
      }

      final serializeExpr = typeHelper.generateSerialize(
        field.type,
        otherExpr,
        config: field.config,
        explicitToJson: true,
      );

      if (field.type.isList) {
        buffer.writeln('if (!\$listEquals($currentExpr, $otherExpr)) {');
        buffer.writeln("  delta['$key'] = $serializeExpr;");
        buffer.writeln('}');
      } else if (field.type.isSet) {
        buffer.writeln('if (!\$setEquals($currentExpr, $otherExpr)) {');
        buffer.writeln("  delta['$key'] = $serializeExpr;");
        buffer.writeln('}');
      } else if (field.type.isMap) {
        buffer.writeln('if (!\$mapEquals($currentExpr, $otherExpr)) {');
        buffer.writeln("  delta['$key'] = $serializeExpr;");
        buffer.writeln('}');
      } else if (field.type.isQueryMap) {
        final curAccess = field.type.isNullable
            ? '$currentExpr?.map'
            : '$currentExpr.map';
        final othAccess = field.type.isNullable
            ? '$otherExpr?.map'
            : '$otherExpr.map';
        buffer.writeln('if (!\$mapEquals($curAccess, $othAccess)) {');
        buffer.writeln("  delta['$key'] = $serializeExpr;");
        buffer.writeln('}');
      } else {
        buffer.writeln('if ($currentExpr != $otherExpr) {');
        buffer.writeln("  delta['$key'] = $serializeExpr;");
        buffer.writeln('}');
      }
    }

    buffer.writeln('return delta;');

    return Method(
      (b) => b
        ..name = '${camelName}Diff'
        ..returns = refer('Map<String, dynamic>')
        ..requiredParameters.addAll([
          Parameter(
            (p) => p
              ..name = 'current'
              ..type = refer(clazz.name),
          ),
          Parameter(
            (p) => p
              ..name = 'other'
              ..type = refer(clazz.name),
          ),
        ])
        ..optionalParameters.add(
          Parameter(
            (p) => p
              ..name = 'deep'
              ..type = refer('bool')
              ..named = true
              ..defaultTo = const Code('true'),
          ),
        )
        ..body = Code(buffer.toString()),
    );
  }

  /// Generates the `${camelName}Diff` function as code string.
  String generateDiff(ParsedClass clazz) {
    return buildDiff(clazz).accept(_emitter).toString();
  }
}
