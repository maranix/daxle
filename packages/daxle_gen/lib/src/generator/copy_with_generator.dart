import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';

/// Generates `copyWith` and `copyWithNull` extensions for classes.
class CopyWithGenerator {
  const CopyWithGenerator();

  /// Builds both the proxy class and the extension for [clazz].
  List<Spec> build(ParsedClass clazz, Set<String> knownCopyWithClasses) {
    return [
      buildProxyClass(clazz, knownCopyWithClasses),
      buildExtension(clazz),
    ];
  }

  /// Builds the generic `$ClassNameCopyWithProxy<$Res>` class.
  Class buildProxyClass(ParsedClass clazz, Set<String> knownCopyWithClasses) {
    final methods = <Method>[
      buildCallMethod(clazz),
      ...buildNestedGetters(clazz, knownCopyWithClasses),
    ];

    return Class(
      (b) => b
        ..name = '\$${clazz.name}CopyWithProxy'
        ..types.add(TypeReference((b) => b..symbol = '\$Res'))
        ..constructors.add(
          Constructor(
            (b) => b
              // Note: leave name null for an unnamed constructor
              ..requiredParameters.addAll([
                Parameter(
                  (b) => b
                    ..name = '_value'
                    ..toThis = true,
                ),
                Parameter(
                  (b) => b
                    ..name = '_then'
                    ..toThis = true,
                ),
              ]),
          ),
        )
        ..fields.addAll([
          Field(
            (b) => b
              ..name = '_value'
              ..type = refer(clazz.name)
              ..modifier = FieldModifier.final$,
          ),
          Field(
            (b) => b
              ..name = '_then'
              ..type = refer('\$Res Function(${clazz.name})')
              ..modifier = FieldModifier.final$,
          ),
        ])
        ..methods.addAll(methods),
    );
  }

  /// Builds the `call({ ... })` method on the proxy.
  Method buildCallMethod(ParsedClass clazz) {
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
      bodyCode = 'return _then(_value);';
    } else {
      final identityChecks = copyParams
          .map(
            (p) =>
                '(${p.name} == null || identical(${p.name}, _value.${p.name}))',
          )
          .join(' &&\n        ');

      final constructorArgs = clazz.constructorParams
          .map((p) {
            final isCopyable = copyParams.any((cp) => cp.name == p.name);
            final expr = isCopyable
                ? '${p.name} ?? _value.${p.name}'
                : '_value.${p.name}';
            return p.isNamed ? '${p.name}: $expr' : expr;
          })
          .join(',\n      ');

      bodyCode =
          'if ($identityChecks) {\n'
          '      return _then(_value);\n'
          '    }\n\n'
          '    return _then(\n'
          '      $constructorInvocation(\n'
          '        $constructorArgs,\n'
          '      ),\n'
          '    );';
    }

    return Method(
      (m) => m
        ..name = 'call'
        ..returns = refer(r'$Res')
        ..optionalParameters.addAll(parameters)
        ..body = Code(bodyCode),
    );
  }

  /// Builds nested getters for fields whose types are also copyable classes.
  List<Method> buildNestedGetters(
    ParsedClass clazz,
    Set<String> knownCopyWithClasses,
  ) {
    final getters = <Method>[];

    for (final field in clazz.fields) {
      if (field.isIgnoredForCopyWith(clazz.copyWith)) continue;

      final baseType = field.type.baseName;
      if (!knownCopyWithClasses.contains(baseType)) continue;

      if (field.type.isNullable) {
        getters.add(
          Method(
            (m) => m
              ..name = field.name
              ..type = MethodType.getter
              ..returns = refer(
                '\$$baseType'
                'CopyWithProxy<\$Res>?',
              )
              ..body = Code(
                'if (_value.${field.name} == null) return null;\n'
                'return \$$baseType'
                'CopyWithProxy(_value.${field.name}!, (val) => call(${field.name}: val));',
              ),
          ),
        );
      } else {
        getters.add(
          Method(
            (m) => m
              ..name = field.name
              ..type = MethodType.getter
              ..returns = refer(
                '\$$baseType'
                'CopyWithProxy<\$Res>',
              )
              ..lambda = true
              ..body = Code(
                '\$$baseType'
                'CopyWithProxy(_value.${field.name}, (val) => call(${field.name}: val))',
              ),
          ),
        );
      }
    }

    return getters;
  }

  /// Builds the `copyWithNull` method for nullable fields.
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

  /// Builds the extension providing the `copyWith` getter and `copyWithNull`.
  Extension buildExtension(ParsedClass clazz) {
    final methods = <Method>[
      Method(
        (m) => m
          ..name = 'copyWith'
          ..type = MethodType.getter
          ..returns = refer('\$${clazz.name}CopyWithProxy<${clazz.name}>')
          ..lambda = true
          ..body = Code('\$${clazz.name}CopyWithProxy(this, (v) => v)'),
      ),
    ];

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
