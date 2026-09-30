import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';
import 'type_helper.dart';

/// Generates top-level functional serialization and deserialization for record typedefs.
class RecordGenerator {
  final TypeHelper typeHelper;
  final DartEmitter _emitter;

  RecordGenerator(this.typeHelper)
      : _emitter = DartEmitter(useNullSafetySyntax: true);

  /// Builds the serialization and deserialization [Spec] list for a record typedef.
  List<Spec> build(ParsedRecordAlias alias) {
    final specs = <Spec>[];
    final camelName = TypeHelper.toCamelCase(alias.name);
    final recType = alias.recordType;
    final isPositional = recType.isRecordPositional;

    if (isPositional) {
      _buildPositionalSpecs(alias, camelName, specs);
    } else {
      _buildNamedSpecs(alias, camelName, specs);
    }

    return specs;
  }

  void _buildPositionalSpecs(
    ParsedRecordAlias alias,
    String camelName,
    List<Spec> specs,
  ) {
    final recType = alias.recordType;

    if (alias.shouldSerialize) {
      final elements = recType.recordFields.map((f) {
        return typeHelper.generateSerialize(
          f.type,
          'instance.\$${f.position}',
          explicitToJson: true,
        );
      }).join(', ');

      specs.add(
        Method(
          (b) => b
            ..name = '${camelName}ToList'
            ..returns = refer('List<dynamic>')
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'instance'
                  ..type = refer(alias.name),
              ),
            )
            ..lambda = true
            ..body = Code('[$elements]'),
        ),
      );

      specs.add(
        Extension(
          (b) => b
            ..name = '${alias.name}ToListExtension'
            ..on = refer(alias.name)
            ..methods.add(
              Method(
                (m) => m
                  ..name = 'toList'
                  ..returns = refer('List<dynamic>')
                  ..lambda = true
                  ..body = Code('${camelName}ToList(this)'),
              ),
            ),
        ),
      );
    }

    if (alias.shouldDeserialize) {
      final fieldDeserializers = recType.recordFields.map((f) {
        final itemExpr = typeHelper.generateDeserialize(
          f.type,
          'list[${f.position - 1}]',
          explicitFromJson: true,
        );
        return itemExpr;
      }).join(', ');

      specs.add(
        Method(
          (b) => b
            ..name = '${camelName}FromList'
            ..returns = refer(alias.name)
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'list'
                  ..type = refer('List<dynamic>'),
              ),
            )
            ..lambda = true
            ..body = Code('($fieldDeserializers)'),
        ),
      );

      specs.add(
        Extension(
          (b) => b
            ..name = '${alias.name}ListExtension'
            ..on = refer('List<dynamic>')
            ..methods.add(
              Method(
                (m) => m
                  ..name = 'to${alias.name}'
                  ..returns = refer(alias.name)
                  ..lambda = true
                  ..body = Code('${camelName}FromList(this)'),
              ),
            ),
        ),
      );
    }
  }

  void _buildNamedSpecs(
    ParsedRecordAlias alias,
    String camelName,
    List<Spec> specs,
  ) {
    final recType = alias.recordType;

    if (alias.shouldSerialize) {
      final entries = recType.recordFields.map((f) {
        final key = f.effectiveKey;
        final member = f.isNamed ? f.name! : '\$${f.position}';
        final valExpr = typeHelper.generateSerialize(
          f.type,
          'instance.$member',
          explicitToJson: true,
        );
        return "'$key': $valExpr";
      }).join(', ');

      specs.add(
        Method(
          (b) => b
            ..name = '${camelName}ToMap'
            ..returns = refer('Map<String, dynamic>')
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'instance'
                  ..type = refer(alias.name),
              ),
            )
            ..lambda = true
            ..body = Code('{$entries}'),
        ),
      );

      specs.add(
        Extension(
          (b) => b
            ..name = '${alias.name}ToMapExtension'
            ..on = refer(alias.name)
            ..methods.add(
              Method(
                (m) => m
                  ..name = 'toMap'
                  ..returns = refer('Map<String, dynamic>')
                  ..lambda = true
                  ..body = Code('${camelName}ToMap(this)'),
              ),
            ),
        ),
      );
    }

    if (alias.shouldDeserialize) {
      final fieldDeserializers = recType.recordFields.map((f) {
        final key = f.effectiveKey;
        final fieldExpr = typeHelper.generateDeserialize(
          f.type,
          "map['$key']",
          explicitFromJson: true,
        );
        return f.isNamed ? '${f.name}: $fieldExpr' : fieldExpr;
      }).join(', ');

      specs.add(
        Method(
          (b) => b
            ..name = '${camelName}FromMap'
            ..returns = refer(alias.name)
            ..requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'map'
                  ..type = refer('Map<String, dynamic>'),
              ),
            )
            ..lambda = true
            ..body = Code('($fieldDeserializers)'),
        ),
      );

      specs.add(
        Extension(
          (b) => b
            ..name = '${alias.name}MapExtension'
            ..on = refer('Map<String, dynamic>')
            ..methods.add(
              Method(
                (m) => m
                  ..name = 'to${alias.name}'
                  ..returns = refer(alias.name)
                  ..lambda = true
                  ..body = Code('${camelName}FromMap(this)'),
              ),
            ),
        ),
      );
    }

  }

  /// Generates the record serialization code as a formatted string.
  String generate(ParsedRecordAlias alias) {
    final specs = build(alias);
    final buffer = StringBuffer();
    for (final spec in specs) {
      buffer.writeln(spec.accept(_emitter));
      buffer.writeln();
    }
    return buffer.toString();
  }
}
