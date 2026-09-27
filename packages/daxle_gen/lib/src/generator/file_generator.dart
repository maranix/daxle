import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import '../models/parsed_element.dart';
import 'class_generator.dart';
import 'enum_generator.dart';
import 'sealed_generator.dart';
import 'type_helper.dart';

/// Coordinates generation for an entire file using [code_builder] and [dart_style].
class FileGenerator {
  final DartFormatter _formatter;
  final DartEmitter _emitter;

  FileGenerator({DartFormatter? formatter, DartEmitter? emitter})
      : _formatter = formatter ??
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

    final specs = <Spec>[];

    // 1. Enums
    for (final parsedEnum in parsedFile.enums) {
      if (parsedEnum.shouldSerialize || parsedEnum.shouldDeserialize) {
        specs.addAll(enumGen.build(parsedEnum));
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
      }
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
