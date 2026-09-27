/// Descriptor for a parsed Dart type.
class ParsedType {
  final String rawType;
  final String baseName;
  final bool isNullable;
  final List<ParsedType> typeArguments;

  const ParsedType({
    required this.rawType,
    required this.baseName,
    required this.isNullable,
    this.typeArguments = const [],
  });

  /// Parses a type string into a [ParsedType].
  factory ParsedType.parse(String typeStr) {
    var trimmed = typeStr.trim();
    if (trimmed.isEmpty || trimmed == 'dynamic') {
      return const ParsedType(
        rawType: 'dynamic',
        baseName: 'dynamic',
        isNullable: true,
      );
    }

    final isNullable = trimmed.endsWith('?');
    if (isNullable) {
      trimmed = trimmed.substring(0, trimmed.length - 1).trim();
    }

    final bracketIdx = trimmed.indexOf('<');
    if (bracketIdx == -1) {
      return ParsedType(
        rawType: typeStr.trim(),
        baseName: trimmed,
        isNullable: isNullable,
        typeArguments: const [],
      );
    }

    final baseName = trimmed.substring(0, bracketIdx).trim();
    final insideBrackets = trimmed
        .substring(bracketIdx + 1, trimmed.lastIndexOf('>'))
        .trim();
    final args = _splitTypeArguments(insideBrackets)
        .map((s) => ParsedType.parse(s))
        .toList();

    return ParsedType(
      rawType: typeStr.trim(),
      baseName: baseName,
      isNullable: isNullable,
      typeArguments: args,
    );
  }

  static List<String> _splitTypeArguments(String str) {
    final result = <String>[];
    var depth = 0;
    var current = StringBuffer();

    for (var i = 0; i < str.length; i++) {
      final char = str[i];
      if (char == '<') {
        depth++;
        current.write(char);
      } else if (char == '>') {
        depth--;
        current.write(char);
      } else if (char == ',' && depth == 0) {
        result.add(current.toString().trim());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    if (current.isNotEmpty) {
      result.add(current.toString().trim());
    }
    return result;
  }

  bool get isPrimitive =>
      baseName == 'int' ||
      baseName == 'double' ||
      baseName == 'num' ||
      baseName == 'String' ||
      baseName == 'bool' ||
      baseName == 'dynamic' ||
      baseName == 'Object';

  bool get isInt => baseName == 'int';
  bool get isDouble => baseName == 'double';
  bool get isNum => baseName == 'num';
  bool get isString => baseName == 'String';
  bool get isBool => baseName == 'bool';
  bool get isDynamic => baseName == 'dynamic';
  bool get isObject => baseName == 'Object';

  bool get isDateTime => baseName == 'DateTime';
  bool get isUri => baseName == 'Uri';
  bool get isBigInt => baseName == 'BigInt';
  bool get isDuration => baseName == 'Duration';

  bool get isOption => baseName == 'Option';
  bool get isQueryMap => baseName == 'QueryMap';

  bool get isList => baseName == 'List';
  bool get isSet => baseName == 'Set';
  bool get isMap => baseName == 'Map';

  ParsedType? get singleTypeArgument =>
      typeArguments.isNotEmpty ? typeArguments.first : null;

  @override
  String toString() => rawType;
}
