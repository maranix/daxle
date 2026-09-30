import 'package:analyzer/dart/ast/ast.dart';

import '../../models/case_style.dart';

/// Context passed to annotation parsers.
typedef AnnotationContext = ({
  String name,
  ArgumentList? arguments,
  String memberName,
});

/// Shared AST argument helper utilities using modern Dart pattern matching.
abstract final class AstArgumentHelper {
  /// Extracts string value from a string literal or interpolation.
  static String? extractString(Expression expr) => switch (expr) {
    SimpleStringLiteral(:final value) => value,
    StringInterpolation() => expr.toSource(),
    _ => null,
  };

  /// Extracts list of strings from a list literal.
  static List<String> extractStringList(Expression expr) {
    if (expr case ListLiteral(:final elements)) {
      final result = <String>[];
      for (final elem in elements) {
        if (elem is Expression) {
          final str = extractString(elem);
          if (str != null) result.add(str);
        }
      }
      return result;
    }
    return const [];
  }

  /// Extracts set of strings from a list or set literal.
  static Set<String> extractStringSet(Expression expr) {
    final elements = switch (expr) {
      ListLiteral(:final elements) => elements,
      SetOrMapLiteral(:final elements) => elements,
      _ => const <CollectionElement>[],
    };
    final result = <String>{};
    for (final elem in elements) {
      if (elem is Expression) {
        final str = extractString(elem);
        if (str != null) result.add(str);
      }
    }
    return result;
  }

  /// Extracts [CaseStyle] enum value from an expression.
  static CaseStyle? extractCaseStyle(Expression expr) {
    final name = expr.toSource().split('.').last;
    for (final style in CaseStyle.values) {
      if (style.name == name) return style;
    }
    return null;
  }
}
