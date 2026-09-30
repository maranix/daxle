import 'package:analyzer/dart/ast/ast.dart';

import 'annotation_context.dart';
import 'annotation_handler.dart';

/// Parsed data from `@SerializedValue`.
typedef SerializedValueData = ({
  String? serializedKey,
  List<String> aliases,
  String? converterCode,
});

/// Handler for `@SerializedValue`.
final class SerializedValueAnnotationHandler
    implements AnnotationHandler<SerializedValueData> {
  const SerializedValueAnnotationHandler();

  @override
  List<String> get supportedNames => const ['SerializedValue'];

  @override
  SerializedValueData parse(AnnotationContext context) {
    String? serializedKey;
    var aliases = <String>[];
    String? converterCode;

    if (context.arguments case final ArgumentList args) {
      for (final arg in args.arguments) {
        if (arg case NamedArgument(:final name, :final argumentExpression)) {
          switch (name.lexeme) {
            case 'value' || 'name':
              final strVal = AstArgumentHelper.extractString(argumentExpression);
              serializedKey = strVal ?? argumentExpression.toSource();
            case 'aliases':
              aliases = AstArgumentHelper.extractStringList(argumentExpression);
            case 'converter':
              converterCode = argumentExpression.toSource();
          }
        } else if (arg case Expression expr) {
          final strVal = AstArgumentHelper.extractString(expr);
          serializedKey = strVal ?? expr.toSource();
        } else {
          serializedKey = arg.toSource();
        }
      }
    }

    return (
      serializedKey: serializedKey,
      aliases: aliases,
      converterCode: converterCode,
    );
  }
}

/// Handler for `@Fallback`.
final class FallbackAnnotationHandler
    implements AnnotationHandler<String?> {
  const FallbackAnnotationHandler();

  @override
  List<String> get supportedNames => const ['Fallback'];

  @override
  String? parse(AnnotationContext context) {
    if (context.arguments case final ArgumentList args) {
      for (final arg in args.arguments) {
        if (arg case NamedArgument(:final name, :final argumentExpression)) {
          if (name.lexeme == 'value' || name.lexeme == 'fallback') {
            return argumentExpression.toSource();
          }
        } else {
          return arg.toSource();
        }
      }
    }
    return null;
  }
}

/// Handler for `@Flatten`.
final class FlattenAnnotationHandler
    implements AnnotationHandler<String> {
  const FlattenAnnotationHandler();

  @override
  List<String> get supportedNames => const ['Flatten', 'flatten'];

  @override
  String parse(AnnotationContext context) {
    var prefix = '';
    if (context.arguments case final ArgumentList args) {
      for (final arg in args.arguments) {
        if (arg case NamedArgument(:final name, :final argumentExpression)
            when name.lexeme == 'prefix') {
          prefix = AstArgumentHelper.extractString(argumentExpression) ?? '';
        } else if (arg case Expression expr) {
          prefix = AstArgumentHelper.extractString(expr) ?? '';
        }
      }
    }
    return prefix;
  }
}

/// Handler for `@Ignore`.
final class IgnoreAnnotationHandler
    implements AnnotationHandler<bool> {
  const IgnoreAnnotationHandler();

  @override
  List<String> get supportedNames => const ['Ignore', 'ignore'];

  @override
  bool parse(AnnotationContext context) => true;
}
