import 'package:analyzer/dart/ast/ast.dart';

import '../../models/annotation_info.dart';
import '../generation_error.dart';
import 'annotation_handler.dart';
import 'member_annotation_handlers.dart';
import 'type_annotation_handlers.dart';

/// Central registry managing modular annotation handlers and resolution.
final class AnnotationRegistry {
  final Map<String, AnnotationHandler<Object?>> _handlers = {};

  AnnotationRegistry() {
    registerDefaultHandlers();
  }

  /// Registers a new or custom [AnnotationHandler].
  void register<T>(AnnotationHandler<T> handler) {
    for (final name in handler.supportedNames) {
      _handlers[name] = handler;
    }
  }

  /// Registers built-in handlers for standard Daxle annotations.
  void registerDefaultHandlers() {
    register(const SerializeAnnotationHandler());
    register(const DeserializeAnnotationHandler());
    register(const EqualsAndHashCodeAnnotationHandler());
    register(const StringifyAnnotationHandler());
    register(const CopyWithAnnotationHandler());
    register(const SerializedValueAnnotationHandler());
    register(const FallbackAnnotationHandler());
    register(const FlattenAnnotationHandler());
    register(const IgnoreAnnotationHandler());
    register(const RedactAnnotationHandler());
    register(const StateMachineAnnotationHandler());
  }

  /// Extracts identifier name from an AST annotation (stripping library prefixes).
  static String getAnnotationName(Annotation annotation) {
    return annotation.name.name.split('.').last;
  }

  /// Resolves annotations, recursively expanding any [AnnotationBundle] constants.
  Iterable<(String name, ArgumentList? arguments, TypeArgumentList? typeArguments)>
  resolveAnnotations(
    NodeList<Annotation> metadata,
    Map<String, List<BundledAnnotation>> bundleMap,
  ) sync* {
    for (final annotation in metadata) {
      final name = getAnnotationName(annotation);
      final constituents = bundleMap[name];
      if (constituents != null) {
        for (final c in constituents) {
          yield (c.name, c.argumentList ?? annotation.arguments, annotation.typeArguments);
        }
      } else {
        yield (name, annotation.arguments, annotation.typeArguments);
      }
    }
  }

  /// Parses a typed annotation using the registered handler for [name].
  T? parseAnnotation<T>({
    required String name,
    required ArgumentList? arguments,
    TypeArgumentList? typeArguments,
    String memberName = '',
  }) {
    final handler = _handlers[name];
    if (handler is AnnotationHandler<T>) {
      return handler.parse((
        name: name,
        arguments: arguments,
        typeArguments: typeArguments,
        memberName: memberName,
      ));
    }
    return null;
  }

  /// Parses member metadata into a consolidated [FieldConfig].
  FieldConfig parseFieldConfig(
    NodeList<Annotation> metadata,
    Map<String, List<BundledAnnotation>> bundleMap, {
    String memberName = 'member',
  }) {
    String? serializedKey;
    var aliases = <String>[];
    String? fallbackCode;
    String? converterCode;
    var isFlattened = false;
    var flattenPrefix = '';
    var isIgnored = false;
    var hasSerializedValue = false;
    var hasFallback = false;
    RedactConfig? redactConfig;

    for (final (name, arguments, typeArguments) in resolveAnnotations(metadata, bundleMap)) {
      final context = (name: name, arguments: arguments, typeArguments: typeArguments, memberName: memberName);
      switch (name) {
        case 'ignore' || 'Ignore':
          isIgnored = true;
        case 'Flatten' || 'flatten':
          isFlattened = true;
          flattenPrefix = const FlattenAnnotationHandler().parse(context);
        case 'SerializedValue':
          hasSerializedValue = true;
          final data = const SerializedValueAnnotationHandler().parse(context);
          serializedKey = data.serializedKey;
          aliases = data.aliases;
          converterCode = data.converterCode;
        case 'Fallback':
          hasFallback = true;
          fallbackCode = const FallbackAnnotationHandler().parse(context);
        case 'Redact' || 'redact':
          redactConfig = const RedactAnnotationHandler().parse(context);
      }
    }

    if (isIgnored &&
        (hasSerializedValue ||
            hasFallback ||
            isFlattened ||
            redactConfig != null)) {
      throw InvalidGenerationSourceError(
        '@ignore cannot coexist with @SerializedValue, @Fallback, @Flatten, or @redact on "$memberName".',
        todo:
            'Remove either @ignore or @SerializedValue/@Fallback/@Flatten/@redact from "$memberName".',
      );
    }

    if (isFlattened && hasSerializedValue) {
      throw InvalidGenerationSourceError(
        '@Flatten cannot coexist with @SerializedValue on "$memberName".',
        todo: 'Remove either @Flatten or @SerializedValue from "$memberName".',
      );
    }

    return FieldConfig(
      serializedKey: serializedKey,
      aliases: aliases,
      fallbackCode: fallbackCode,
      converterCode: converterCode,
      isFlattened: isFlattened,
      flattenPrefix: flattenPrefix,
      isIgnored: isIgnored,
      redactConfig: redactConfig,
    );
  }
}
