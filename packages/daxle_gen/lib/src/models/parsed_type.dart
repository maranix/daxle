/// Represents a field in a record type.
class ParsedRecordField {
  final String? name;
  final ParsedType type;
  final bool isNamed;
  final int position; // 1-indexed for positional fields ($1, $2, ...)
  final String? serializedKey;

  const ParsedRecordField({
    this.name,
    required this.type,
    required this.isNamed,
    required this.position,
    this.serializedKey,
  });

  String get effectiveKey => serializedKey ?? name ?? '\$$position';
  String get memberAccess => isNamed ? name! : '\$$position';
}

/// Descriptor for a parsed Dart type.
class ParsedType {
  final String rawType;
  final String baseName;
  final bool isNullable;
  final List<ParsedType> typeArguments;
  final List<ParsedRecordField> recordFields;

  const ParsedType({
    required this.rawType,
    required this.baseName,
    required this.isNullable,
    this.typeArguments = const [],
    this.recordFields = const [],
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

    // Check for record type: starts with '(' and ends with ')'
    if (trimmed.startsWith('(') && trimmed.endsWith(')')) {
      final inside = trimmed.substring(1, trimmed.length - 1).trim();
      final recordFields = _parseRecordFields(inside);
      return ParsedType(
        rawType: typeStr.trim(),
        baseName: trimmed,
        isNullable: isNullable,
        typeArguments: const [],
        recordFields: recordFields,
      );
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

  static List<ParsedRecordField> _parseRecordFields(String inside) {
    if (inside.trim().isEmpty) return const [];
    final fields = <ParsedRecordField>[];
    final parts = _splitTypeArguments(inside);
    var posIndex = 1;

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        // Named fields block: {Type1 name1, Type2 name2}
        final namedInside = trimmed.substring(1, trimmed.length - 1).trim();
        final namedParts = _splitTypeArguments(namedInside);
        for (final namedPart in namedParts) {
          final npTrimmed = namedPart.trim();
          if (npTrimmed.isEmpty) continue;
          final lastSpace = _findLastSpaceAtDepthZero(npTrimmed);
          if (lastSpace != -1) {
            final typeStr = npTrimmed.substring(0, lastSpace).trim();
            final nameStr = npTrimmed.substring(lastSpace + 1).trim();
            fields.add(
              ParsedRecordField(
                name: nameStr,
                type: ParsedType.parse(typeStr),
                isNamed: true,
                position: posIndex++,
              ),
            );
          } else {
            fields.add(
              ParsedRecordField(
                name: npTrimmed,
                type: const ParsedType(
                  rawType: 'dynamic',
                  baseName: 'dynamic',
                  isNullable: true,
                ),
                isNamed: true,
                position: posIndex++,
              ),
            );
          }
        }
      } else {
        // Positional field, may optionally have documentation name: Type name or just Type
        final lastSpace = _findLastSpaceAtDepthZero(trimmed);
        if (lastSpace != -1) {
          final potentialType = trimmed.substring(0, lastSpace).trim();
          final potentialName = trimmed.substring(lastSpace + 1).trim();
          // If potentialType is a valid type (e.g. not starting with special punctuation)
          fields.add(
            ParsedRecordField(
              name: potentialName,
              type: ParsedType.parse(potentialType),
              isNamed: false,
              position: posIndex++,
            ),
          );
        } else {
          fields.add(
            ParsedRecordField(
              name: null,
              type: ParsedType.parse(trimmed),
              isNamed: false,
              position: posIndex++,
            ),
          );
        }
      }
    }

    return fields;
  }

  static int _findLastSpaceAtDepthZero(String str) {
    var depth = 0;
    var lastSpace = -1;
    for (var i = 0; i < str.length; i++) {
      final char = str[i];
      if (char == '<' || char == '(' || char == '{' || char == '[') {
        depth++;
      } else if (char == '>' || char == ')' || char == '}' || char == ']') {
        depth--;
      } else if (char == ' ' && depth == 0) {
        lastSpace = i;
      }
    }
    return lastSpace;
  }

  static List<String> _splitTypeArguments(String str) {
    final result = <String>[];
    var depth = 0;
    var current = StringBuffer();

    for (var i = 0; i < str.length; i++) {
      final char = str[i];
      if (char == '<' || char == '(' || char == '{' || char == '[') {
        depth++;
        current.write(char);
      } else if (char == '>' || char == ')' || char == '}' || char == ']') {
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

  bool get isRecord => recordFields.isNotEmpty;
  bool get isRecordNamed => isRecord && recordFields.every((f) => f.isNamed);
  bool get isRecordPositional =>
      isRecord && recordFields.every((f) => !f.isNamed);
  bool get isRecordMixed => isRecord && !isRecordNamed && !isRecordPositional;

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

