import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';
import 'type_helper.dart';

/// Generates top-level functional serialization and deserialization for extension types.
class ExtensionTypeGenerator {
  final TypeHelper typeHelper;
  final DartEmitter _emitter;

  ExtensionTypeGenerator(this.typeHelper)
    : _emitter = DartEmitter(useNullSafetySyntax: true);

  /// Builds the serialization and deserialization [Spec] list for an extension type.
  List<Spec> build(ParsedExtensionType extType) {
    final specs = <Spec>[];
    final camelName = TypeHelper.toCamelCase(extType.name);
    final fieldName = extType.representationFieldName;
    final repType = extType.representationType;

    if (extType.shouldSerialize) {
      final serializeExpr = typeHelper.generateSerialize(
        repType,
        'instance.$fieldName',
        explicitToJson: true,
      );

      specs.add(
        Method(
          (b) => b
            ..name = '${camelName}ToMap'
            ..returns = refer('dynamic')
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'instance'
                  ..type = refer(extType.name),
              ),
            )
            ..lambda = true
            ..body = Code(serializeExpr),
        ),
      );

      specs.add(
        Extension(
          (b) => b
            ..name = '${extType.name}ToMapExtension'
            ..on = refer(extType.name)
            ..methods.add(
              Method(
                (m) => m
                  ..name = 'toMap'
                  ..returns = refer('dynamic')
                  ..lambda = true
                  ..body = Code('${camelName}ToMap(this)'),
              ),
            ),
        ),
      );
    }

    if (extType.shouldDeserialize) {
      final deserializeExpr = typeHelper.generateDeserialize(
        repType,
        'json',
        explicitFromJson: true,
      );

      specs.add(
        Method(
          (b) => b
            ..name = '${camelName}FromMap'
            ..returns = refer(extType.name)
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'json'
                  ..type = refer('Object?'),
              ),
            )
            ..lambda = true
            ..body = Code('${extType.name}($deserializeExpr)'),
        ),
      );
    }

    return specs;
  }

  /// Generates the extension type serialization code as a formatted string.
  String generate(ParsedExtensionType extType) {
    final specs = build(extType);
    final buffer = StringBuffer();
    for (final spec in specs) {
      buffer.writeln(spec.accept(_emitter));
      buffer.writeln();
    }
    return buffer.toString();
  }
}
