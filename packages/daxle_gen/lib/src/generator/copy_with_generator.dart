import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';

/// Generates `copyWith` and `copyWithNull` extensions for classes.
class CopyWithGenerator {
  const CopyWithGenerator();

  Method buildCopyWith(ParsedClass clazz) {
    final copyParams = clazz.constructorParams
        .where((p) => !p.isIgnoredForCopyWith(clazz.copyWith))
        .toList();

    final constructorInvocation = clazz.constructorName.isEmpty
        ? clazz.name
        : '${clazz.name}.${clazz.constructorName}';

    final parameters = copyParams.map((p) {
      final typeStr = p.type.rawType.endsWith('?')
          ? p.type.rawType
          : '${p.type.rawType}?';
      return Parameter(
        (pb) => pb
          ..name = p.name
          ..type = refer(typeStr)
          ..named = true,
      );
    }).toList();

    final String bodyCode;
    if (copyParams.isEmpty) {
      bodyCode = 'return this;';
    } else {
      final identityChecks = copyParams
          .map(
            (p) =>
                '(${p.name} == null || identical(${p.name}, this.${p.name}))',
          )
          .join(' &&\n        ');

      final constructorArgs = clazz.constructorParams
          .map((p) {
            final isCopyable = copyParams.any((cp) => cp.name == p.name);
            final expr = isCopyable
                ? '${p.name} ?? this.${p.name}'
                : 'this.${p.name}';
            return p.isNamed ? '${p.name}: $expr' : expr;
          })
          .join(',\n      ');

      bodyCode =
          'if ($identityChecks) {\n'
          '      return this;\n'
          '    }\n\n'
          '    return $constructorInvocation(\n'
          '      $constructorArgs,\n'
          '    );';
    }

    return Method(
      (m) => m
        ..name = 'copyWith'
        ..returns = refer(clazz.name)
        ..optionalParameters.addAll(parameters)
        ..body = Code(bodyCode),
    );
  }

  Method? buildCopyWithNull(ParsedClass clazz) {
    final nullableParams = clazz.constructorParams
        .where(
          (p) => p.type.isNullable && !p.isIgnoredForCopyWith(clazz.copyWith),
        )
        .toList();

    if (nullableParams.isEmpty) {
      return null;
    }

    final constructorInvocation = clazz.constructorName.isEmpty
        ? clazz.name
        : '${clazz.name}.${clazz.constructorName}';

    final parameters = nullableParams.map((p) {
      return Parameter(
        (pb) => pb
          ..name = p.name
          ..type = refer('bool')
          ..named = true
          ..defaultTo = const Code('false'),
      );
    }).toList();

    final falseChecks = nullableParams.map((p) => '!${p.name}').join(' && ');

    final constructorArgs = clazz.constructorParams
        .map((p) {
          final isNullableParam = nullableParams.any((np) => np.name == p.name);
          final expr = isNullableParam
              ? '${p.name} ? null : this.${p.name}'
              : 'this.${p.name}';
          return p.isNamed ? '${p.name}: $expr' : expr;
        })
        .join(',\n      ');

    final bodyCode =
        'if ($falseChecks) {\n'
        '      return this;\n'
        '    }\n\n'
        '    return $constructorInvocation(\n'
        '      $constructorArgs,\n'
        '    );';

    return Method(
      (m) => m
        ..name = 'copyWithNull'
        ..returns = refer(clazz.name)
        ..optionalParameters.addAll(parameters)
        ..body = Code(bodyCode),
    );
  }

  Extension buildExtension(ParsedClass clazz) {
    final methods = <Method>[];
    methods.add(buildCopyWith(clazz));
    final copyWithNull = buildCopyWithNull(clazz);
    if (copyWithNull != null) {
      methods.add(copyWithNull);
    }

    return Extension(
      (b) => b
        ..name = '${clazz.name}CopyWithExtension'
        ..on = refer(clazz.name)
        ..methods.addAll(methods),
    );
  }
}
