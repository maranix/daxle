import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';
import 'type_helper.dart';

/// Generates equality (`operator ==`) and [hashCode] mixins for classes.
class EqualityGenerator {
  final TypeHelper typeHelper;

  EqualityGenerator(this.typeHelper);

  bool isCollectionField(ParsedField field) {
    final type = field.type;
    return type.isList ||
        type.isSet ||
        type.isMap ||
        type.isQueryMap ||
        type.isDynamic ||
        type.baseName == 'Object' ||
        type.baseName == 'Iterable';
  }

  int fieldSortPriority(ParsedField field) {
    final type = field.type;
    // Priority 0: Cheap primitives and enums
    if (type.isBool ||
        type.isInt ||
        type.isDouble ||
        type.isNum ||
        type.isString ||
        typeHelper.knownEnums.contains(type.baseName)) {
      return 0;
    }
    // Priority 1: Other non-collection objects (DateTime, Uri, Duration, BigInt, nested models, etc.)
    if (!isCollectionField(field)) {
      return 1;
    }
    // Priority 2: Collections and dynamic/untyped
    return 2;
  }

  bool hasCollections(ParsedClass clazz) {
    final activeFields = clazz.fields.where(
      (f) => !f.isIgnoredForEquals(clazz.equalsAndHashCode),
    );
    return activeFields.any(isCollectionField);
  }

  Method buildEquals(ParsedClass clazz) {
    final activeFields = clazz.fields
        .where((f) => !f.isIgnoredForEquals(clazz.equalsAndHashCode))
        .toList();

    // Sort fields stably: cheap primitives first, non-collections next, collections last
    activeFields.sort((a, b) {
      final prioA = fieldSortPriority(a);
      final prioB = fieldSortPriority(b);
      return prioA.compareTo(prioB);
    });

    final String equalsBody;
    if (activeFields.isEmpty) {
      equalsBody =
          'return identical(this, other) ||\n'
          '    other is ${clazz.name} && runtimeType == other.runtimeType;';
    } else {
      final comparisons = activeFields
          .map((f) {
            if (f.type.isList) {
              return '\$listEquals(self.${f.name}, other.${f.name})';
            } else if (f.type.isSet) {
              return '\$setEquals(self.${f.name}, other.${f.name})';
            } else if (f.type.isMap) {
              return '\$mapEquals(self.${f.name}, other.${f.name})';
            } else if (f.type.isQueryMap) {
              return '\$mapEquals(self.${f.name}.map, other.${f.name}.map)';
            } else if (isCollectionField(f)) {
              return '\$deepEquals(self.${f.name}, other.${f.name})';
            } else {
              return 'self.${f.name} == other.${f.name}';
            }
          })
          .join(' &&\n        ');

      equalsBody =
          'if (identical(this, other)) return true;\n'
          '    if (other is! ${clazz.name} || runtimeType != other.runtimeType) return false;\n'
          '    final self = this as ${clazz.name};\n'
          '    return $comparisons;';
    }

    return Method(
      (m) => m
        ..annotations.add(refer('override'))
        ..name = 'operator =='
        ..returns = refer('bool')
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'other'
              ..type = refer('Object'),
          ),
        )
        ..body = Code(equalsBody),
    );
  }

  Method buildHashCode(ParsedClass clazz) {
    final activeFields = clazz.fields
        .where((f) => !f.isIgnoredForEquals(clazz.equalsAndHashCode))
        .toList();

    if (activeFields.isEmpty) {
      return Method(
        (m) => m
          ..annotations.add(refer('override'))
          ..name = 'hashCode'
          ..type = MethodType.getter
          ..returns = refer('int')
          ..lambda = true
          ..body = const Code('0'),
      );
    }

    final fieldExprs = activeFields.map((f) {
      if (f.type.isList) {
        return '\$listHashCode(self.${f.name})';
      } else if (f.type.isSet) {
        return '\$setHashCode(self.${f.name})';
      } else if (f.type.isMap) {
        return '\$mapHashCode(self.${f.name})';
      } else if (f.type.isQueryMap) {
        return '\$mapHashCode(self.${f.name}.map)';
      } else if (isCollectionField(f)) {
        return '\$deepHashCode(self.${f.name})';
      } else {
        return 'self.${f.name}';
      }
    }).toList();

    final String hashCodeExpr = fieldExprs.length == 1
        ? 'Object.hash(${fieldExprs[0]}, null)'
        : _buildNestedHash(fieldExprs);

    final hashCodeBody =
        'final self = this as ${clazz.name};\nreturn $hashCodeExpr;';

    return Method(
      (m) => m
        ..annotations.add(refer('override'))
        ..name = 'hashCode'
        ..type = MethodType.getter
        ..returns = refer('int')
        ..body = Code(hashCodeBody),
    );
  }

  String _buildNestedHash(List<String> exprs) {
    if (exprs.length <= 20) {
      return 'Object.hash(${exprs.join(', ')})';
    }
    final first19 = exprs.take(19).toList();
    final remainder = exprs.skip(19).toList();
    first19.add(_buildNestedHash(remainder));
    return 'Object.hash(${first19.join(', ')})';
  }

  Mixin buildMixin(ParsedClass clazz) {
    return Mixin(
      (b) => b
        ..name = '_\$${clazz.name}EqualsAndHashCode'
        ..methods.addAll([
          buildEquals(clazz),
          buildHashCode(clazz),
        ]),
    );
  }
}
