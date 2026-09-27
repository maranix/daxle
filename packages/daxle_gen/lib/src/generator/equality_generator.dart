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
            if (isCollectionField(f)) {
              return '_daxleDeepEquals(self.${f.name}, other.${f.name})';
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
      if (isCollectionField(f)) {
        return '_daxleDeepHashCode(self.${f.name})';
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

  static const String deepEqualityHelpers = '''
bool _daxleDeepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;

  if (a is List && b is List) {
    final length = a.length;
    if (length != b.length) return false;
    for (var i = 0; i < length; i++) {
      if (!_daxleDeepEquals(a[i], b[i])) return false;
    }
    return true;
  }

  if (a is Set && b is Set) {
    if (a.length != b.length) return false;
    for (final element in a) {
      if (!b.contains(element)) {
        var found = false;
        for (final otherElement in b) {
          if (_daxleDeepEquals(element, otherElement)) {
            found = true;
            break;
          }
        }
        if (!found) return false;
      }
    }
    return true;
  }

  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key)) return false;
      if (!_daxleDeepEquals(entry.value, b[entry.key])) return false;
    }
    return true;
  }

  if (a is Iterable && b is Iterable) {
    final itA = a.iterator;
    final itB = b.iterator;
    while (itA.moveNext()) {
      if (!itB.moveNext()) return false;
      if (!_daxleDeepEquals(itA.current, itB.current)) return false;
    }
    return !itB.moveNext();
  }

  return a == b;
}

int _daxleDeepHashCode(Object? value) {
  if (value == null) return 0;
  if (value is List) {
    var hash = 1;
    for (var i = 0; i < value.length; i++) {
      hash = 0x1fffffff & (hash + _daxleDeepHashCode(value[i]));
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
  if (value is Set) {
    var hash = 0;
    for (final element in value) {
      hash = (hash + _daxleDeepHashCode(element)) & 0x3fffffff;
    }
    return hash;
  }
  if (value is Map) {
    var hash = 0;
    for (final entry in value.entries) {
      final entryHash =
          (_daxleDeepHashCode(entry.key) ^ _daxleDeepHashCode(entry.value)) &
              0x3fffffff;
      hash = (hash + entryHash) & 0x3fffffff;
    }
    return hash;
  }
  if (value is Iterable) {
    var hash = 1;
    for (final element in value) {
      hash = 0x1fffffff & (hash + _daxleDeepHashCode(element));
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
  return value.hashCode;
}
''';
}
