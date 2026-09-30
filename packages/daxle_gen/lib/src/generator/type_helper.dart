import '../models/annotation_info.dart';
import '../models/parsed_element.dart';
import '../models/parsed_type.dart';

/// Helper for generating Dart code expressions for serialization and deserialization.
class TypeHelper {
  final Set<String> knownEnums;
  final Set<String> knownClasses;
  final Set<String> knownExtensionTypes;
  final Map<String, ParsedRecordAlias> knownRecordAliases;

  const TypeHelper({
    this.knownEnums = const {},
    this.knownClasses = const {},
    this.knownExtensionTypes = const {},
    this.knownRecordAliases = const {},
  });

  static String toCamelCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }

  /// Generates the deserialization expression for [type] from [jsonExpr].
  String generateDeserialize(
    ParsedType type,
    String jsonExpr, {
    FieldConfig? config,
    String? parameterDefaultCode,
    bool explicitFromJson = true,
    int depth = 0,
  }) {
    // Custom converter takes highest precedence
    final converter = config?.effectiveDeserializeConverter;
    if (converter != null) {
      final prefix = converter.startsWith('const ') ? '' : 'const ';
      if (type.isNullable) {
        return '$jsonExpr == null ? null : $prefix$converter.fromJson($jsonExpr)';
      }
      return '$prefix$converter.fromJson($jsonExpr)';
    }

    final fallbackCode = config?.fallbackCode ?? parameterDefaultCode;

    String expr;
    if (type.isString) {
      expr = type.isNullable
          ? '($jsonExpr as String?)'
          : '($jsonExpr as String)';
    } else if (type.isInt) {
      expr = type.isNullable
          ? '(($jsonExpr as num?)?.toInt())'
          : '(($jsonExpr as num).toInt())';
    } else if (type.isDouble) {
      expr = type.isNullable
          ? '(($jsonExpr as num?)?.toDouble())'
          : '(($jsonExpr as num).toDouble())';
    } else if (type.isNum) {
      expr = type.isNullable ? '($jsonExpr as num?)' : '($jsonExpr as num)';
    } else if (type.isBool) {
      expr = type.isNullable ? '($jsonExpr as bool?)' : '($jsonExpr as bool)';
    } else if (type.isDynamic || (type.isObject && type.isNullable)) {
      expr = jsonExpr;
    } else if (type.isObject) {
      expr = '($jsonExpr as Object)';
    } else if (type.isDateTime) {
      expr = type.isNullable
          ? '($jsonExpr == null ? null : DateTime.parse($jsonExpr as String))'
          : 'DateTime.parse($jsonExpr as String)';
    } else if (type.isUri) {
      expr = type.isNullable
          ? '($jsonExpr == null ? null : Uri.parse($jsonExpr as String))'
          : 'Uri.parse($jsonExpr as String)';
    } else if (type.isBigInt) {
      expr = type.isNullable
          ? '($jsonExpr == null ? null : BigInt.parse($jsonExpr as String))'
          : 'BigInt.parse($jsonExpr as String)';
    } else if (type.isDuration) {
      expr = type.isNullable
          ? '($jsonExpr == null ? null : Duration(microseconds: ($jsonExpr as num).toInt()))'
          : 'Duration(microseconds: ($jsonExpr as num).toInt())';
    } else if (type.isQueryMap) {
      expr = type.isNullable
          ? '($jsonExpr == null ? null : QueryMap(($jsonExpr as Map).cast<Object?, Object?>()))'
          : 'QueryMap(($jsonExpr as Map).cast<Object?, Object?>())';
    } else if (type.isList) {
      final itemVar = depth == 0 ? 'e' : 'e$depth';
      final itemType =
          type.singleTypeArgument ??
          const ParsedType(
            rawType: 'dynamic',
            baseName: 'dynamic',
            isNullable: true,
          );
      final itemDeserialize = generateDeserialize(
        itemType,
        itemVar,
        explicitFromJson: explicitFromJson,
        depth: depth + 1,
      );
      if (type.isNullable) {
        expr =
            '($jsonExpr as List<dynamic>?)?.map(($itemVar) => $itemDeserialize).toList()';
      } else {
        expr =
            '($jsonExpr as List<dynamic>).map(($itemVar) => $itemDeserialize).toList()';
      }
    } else if (type.isSet) {
      final itemVar = depth == 0 ? 'e' : 'e$depth';
      final itemType =
          type.singleTypeArgument ??
          const ParsedType(
            rawType: 'dynamic',
            baseName: 'dynamic',
            isNullable: true,
          );
      final itemDeserialize = generateDeserialize(
        itemType,
        itemVar,
        explicitFromJson: explicitFromJson,
        depth: depth + 1,
      );
      if (type.isNullable) {
        expr =
            '($jsonExpr as List<dynamic>?)?.map(($itemVar) => $itemDeserialize).toSet()';
      } else {
        expr =
            '($jsonExpr as List<dynamic>).map(($itemVar) => $itemDeserialize).toSet()';
      }
    } else if (type.isMap) {
      final kVar = depth == 0 ? 'k' : 'k$depth';
      final vVar = depth == 0 ? 'v' : 'v$depth';
      final keyType = type.typeArguments.isNotEmpty
          ? type.typeArguments[0]
          : const ParsedType(
              rawType: 'String',
              baseName: 'String',
              isNullable: false,
            );
      final valType = type.typeArguments.length > 1
          ? type.typeArguments[1]
          : const ParsedType(
              rawType: 'dynamic',
              baseName: 'dynamic',
              isNullable: true,
            );
      final keyDeserialize = _generateKeyDeserialize(
        keyType,
        kVar,
        explicitFromJson: explicitFromJson,
      );
      final valDeserialize = generateDeserialize(
        valType,
        vVar,
        explicitFromJson: explicitFromJson,
        depth: depth + 1,
      );
      if (type.isNullable) {
        expr =
            '($jsonExpr as Map<String, dynamic>?)?.map(($kVar, $vVar) => MapEntry($keyDeserialize, $valDeserialize))';
      } else {
        expr =
            '($jsonExpr as Map<String, dynamic>).map(($kVar, $vVar) => MapEntry($keyDeserialize, $valDeserialize))';
      }
    } else if (knownEnums.contains(type.baseName)) {
      final fn = '${toCamelCase(type.baseName)}FromValue';
      expr = type.isNullable
          ? '($jsonExpr == null ? null : $fn($jsonExpr))'
          : '$fn($jsonExpr)';
    } else if (knownExtensionTypes.contains(type.baseName)) {
      final fn = '${toCamelCase(type.baseName)}FromMap';
      expr = type.isNullable
          ? '($jsonExpr == null ? null : $fn($jsonExpr))'
          : '$fn($jsonExpr)';
    } else if (knownRecordAliases.containsKey(type.baseName)) {
      final alias = knownRecordAliases[type.baseName]!;
      final isPos = alias.recordType.isRecordPositional;
      final fn =
          '${toCamelCase(type.baseName)}${isPos ? "FromList" : "FromMap"}';
      final castType = isPos ? 'List<dynamic>' : 'Map<String, dynamic>';
      expr = type.isNullable
          ? '($jsonExpr == null ? null : $fn($jsonExpr as $castType))'
          : '$fn($jsonExpr as $castType)';
    } else if (type.isRecord) {
      if (type.isRecordPositional) {
        final varName = 'list${depth == 0 ? '' : depth}';
        final fieldExprs = type.recordFields.map((f) {
          return generateDeserialize(
            f.type,
            '$varName[${f.position - 1}]',
            explicitFromJson: explicitFromJson,
            depth: depth + 1,
          );
        }).join(', ');
        expr = type.isNullable
            ? '($jsonExpr == null ? null : (() { final $varName = $jsonExpr as List<dynamic>; return ($fieldExprs); })())'
            : '(() { final $varName = $jsonExpr as List<dynamic>; return ($fieldExprs); })()';
      } else {
        final varName = 'map${depth == 0 ? '' : depth}';
        final fieldExprs = type.recordFields.map((f) {
          final key = f.effectiveKey;
          final fieldVal = generateDeserialize(
            f.type,
            "$varName['$key']",
            explicitFromJson: explicitFromJson,
            depth: depth + 1,
          );
          return f.isNamed ? '${f.name}: $fieldVal' : fieldVal;
        }).join(', ');
        expr = type.isNullable
            ? '($jsonExpr == null ? null : (() { final $varName = $jsonExpr as Map<String, dynamic>; return ($fieldExprs); })())'
            : '(() { final $varName = $jsonExpr as Map<String, dynamic>; return ($fieldExprs); })()';
      }
    } else {
      if (!explicitFromJson) {
        expr = '($jsonExpr as ${type.rawType})';
      } else {
        final fn = '${toCamelCase(type.baseName)}FromMap';
        expr = type.isNullable
            ? '($jsonExpr == null ? null : $fn($jsonExpr as Map<String, dynamic>))'
            : '$fn($jsonExpr as Map<String, dynamic>)';
      }
    }


    if (fallbackCode != null) {
      return '$jsonExpr == null ? $fallbackCode : $expr';
    }

    return expr;
  }

  /// Generates the serialization expression for [type] from [fieldExpr].
  String generateSerialize(
    ParsedType type,
    String fieldExpr, {
    FieldConfig? config,
    bool explicitToJson = true,
    int depth = 0,
  }) {
    final converter = config?.effectiveSerializeConverter;
    if (converter != null) {
      final prefix = converter.startsWith('const ') ? '' : 'const ';
      if (type.isNullable) {
        return '$fieldExpr == null ? null : $prefix$converter.toJson($fieldExpr!)';
      }
      return '$prefix$converter.toJson($fieldExpr)';
    }

    String expr;
    if (type.isPrimitive) {
      expr = fieldExpr;
    } else if (type.isDateTime) {
      expr = type.isNullable
          ? '$fieldExpr?.toIso8601String()'
          : '$fieldExpr.toIso8601String()';
    } else if (type.isUri || type.isBigInt) {
      expr = type.isNullable
          ? '$fieldExpr?.toString()'
          : '$fieldExpr.toString()';
    } else if (type.isDuration) {
      expr = type.isNullable
          ? '$fieldExpr?.inMicroseconds'
          : '$fieldExpr.inMicroseconds';
    } else if (type.isQueryMap) {
      expr = type.isNullable ? '$fieldExpr?.map' : '$fieldExpr.map';
    } else if (type.isList) {
      final itemVar = depth == 0 ? 'e' : 'e$depth';
      final itemType = type.singleTypeArgument;
      if (itemType == null || (itemType.isPrimitive && explicitToJson)) {
        expr = fieldExpr;
      } else {
        final itemSerialize = generateSerialize(
          itemType,
          itemVar,
          explicitToJson: explicitToJson,
          depth: depth + 1,
        );
        expr = type.isNullable
            ? '$fieldExpr?.map(($itemVar) => $itemSerialize).toList()'
            : '$fieldExpr.map(($itemVar) => $itemSerialize).toList()';
      }
    } else if (type.isSet) {
      final itemVar = depth == 0 ? 'e' : 'e$depth';
      final itemType = type.singleTypeArgument;
      if (itemType == null || itemType.isPrimitive) {
        expr = type.isNullable ? '$fieldExpr?.toList()' : '$fieldExpr.toList()';
      } else {
        final itemSerialize = generateSerialize(
          itemType,
          itemVar,
          explicitToJson: explicitToJson,
          depth: depth + 1,
        );
        expr = type.isNullable
            ? '$fieldExpr?.map(($itemVar) => $itemSerialize).toList()'
            : '$fieldExpr.map(($itemVar) => $itemSerialize).toList()';
      }
    } else if (type.isMap) {
      final kVar = depth == 0 ? 'k' : 'k$depth';
      final vVar = depth == 0 ? 'v' : 'v$depth';
      final keyType = type.typeArguments.isNotEmpty
          ? type.typeArguments[0]
          : const ParsedType(
              rawType: 'String',
              baseName: 'String',
              isNullable: false,
            );
      final valType = type.typeArguments.length > 1
          ? type.typeArguments[1]
          : null;
      final keyNeedsConversion =
          !keyType.isString && !keyType.isDynamic && !keyType.isObject;
      final valNeedsConversion =
          valType != null && !(valType.isPrimitive && explicitToJson);

      if (!keyNeedsConversion && !valNeedsConversion) {
        expr = fieldExpr;
      } else {
        final keySerialize = _generateKeySerialize(
          keyType,
          kVar,
          explicitToJson: explicitToJson,
        );
        final valSerialize = valType == null
            ? vVar
            : generateSerialize(
                valType,
                vVar,
                explicitToJson: explicitToJson,
                depth: depth + 1,
              );
        expr = type.isNullable
            ? '$fieldExpr?.map(($kVar, $vVar) => MapEntry($keySerialize, $valSerialize))'
            : '$fieldExpr.map(($kVar, $vVar) => MapEntry($keySerialize, $valSerialize))';
      }
    } else if (knownEnums.contains(type.baseName)) {
      final fn = '${toCamelCase(type.baseName)}ToValue';
      expr = type.isNullable
          ? '($fieldExpr == null ? null : $fn($fieldExpr!))'
          : '$fn($fieldExpr)';
    } else if (knownExtensionTypes.contains(type.baseName)) {
      final fn = '${toCamelCase(type.baseName)}ToMap';
      expr = type.isNullable
          ? '($fieldExpr == null ? null : $fn($fieldExpr!))'
          : '$fn($fieldExpr)';
    } else if (knownRecordAliases.containsKey(type.baseName)) {
      final alias = knownRecordAliases[type.baseName]!;
      final isPos = alias.recordType.isRecordPositional;
      final fn = '${toCamelCase(type.baseName)}${isPos ? "ToList" : "ToMap"}';
      expr = type.isNullable
          ? '($fieldExpr == null ? null : $fn($fieldExpr!))'
          : '$fn($fieldExpr)';
    } else if (type.isRecord) {
      if (type.isRecordPositional) {
        final elements = type.recordFields.map((f) {
          final access = type.isNullable
              ? '$fieldExpr!.\$${f.position}'
              : '$fieldExpr.\$${f.position}';
          return generateSerialize(
            f.type,
            access,
            explicitToJson: explicitToJson,
            depth: depth + 1,
          );
        }).join(', ');
        expr = type.isNullable
            ? '($fieldExpr == null ? null : [$elements])'
            : '[$elements]';
      } else {
        final entries = type.recordFields.map((f) {
          final key = f.effectiveKey;
          final member = f.isNamed ? f.name! : '\$${f.position}';
          final access = type.isNullable
              ? '$fieldExpr!.$member'
              : '$fieldExpr.$member';
          final serialized = generateSerialize(
            f.type,
            access,
            explicitToJson: explicitToJson,
            depth: depth + 1,
          );
          return "'$key': $serialized";
        }).join(', ');
        expr = type.isNullable
            ? '($fieldExpr == null ? null : {$entries})'
            : '{$entries}';
      }
    } else {
      if (!explicitToJson) {
        expr = fieldExpr;
      } else {
        final fn = '${toCamelCase(type.baseName)}ToMap';
        expr = type.isNullable
            ? '($fieldExpr == null ? null : $fn($fieldExpr!))'
            : '$fn($fieldExpr)';
      }
    }


    final serializeFallback = config?.fallbackCode;
    if (serializeFallback != null && type.isNullable) {
      if (type.isPrimitive) {
        return '$fieldExpr ?? $serializeFallback';
      }
      return '$fieldExpr == null ? $serializeFallback : $expr';
    }

    return expr;
  }

  /// Generates the serialization expression for [type] from [fieldExpr] when caller
  /// guarantees [fieldExpr] is not null (e.g. inside `if ($fieldExpr != null)`).
  String generateSerializeNonNull(
    ParsedType type,
    String fieldExpr, {
    FieldConfig? config,
    bool explicitToJson = true,
    int depth = 0,
  }) {
    final converter = config?.effectiveSerializeConverter;
    if (converter != null) {
      final prefix = converter.startsWith('const ') ? '' : 'const ';
      return '$prefix$converter.toJson($fieldExpr!)';
    }

    if (type.isPrimitive) {
      return fieldExpr;
    } else if (type.isDateTime) {
      return '$fieldExpr!.toIso8601String()';
    } else if (type.isUri || type.isBigInt) {
      return '$fieldExpr!.toString()';
    } else if (type.isDuration) {
      return '$fieldExpr!.inMicroseconds';
    } else if (type.isQueryMap) {
      return '$fieldExpr!.map';
    } else if (type.isList) {
      final itemVar = depth == 0 ? 'e' : 'e$depth';
      final itemType = type.singleTypeArgument;
      if (itemType == null || (itemType.isPrimitive && explicitToJson)) {
        return fieldExpr;
      }
      final itemSerialize = generateSerialize(
        itemType,
        itemVar,
        explicitToJson: explicitToJson,
        depth: depth + 1,
      );
      return '$fieldExpr!.map(($itemVar) => $itemSerialize).toList()';
    } else if (type.isSet) {
      final itemVar = depth == 0 ? 'e' : 'e$depth';
      final itemType = type.singleTypeArgument;
      if (itemType == null || itemType.isPrimitive) {
        return '$fieldExpr!.toList()';
      }
      final itemSerialize = generateSerialize(
        itemType,
        itemVar,
        explicitToJson: explicitToJson,
        depth: depth + 1,
      );
      return '$fieldExpr!.map(($itemVar) => $itemSerialize).toList()';
    } else if (type.isMap) {
      final kVar = depth == 0 ? 'k' : 'k$depth';
      final vVar = depth == 0 ? 'v' : 'v$depth';
      final keyType = type.typeArguments.isNotEmpty
          ? type.typeArguments[0]
          : const ParsedType(
              rawType: 'String',
              baseName: 'String',
              isNullable: false,
            );
      final valType = type.typeArguments.length > 1
          ? type.typeArguments[1]
          : null;
      final keyNeedsConversion =
          !keyType.isString && !keyType.isDynamic && !keyType.isObject;
      final valNeedsConversion =
          valType != null && !(valType.isPrimitive && explicitToJson);

      if (!keyNeedsConversion && !valNeedsConversion) {
        return fieldExpr;
      }
      final keySerialize = _generateKeySerialize(
        keyType,
        kVar,
        explicitToJson: explicitToJson,
      );
      final valSerialize = valType == null
          ? vVar
          : generateSerialize(
              valType,
              vVar,
              explicitToJson: explicitToJson,
              depth: depth + 1,
            );
      return '$fieldExpr!.map(($kVar, $vVar) => MapEntry($keySerialize, $valSerialize))';
    } else if (knownEnums.contains(type.baseName)) {
      final fn = '${toCamelCase(type.baseName)}ToValue';
      return '$fn($fieldExpr!)';
    } else if (knownExtensionTypes.contains(type.baseName)) {
      final fn = '${toCamelCase(type.baseName)}ToMap';
      return '$fn($fieldExpr!)';
    } else if (knownRecordAliases.containsKey(type.baseName)) {
      final alias = knownRecordAliases[type.baseName]!;
      final isPos = alias.recordType.isRecordPositional;
      final fn = '${toCamelCase(type.baseName)}${isPos ? "ToList" : "ToMap"}';
      return '$fn($fieldExpr!)';
    } else if (type.isRecord) {
      if (type.isRecordPositional) {
        final elements = type.recordFields.map((f) {
          return generateSerialize(
            f.type,
            '$fieldExpr!.\$${f.position}',
            explicitToJson: explicitToJson,
            depth: depth + 1,
          );
        }).join(', ');
        return '[$elements]';
      } else {
        final entries = type.recordFields.map((f) {
          final key = f.effectiveKey;
          final member = f.isNamed ? f.name! : '\$${f.position}';
          final serialized = generateSerialize(
            f.type,
            '$fieldExpr!.$member',
            explicitToJson: explicitToJson,
            depth: depth + 1,
          );
          return "'$key': $serialized";
        }).join(', ');
        return '{$entries}';
      }
    } else {
      if (!explicitToJson) {
        return fieldExpr;
      }
      final fn = '${toCamelCase(type.baseName)}ToMap';
      return '$fn($fieldExpr!)';
    }

  }

  String _generateKeyDeserialize(
    ParsedType keyType,
    String kVar, {
    bool explicitFromJson = true,
  }) {
    if (keyType.isString ||
        keyType.isDynamic ||
        (keyType.isObject && keyType.isNullable)) {
      return kVar;
    } else if (keyType.isObject) {
      return '($kVar as Object)';
    } else if (keyType.isInt) {
      return 'int.parse($kVar)';
    } else if (keyType.isDouble) {
      return 'double.parse($kVar)';
    } else if (keyType.isNum) {
      return 'num.parse($kVar)';
    } else if (keyType.isBigInt) {
      return 'BigInt.parse($kVar)';
    } else if (keyType.isUri) {
      return 'Uri.parse($kVar)';
    } else if (keyType.isDateTime) {
      return 'DateTime.parse($kVar)';
    } else if (knownEnums.contains(keyType.baseName)) {
      final fn = '${toCamelCase(keyType.baseName)}FromValue';
      return '$fn($kVar)';
    } else if (knownExtensionTypes.contains(keyType.baseName)) {
      final fn = '${toCamelCase(keyType.baseName)}FromMap';
      return '$fn($kVar)';
    } else {
      if (!explicitFromJson) {
        return '($kVar as ${keyType.rawType})';
      } else {
        return kVar;
      }
    }
  }

  String _generateKeySerialize(
    ParsedType keyType,
    String kVar, {
    bool explicitToJson = true,
  }) {
    if (keyType.isString || keyType.isDynamic || keyType.isObject) {
      return kVar;
    } else if (keyType.isInt ||
        keyType.isDouble ||
        keyType.isNum ||
        keyType.isBool ||
        keyType.isBigInt ||
        keyType.isUri) {
      return '$kVar.toString()';
    } else if (keyType.isDateTime) {
      return '$kVar.toIso8601String()';
    } else if (knownEnums.contains(keyType.baseName)) {
      final fn = '${toCamelCase(keyType.baseName)}ToValue';
      return '$fn($kVar).toString()';
    } else if (knownExtensionTypes.contains(keyType.baseName)) {
      final fn = '${toCamelCase(keyType.baseName)}ToMap';
      return '$fn($kVar).toString()';
    } else {
      return '$kVar.toString()';
    }
  }
}
