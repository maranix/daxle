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

    final fieldStrings = activeFields
        .map((f) => '${f.name}: \${self.${f.name}}')
        .join(', ');
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
