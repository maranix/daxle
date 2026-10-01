import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';

/// Generates [toString] mixins for classes and enums.
class StringifyGenerator {
  const StringifyGenerator();

  Method buildToString(ParsedClass clazz) {
    final activeFields = clazz.fields
        .where((f) => !f.isIgnoredForStringify(clazz.stringify))
        .toList();

    if (activeFields.isEmpty) {
      return Method(
        (m) => m
          ..annotations.add(refer('override'))
          ..name = 'toString'
          ..returns = refer('String')
          ..lambda = true
          ..body = Code("'${clazz.name}()'"),
      );
    }

    final fieldStrings = activeFields.map((f) {
      if (f.isRedacted) {
        final cfg = f.redactConfig!;
        final maskEscaped = cfg.mask
            .replaceAll(r'\', r'\\')
            .replaceAll(r'$', r'\$')
            .replaceAll(r"'", r"\'");
        if (cfg.preserveLength && f.type.isString) {
          if (f.type.isNullable) {
            return "${f.name}: \${self.${f.name} == null ? 'null' : ('$maskEscaped'.isNotEmpty ? '$maskEscaped'[0] * self.${f.name}!.length : '')}";
          } else {
            return "${f.name}: \${'$maskEscaped'.isNotEmpty ? '$maskEscaped'[0] * self.${f.name}.length : ''}";
          }
        } else {
          if (f.type.isNullable) {
            return "${f.name}: \${self.${f.name} == null ? 'null' : '$maskEscaped'}";
          } else {
            return "${f.name}: $maskEscaped";
          }
        }
      }
      return '${f.name}: \${self.${f.name}}';
    }).join(', ');
    final body =
        'final self = this as ${clazz.name};\n'
        "return '${clazz.name}($fieldStrings)';";

    return Method(
      (m) => m
        ..annotations.add(refer('override'))
        ..name = 'toString'
        ..returns = refer('String')
        ..body = Code(body),
    );
  }

  Mixin buildClassMixin(ParsedClass clazz) {
    return Mixin(
      (b) => b
        ..name = '_\$${clazz.name}Stringify'
        ..methods.add(buildToString(clazz)),
    );
  }

  Mixin buildEnumMixin(ParsedEnum parsedEnum) {
    final cases = parsedEnum.constants
        .map(
          (c) =>
              '  ${parsedEnum.name}.${c.name} => \'${parsedEnum.name}.${c.name}\',',
        )
        .join('\n');
    final body = 'switch (this as ${parsedEnum.name}) {\n$cases\n}';

    return Mixin(
      (b) => b
        ..name = '_\$${parsedEnum.name}Stringify'
        ..on = refer('Enum')
        ..methods.add(
          Method(
            (m) => m
              ..annotations.add(refer('override'))
              ..name = 'toString'
              ..returns = refer('String')
              ..lambda = true
              ..body = Code(body),
          ),
        ),
    );
  }
}
