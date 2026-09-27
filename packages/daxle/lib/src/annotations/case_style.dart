/// Defines case conversion styles for field and enum serialization.
enum CaseStyle {
  /// Preserves the original identifier case without transformation.
  none,

  /// Converts to camelCase (e.g. `userId`, `createdAt`).
  camelCase,

  /// Converts to snake_case (e.g. `user_id`, `created_at`).
  snakeCase,

  /// Converts to kebab-case (e.g. `user-id`, `created-at`).
  kebabCase,

  /// Converts to PascalCase (e.g. `UserId`, `CreatedAt`).
  pascalCase,

  /// Converts to SCREAMING_SNAKE_CASE (e.g. `USER_ID`, `CREATED_AT`).
  screamingSnakeCase,

  /// Converts to lowercase (e.g. `userid`, `createdat`).
  lowerCase,

  /// Converts to UPPERCASE (e.g. `USERID`, `CREATEDAT`).
  upperCase;

  /// Transforms the given [input] string according to this case style.
  String transform(String input) {
    if (this == CaseStyle.none || input.isEmpty) return input;

    final words = _splitWords(input);
    if (words.isEmpty) return input;

    switch (this) {
      case CaseStyle.none:
        return input;
      case CaseStyle.snakeCase:
        return words.map((w) => w.toLowerCase()).join('_');
      case CaseStyle.kebabCase:
        return words.map((w) => w.toLowerCase()).join('-');
      case CaseStyle.screamingSnakeCase:
        return words.map((w) => w.toUpperCase()).join('_');
      case CaseStyle.lowerCase:
        return words.map((w) => w.toLowerCase()).join();
      case CaseStyle.upperCase:
        return words.map((w) => w.toUpperCase()).join();
      case CaseStyle.pascalCase:
        return words
            .map((w) => w.isEmpty
                ? ''
                : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
            .join();
      case CaseStyle.camelCase:
        final buffer = StringBuffer(words.first.toLowerCase());
        for (var i = 1; i < words.length; i++) {
          final w = words[i];
          if (w.isNotEmpty) {
            buffer.write('${w[0].toUpperCase()}${w.substring(1).toLowerCase()}');
          }
        }
        return buffer.toString();
    }
  }

  static List<String> _splitWords(String input) {
    final result = <String>[];
    final regex =
        RegExp(r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|[\s_\-]+');
    final segments = input.split(regex);
    for (final seg in segments) {
      final trimmed = seg.trim();
      if (trimmed.isNotEmpty) {
        result.add(trimmed);
      }
    }
    return result;
  }
}
