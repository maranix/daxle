import 'package:analyzer/dart/ast/ast.dart';

import '../../models/annotation_info.dart';
import '../../models/case_style.dart';
import 'annotation_context.dart';
import 'annotation_handler.dart';

/// Handler for `@Serialize`.
final class SerializeAnnotationHandler implements AnnotationHandler<SerializeInfo> {
  const SerializeAnnotationHandler();

  @override
  List<String> get supportedNames => const [
    'Serialize',
    'serialize',
  ];

  @override
  SerializeInfo parse(AnnotationContext context) {
    String? discriminator;
    String? valueField;
    CaseStyle? caseStyle;
    var ignoreFields = <String>{};

    if (context.arguments case final ArgumentList args) {
      for (final arg in args.arguments) {
        if (arg case NamedArgument(:final name, :final argumentExpression)) {
          switch (name.lexeme) {
            case 'discriminator':
              discriminator = AstArgumentHelper.extractString(argumentExpression);
            case 'valueField':
              valueField = AstArgumentHelper.extractString(argumentExpression);
            case 'caseStyle':
              caseStyle = AstArgumentHelper.extractCaseStyle(argumentExpression);
            case 'ignoreFields':
              ignoreFields = AstArgumentHelper.extractStringSet(argumentExpression);
          }
        }
      }
    }

    return SerializeInfo(
      discriminator: discriminator,
      valueField: valueField,
      caseStyle: caseStyle,
      ignoreFields: ignoreFields,
    );
  }
}

/// Handler for `@Deserialize`.
final class DeserializeAnnotationHandler
    implements AnnotationHandler<DeserializeInfo> {
  const DeserializeAnnotationHandler();

  @override
  List<String> get supportedNames => const [
    'Deserialize',
    'deserialize',
  ];

  @override
  DeserializeInfo parse(AnnotationContext context) {
    String? discriminator;
    String? valueField;
    CaseStyle? caseStyle;
    var ignoreFields = <String>{};

    if (context.arguments case final ArgumentList args) {
      for (final arg in args.arguments) {
        if (arg case NamedArgument(:final name, :final argumentExpression)) {
          switch (name.lexeme) {
            case 'discriminator':
              discriminator = AstArgumentHelper.extractString(argumentExpression);
            case 'valueField':
              valueField = AstArgumentHelper.extractString(argumentExpression);
            case 'caseStyle':
              caseStyle = AstArgumentHelper.extractCaseStyle(argumentExpression);
            case 'ignoreFields':
              ignoreFields = AstArgumentHelper.extractStringSet(argumentExpression);
          }
        }
      }
    }

    return DeserializeInfo(
      discriminator: discriminator,
      valueField: valueField,
      caseStyle: caseStyle,
      ignoreFields: ignoreFields,
    );
  }
}

/// Handler for `@EqualsAndHashCode`.
final class EqualsAndHashCodeAnnotationHandler
    implements AnnotationHandler<EqualsAndHashCodeInfo> {
  const EqualsAndHashCodeAnnotationHandler();

  @override
  List<String> get supportedNames => const [
    'EqualsAndHashCode',
    'equalsAndHashCode',
  ];

  @override
  EqualsAndHashCodeInfo parse(AnnotationContext context) {
    var ignoreFields = <String>{};

    if (context.arguments case final ArgumentList args) {
      for (final arg in args.arguments) {
        if (arg case NamedArgument(:final name, :final argumentExpression)
            when name.lexeme == 'ignoreFields') {
          ignoreFields = AstArgumentHelper.extractStringSet(argumentExpression);
        }
      }
    }

    return EqualsAndHashCodeInfo(ignoreFields: ignoreFields);
  }
}

/// Handler for `@Stringify`.
final class StringifyAnnotationHandler implements AnnotationHandler<StringifyInfo> {
  const StringifyAnnotationHandler();

  @override
  List<String> get supportedNames => const [
    'Stringify',
    'stringify',
  ];

  @override
  StringifyInfo parse(AnnotationContext context) {
    var ignoreFields = <String>{};

    if (context.arguments case final ArgumentList args) {
      for (final arg in args.arguments) {
        if (arg case NamedArgument(:final name, :final argumentExpression)
            when name.lexeme == 'ignoreFields') {
          ignoreFields = AstArgumentHelper.extractStringSet(argumentExpression);
        }
      }
    }

    return StringifyInfo(ignoreFields: ignoreFields);
  }
}

/// Handler for `@CopyWith`.
final class CopyWithAnnotationHandler implements AnnotationHandler<CopyWithInfo> {
  const CopyWithAnnotationHandler();

  @override
  List<String> get supportedNames => const [
    'CopyWith',
    'copyWith',
  ];

  @override
  CopyWithInfo parse(AnnotationContext context) {
    var ignoreFields = <String>{};

    if (context.arguments case final ArgumentList args) {
      for (final arg in args.arguments) {
        if (arg case NamedArgument(:final name, :final argumentExpression)
            when name.lexeme == 'ignoreFields') {
          ignoreFields = AstArgumentHelper.extractStringSet(argumentExpression);
        }
      }
    }

    return CopyWithInfo(ignoreFields: ignoreFields);
  }
}
