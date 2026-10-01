import 'package:analyzer/dart/ast/ast.dart';

import '../../models/annotation_info.dart';
import '../../models/case_style.dart';
import '../../models/state_machine_info.dart';
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

/// Handler for `@StateMachine`.
final class StateMachineAnnotationHandler
    implements AnnotationHandler<StateMachineInfo> {
  const StateMachineAnnotationHandler();

  @override
  List<String> get supportedNames => const [
    'StateMachine',
    'stateMachine',
  ];

  @override
  StateMachineInfo parse(AnnotationContext context) {
    final flows = <ParsedFlow>[];

    if (context.arguments case final ArgumentList args) {
      if (args.arguments.isNotEmpty) {
        final firstArg = args.arguments.first;
        final listLiteral = switch (firstArg) {
          NamedArgument(:final argumentExpression) =>
            argumentExpression is ListLiteral ? argumentExpression : null,
          ListLiteral() => firstArg,
          _ => null,
        };

        if (listLiteral != null) {
          for (final elem in listLiteral.elements) {
            if (elem is Expression) {
              final parsed = _parseFlow(elem);
              if (parsed != null) {
                flows.add(parsed);
              }
            }
          }
        }
      }
    }

    return StateMachineInfo(flows: flows);
  }

  ParsedFlow? _parseFlow(Expression expr) {
    ArgumentList? argList;
    if (expr case MethodInvocation(:final methodName, :final argumentList)
        when methodName.name == 'Flow') {
      argList = argumentList;
    } else if (expr
        case InstanceCreationExpression(
          :final constructorName,
          :final argumentList,
        )) {
      final name = constructorName.type.toSource().split('.').last;
      if (name == 'Flow') {
        argList = argumentList;
      }
    }

    if (argList == null) return null;

    String? from;
    String? to;
    String? using;

    for (final arg in argList.arguments) {
      if (arg case NamedArgument(:final name, :final argumentExpression)) {
        switch (name.lexeme) {
          case 'from':
            from = _extractIdentifier(argumentExpression);
          case 'to':
            to = _extractIdentifier(argumentExpression);
          case 'using':
            using = _extractIdentifier(argumentExpression);
        }
      }
    }

    if (from != null && to != null) {
      return ParsedFlow(from: from, to: to, using: using);
    }
    return null;
  }

  String _extractIdentifier(Expression expr) {
    if (expr case Identifier(:final name)) return name;
    return expr.toSource();
  }
}

