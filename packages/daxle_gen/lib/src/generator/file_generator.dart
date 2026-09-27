import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import '../models/parsed_element.dart';
import 'class_generator.dart';
import 'copy_with_generator.dart';
import 'enum_generator.dart';
import 'equality_generator.dart';
import 'sealed_generator.dart';
import 'stringify_generator.dart';
import 'type_helper.dart';

/// Coordinates generation for an entire file using [code_builder] and [dart_style].
class FileGenerator {
  final DartFormatter _formatter;
  final DartEmitter _emitter;

  FileGenerator({DartFormatter? formatter, DartEmitter? emitter})
    : _formatter =
          formatter ??
          DartFormatter(languageVersion: DartFormatter.latestLanguageVersion),
      _emitter = emitter ?? DartEmitter(useNullSafetySyntax: true);

  /// Generates the code string for the `.daxle.dart` part file.
  /// Returns `null` if the file has no annotated classes or enums.
  String? generate(ParsedFile parsedFile) {
    if (!parsedFile.hasDaxleAnnotations) {
      return null;
    }

    final knownEnums = parsedFile.enums.map((e) => e.name).toSet();
    final knownClasses = parsedFile.classes.map((c) => c.name).toSet();
    final typeHelper = TypeHelper(
      knownEnums: knownEnums,
      knownClasses: knownClasses,
    );

    final classGen = ClassGenerator(typeHelper);
    final enumGen = EnumGenerator();
    final sealedGen = SealedGenerator();
    final equalityGen = EqualityGenerator(typeHelper);
    final stringifyGen = const StringifyGenerator();
    final copyWithGen = const CopyWithGenerator();

    final specs = <Spec>[];

    // 1. Enums
    for (final parsedEnum in parsedFile.enums) {
      if (parsedEnum.shouldSerialize || parsedEnum.shouldDeserialize) {
        specs.addAll(enumGen.build(parsedEnum));
      }
      if (parsedEnum.shouldStringify) {
        specs.add(stringifyGen.buildEnumMixin(parsedEnum));
      }
    }

    // 2. Identify sealed classes and their subclasses (both extends and implements)
    final sealedClasses = parsedFile.classes.where((c) => c.isSealed).toList();
    final sealedSubclasses = <String, List<ParsedClass>>{};

    for (final sc in sealedClasses) {
      sealedSubclasses[sc.name] = parsedFile.classes
          .where((c) => c.isSubclassOf(sc.name) && !c.isSealed)
          .toList();
    }

    // 3. Normal Classes & Subclasses
    for (final clazz in parsedFile.classes) {
      if (clazz.isSealed) continue;

      var shouldSer = clazz.shouldSerialize;
      var shouldDeser = clazz.shouldDeserialize;

      for (final sc in sealedClasses) {
        if (clazz.isSubclassOf(sc.name)) {
          shouldSer = shouldSer || sc.shouldSerialize;
          shouldDeser = shouldDeser || sc.shouldDeserialize;
        }
      }

      if (shouldDeser) {
        specs.add(classGen.buildFromJson(clazz));
      }
      if (shouldSer) {
        specs.add(classGen.buildToMap(clazz));
        final camelName = TypeHelper.toCamelCase(clazz.name);
        specs.add(
          Extension(
            (b) => b
              ..name = '${clazz.name}JsonExtension'
              ..on = refer(clazz.name)
              ..methods.add(
                Method(
                  (m) => m
                    ..name = 'toJson'
                    ..returns = refer('Map<String, dynamic>')
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
                    ..body = Code(
                      '${camelName}ToMap(this, excludeNull: excludeNull)',
                    ),
                ),
              ),
          ),
        );
      }

      // Equality and Stringify mixins
      if (clazz.shouldEqualsAndHashCode && clazz.shouldStringify) {
        specs.add(equalityGen.buildMixin(clazz));
        specs.add(stringifyGen.buildClassMixin(clazz));

        // Consolidated mixin _$ClassName
        specs.add(
          Mixin(
            (b) => b
              ..name = '_\$${clazz.name}'
              ..implements.addAll([
                refer('_\$${clazz.name}EqualsAndHashCode'),
                refer('_\$${clazz.name}Stringify'),
              ])
              ..methods.addAll([
                equalityGen.buildEquals(clazz),
                equalityGen.buildHashCode(clazz),
                stringifyGen.buildToString(clazz),
              ]),
          ),
        );
      } else if (clazz.shouldEqualsAndHashCode) {
        specs.add(equalityGen.buildMixin(clazz));
      } else if (clazz.shouldStringify) {
        specs.add(stringifyGen.buildClassMixin(clazz));
      }

      // CopyWith extension
      if (clazz.shouldCopyWith) {
        specs.add(copyWithGen.buildExtension(clazz));
      }
    }

    // 4. Sealed Classes
    for (final sc in sealedClasses) {
      final subs = sealedSubclasses[sc.name] ?? const [];
      if (sc.shouldDeserialize) {
        specs.add(sealedGen.buildFromJson(sc, subs));
      }
      if (sc.shouldSerialize) {
        specs.add(sealedGen.buildToMap(sc, subs));
        final camelName = TypeHelper.toCamelCase(sc.name);
        specs.add(
          Extension(
            (b) => b
              ..name = '${sc.name}JsonExtension'
              ..on = refer(sc.name)
              ..methods.add(
                Method(
                  (m) => m
                    ..name = 'toJson'
                    ..returns = refer('Map<String, dynamic>')
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
                    ..body = Code(
                      '${camelName}ToMap(this, excludeNull: excludeNull)',
                    ),
                ),
              ),
          ),
        );
      }
    }

    // 5. Deep equality helpers if collections are present in any class using equality
    final hasCollectionFields = parsedFile.classes
        .where((c) => c.shouldEqualsAndHashCode)
        .any(equalityGen.hasCollections);

    if (hasCollectionFields) {
      specs.add(const Code(EqualityGenerator.deepEqualityHelpers));
    }

    // 6. Daxle key and prefix resolution helpers if aliases or Flatten are used
    final hasFlattenOrAliases = parsedFile.classes.any(
      (c) =>
          c.fields.any(
            (f) => f.config.isFlattened || f.config.aliases.isNotEmpty,
          ) ||
          c.constructorParams.any(
            (p) => p.config.isFlattened || p.config.aliases.isNotEmpty,
          ),
    );

    if (hasFlattenOrAliases) {
      specs.add(
        const Code('''
Object? _daxleResolveKey(
  Map<String, dynamic> json,
  String key,
  List<String> aliases,
) {
  if (json.containsKey(key)) return json[key];
  for (final alias in aliases) {
    if (json.containsKey(alias)) return json[alias];
  }
  return null;
}

bool _daxleHasKey(
  Map<String, dynamic> json,
  String key,
  List<String> aliases,
) {
  if (json.containsKey(key)) return true;
  for (final alias in aliases) {
    if (json.containsKey(alias)) return true;
  }
  return false;
}

Map<String, dynamic> _daxleExtractPrefix(
  Map<String, dynamic> json,
  String prefix,
) {
  if (prefix.isEmpty) return json;
  final result = <String, dynamic>{};
  for (final entry in json.entries) {
    if (entry.key.startsWith(prefix)) {
      result[entry.key.substring(prefix.length)] = entry.value;
    }
  }
  return result;
}
'''),
      );
    }

    final library = Library((b) => b..body.addAll(specs));
    final emittedCode = library.accept(_emitter).toString();

    final buffer = StringBuffer()
      ..writeln('// coverage:ignore-file')
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// ignore_for_file: type=lint')
      ..writeln()
      ..writeln("part of '${parsedFile.fileName}';")
      ..writeln()
      ..write(emittedCode);

    final rawCode = buffer.toString();
    try {
      return _formatter.format(rawCode);
    } catch (_) {
      return rawCode;
    }
  }
}
