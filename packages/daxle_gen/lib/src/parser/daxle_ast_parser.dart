import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:daxle/daxle.dart';

import '../models/annotation_info.dart';
import '../models/parsed_element.dart';
import '../models/parsed_type.dart';

/// Parses Dart source files into [ParsedFile] structures using analyzer AST.
class DaxleAstParser {
  const DaxleAstParser();

  /// Parses a file at [filePath].
  ParsedFile parse(String filePath) {
    final result = parseFile(
      path: filePath,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    return parseUnit(result.unit, filePath: filePath, fileName: fileName);
  }

  /// Parses Dart code string.
  ParsedFile parseContent(String content, {String filePath = 'source.dart'}) {
    final result = parseString(
      content: content,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    );
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    return parseUnit(result.unit, filePath: filePath, fileName: fileName);
  }

  /// Parses a [CompilationUnit] directly.
  ParsedFile parseUnit(
    CompilationUnit unit, {
    required String filePath,
    required String fileName,
  }) {
    final classes = <ParsedClass>[];
    final enums = <ParsedEnum>[];
    final partDirectives = <String>[];

    for (final directive in unit.directives) {
      if (directive is PartDirective) {
        partDirectives.add(directive.uri.stringValue ?? directive.uri.toSource());
      }
    }

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        final parsedClass = _parseClass(declaration);
        classes.add(parsedClass);
      } else if (declaration is EnumDeclaration) {
        final parsedEnum = _parseEnum(declaration);
        enums.add(parsedEnum);
      }
    }

    return ParsedFile(
      filePath: filePath,
      fileName: fileName,
      classes: classes,
      enums: enums,
      partDirectives: partDirectives,
    );
  }

  ParsedClass _parseClass(ClassDeclaration declaration) {
    final className = declaration.namePart.typeName.lexeme;
    final isSealed = declaration.sealedKeyword != null;
    final superclass = declaration.extendsClause?.superclass.name.lexeme;

    final interfaces = <String>[];
    if (declaration.implementsClause != null) {
      for (final interface in declaration.implementsClause!.interfaces) {
        interfaces.add(interface.name.lexeme);
      }
    }
    if (declaration.withClause != null) {
      for (final mixinType in declaration.withClause!.mixinTypes) {
        interfaces.add(mixinType.name.lexeme);
      }
    }

    SerializeInfo? serializeInfo;
    DeserializeInfo? deserializeInfo;
    String? customDiscriminatorName;

    for (final annotation in declaration.metadata) {
      final name = _getAnnotationName(annotation);
      if (name == 'Serialize' ||
          name == 'serialize' ||
          name == 'SerializeClass' ||
          name == 'serializeClass') {
        serializeInfo = _parseSerializeAnnotation(annotation);
      } else if (name == 'Deserialize' ||
          name == 'deserialize' ||
          name == 'DeserializeClass' ||
          name == 'deserializeClass') {
        deserializeInfo = _parseDeserializeAnnotation(annotation);
      } else if (name == 'SerializeValue' || name == 'DeserializeValue') {
        final cfg = _parseFieldConfig(declaration.metadata);
        customDiscriminatorName ??=
            cfg.effectiveSerializeKey ?? cfg.effectiveDeserializeKey;
      }
    }

    final fields = <ParsedField>[];
    final constructorParams = <ParsedConstructorParam>[];
    var isPrimaryConstructor = false;
    var constructorName = '';

    // Check for primary constructor
    if (declaration.namePart case PrimaryConstructorDeclaration primary) {
      isPrimaryConstructor = true;
      if (primary.constructorName != null) {
        constructorName = primary.constructorName!.name.lexeme;
      }

      for (final param in primary.formalParameters.parameters) {
        final paramName = param.name?.lexeme ?? '';
        final paramTypeStr = _getParameterTypeString(param);
        final paramType = ParsedType.parse(paramTypeStr);
        final fieldConfig = _parseFieldConfig(param.metadata);
        final defaultVal = _getParameterDefaultValue(param);

        final parsedParam = ParsedConstructorParam(
          name: paramName,
          type: paramType,
          isNamed: param.isNamed,
          isRequired: param.isRequired,
          hasDefault: defaultVal != null,
          defaultValueCode: defaultVal,
          config: fieldConfig,
        );
        constructorParams.add(parsedParam);

        // In primary constructors, parameters are declaring parameters
        fields.add(ParsedField(
          name: paramName,
          type: paramType,
          config: fieldConfig,
          isFinal: true,
          hasDefaultValue: defaultVal != null,
          defaultValueCode: defaultVal,
        ));
      }
    }

    // Inspect class body
    if (declaration.body case BlockClassBody body) {
      // Collect field declarations
      for (final member in body.members) {
        if (member is FieldDeclaration && !member.isStatic) {
          final typeStr = member.fields.type?.toSource() ?? 'dynamic';
          final parsedType = ParsedType.parse(typeStr);
          final fieldAnnotations = _parseFieldConfig(member.metadata);

          for (final variable in member.fields.variables) {
            final varName = variable.name.lexeme;
            final initCode = variable.initializer?.toSource();
            final varAnnotations = _parseFieldConfig(variable.metadata);
            final mergedConfig = fieldAnnotations.merge(varAnnotations);

            // Avoid duplicating if already populated by primary constructor
            if (!fields.any((f) => f.name == varName)) {
              fields.add(ParsedField(
                name: varName,
                type: parsedType,
                config: mergedConfig,
                isFinal: member.fields.isFinal || member.fields.isConst,
                hasDefaultValue: initCode != null,
                defaultValueCode: initCode,
              ));
            }
          }
        }
      }

      // If not primary constructor, look for generative constructor
      if (!isPrimaryConstructor) {
        ConstructorDeclaration? targetConstructor;
        for (final member in body.members) {
          if (member is ConstructorDeclaration && member.factoryKeyword == null) {
            if (member.name == null) {
              targetConstructor = member;
              break;
            } else {
              targetConstructor ??= member;
            }
          }
        }

        if (targetConstructor != null) {
          constructorName = targetConstructor.name?.lexeme ?? '';
          for (final param in targetConstructor.parameters.parameters) {
            final paramName = param.name?.lexeme ?? '';
            var paramTypeStr = _getParameterTypeString(param);

            // If initializing formal `this.fieldName` and type was omitted, look up field type
            if (paramTypeStr == 'dynamic' &&
                (param is FieldFormalParameter ||
                    param.toSource().startsWith('this.'))) {
              final matchedField =
                  fields.where((f) => f.name == paramName).firstOrNull;
              if (matchedField != null) {
                paramTypeStr = matchedField.type.rawType;
              }
            }

            final paramType = ParsedType.parse(paramTypeStr);
            final paramConfig = _parseFieldConfig(param.metadata);
            final defaultVal = _getParameterDefaultValue(param);

            constructorParams.add(ParsedConstructorParam(
              name: paramName,
              type: paramType,
              isNamed: param.isNamed,
              isRequired: param.isRequired,
              hasDefault: defaultVal != null,
              defaultValueCode: defaultVal,
              config: paramConfig,
            ));

            // Merge constructor parameter config into matching field config
            final fieldIndex = fields.indexWhere((f) => f.name == paramName);
            if (fieldIndex != -1) {
              fields[fieldIndex] = ParsedField(
                name: fields[fieldIndex].name,
                type: fields[fieldIndex].type,
                config: fields[fieldIndex].config.merge(paramConfig),
                isFinal: fields[fieldIndex].isFinal,
                hasDefaultValue:
                    fields[fieldIndex].hasDefaultValue || defaultVal != null,
                defaultValueCode:
                    fields[fieldIndex].defaultValueCode ?? defaultVal,
              );
            }
          }
        }
      }
    }

    return ParsedClass(
      name: className,
      isSealed: isSealed,
      superclass: superclass,
      interfaces: interfaces,
      serialize: serializeInfo,
      deserialize: deserializeInfo,
      customDiscriminatorName: customDiscriminatorName,
      fields: fields,
      constructorParams: constructorParams,
      constructorName: constructorName,
      isPrimaryConstructor: isPrimaryConstructor,
    );
  }

  ParsedEnum _parseEnum(EnumDeclaration declaration) {
    final enumName = declaration.namePart.typeName.lexeme;

    SerializeEnumInfo? serializeInfo;
    DeserializeEnumInfo? deserializeInfo;

    for (final annotation in declaration.metadata) {
      final name = _getAnnotationName(annotation);
      if (name == 'SerializeEnum' ||
          name == 'serializeEnum' ||
          name == 'Serialize' ||
          name == 'serialize') {
        serializeInfo = _parseSerializeEnumAnnotation(annotation);
      } else if (name == 'DeserializeEnum' ||
          name == 'deserializeEnum' ||
          name == 'Deserialize' ||
          name == 'deserialize') {
        deserializeInfo = _parseDeserializeEnumAnnotation(annotation);
      }
    }

    final valueFieldName = serializeInfo?.valueField ?? deserializeInfo?.valueField;
    ParsedType? valueFieldType;
    final constants = <ParsedEnumConstant>[];

    if (declaration.body case BlockEnumBody body) {
      // Find value field type if valueFieldName is defined
      if (valueFieldName != null) {
        for (final member in body.members) {
          if (member is FieldDeclaration) {
            for (final variable in member.fields.variables) {
              if (variable.name.lexeme == valueFieldName) {
                final typeStr = member.fields.type?.toSource() ?? 'dynamic';
                valueFieldType = ParsedType.parse(typeStr);
                break;
              }
            }
          }
        }
      }

      int? valueFieldPositionalIndex;
      if (declaration.namePart case PrimaryConstructorDeclaration primary) {
        if (valueFieldName != null) {
          var posIdx = 0;
          for (final param in primary.formalParameters.parameters) {
            final paramName = param.name?.lexeme ?? '';
            if (!param.isNamed) {
              if (paramName == valueFieldName) {
                valueFieldPositionalIndex = posIdx;
                break;
              }
              posIdx++;
            }
          }
        }
      } else {
        ConstructorDeclaration? enumConstructor;
        for (final member in body.members) {
          if (member is ConstructorDeclaration && member.factoryKeyword == null) {
            enumConstructor = member;
            break;
          }
        }

        if (enumConstructor != null && valueFieldName != null) {
          var posIdx = 0;
          for (final param in enumConstructor.parameters.parameters) {
            final paramName = param.name?.lexeme ?? '';
            if (!param.isNamed) {
              if (paramName == valueFieldName) {
                valueFieldPositionalIndex = posIdx;
                break;
              }
              posIdx++;
            }
          }
        }
      }

      for (final constant in body.constants) {
        final constName = constant.name.lexeme;
        String? explicitValCode;

        // Check for @SerializeValue annotation on enum constant
        final config = _parseFieldConfig(constant.metadata);
        if (config.effectiveSerializeKey != null) {
          explicitValCode = "'${config.effectiveSerializeKey}'";
        } else if (config.serializeCaseStyle != null) {
          explicitValCode =
              "'${config.serializeCaseStyle!.transform(constName)}'";
        } else if (valueFieldName != null &&
            constant.arguments != null &&
            constant.arguments!.argumentList.arguments.isNotEmpty) {
          final args = constant.arguments!.argumentList.arguments;
          for (final arg in args) {
            if (arg is NamedArgument && arg.name.lexeme == valueFieldName) {
              explicitValCode = arg.argumentExpression.toSource();
              break;
            }
          }
          if (explicitValCode == null) {
            if (valueFieldPositionalIndex != null &&
                valueFieldPositionalIndex < args.length &&
                args[valueFieldPositionalIndex] is! NamedArgument) {
              explicitValCode = args[valueFieldPositionalIndex].toSource();
            } else {
              explicitValCode = args.first.toSource();
            }
          }
        } else if (serializeInfo?.caseStyle != null) {
          explicitValCode =
              "'${serializeInfo!.caseStyle!.transform(constName)}'";
        }

        constants.add(ParsedEnumConstant(
          name: constName,
          explicitValueCode: explicitValCode,
        ));
      }
    }

    return ParsedEnum(
      name: enumName,
      serialize: serializeInfo,
      deserialize: deserializeInfo,
      valueFieldName: valueFieldName,
      valueFieldType: valueFieldType,
      constants: constants,
    );
  }

  String _getAnnotationName(Annotation annotation) {
    return annotation.name.name.split('.').last;
  }

  SerializeInfo _parseSerializeAnnotation(Annotation annotation) {
    String? discriminator;
    CaseStyle? caseStyle;
    var ignoreFields = <String>{};

    if (annotation.arguments != null) {
      for (final arg in annotation.arguments!.arguments) {
        if (arg is NamedArgument) {
          final argName = arg.name.lexeme;
          if (argName == 'discriminator') {
            discriminator = _extractStringValue(arg.argumentExpression);
          } else if (argName == 'caseStyle') {
            caseStyle = _extractCaseStyle(arg.argumentExpression);
          } else if (argName == 'ignoreFields') {
            ignoreFields = _extractStringSet(arg.argumentExpression);
          }
        }
      }
    }

    return SerializeInfo(
      discriminator: discriminator,
      caseStyle: caseStyle,
      ignoreFields: ignoreFields,
    );
  }

  DeserializeInfo _parseDeserializeAnnotation(Annotation annotation) {
    String? discriminator;
    CaseStyle? caseStyle;
    var ignoreFields = <String>{};

    if (annotation.arguments != null) {
      for (final arg in annotation.arguments!.arguments) {
        if (arg is NamedArgument) {
          final argName = arg.name.lexeme;
          if (argName == 'discriminator') {
            discriminator = _extractStringValue(arg.argumentExpression);
          } else if (argName == 'caseStyle') {
            caseStyle = _extractCaseStyle(arg.argumentExpression);
          } else if (argName == 'ignoreFields') {
            ignoreFields = _extractStringSet(arg.argumentExpression);
          }
        }
      }
    }

    return DeserializeInfo(
      discriminator: discriminator,
      caseStyle: caseStyle,
      ignoreFields: ignoreFields,
    );
  }

  SerializeEnumInfo _parseSerializeEnumAnnotation(Annotation annotation) {
    String? valueField;
    CaseStyle? caseStyle;

    if (annotation.arguments != null) {
      for (final arg in annotation.arguments!.arguments) {
        if (arg is NamedArgument) {
          final argName = arg.name.lexeme;
          if (argName == 'valueField') {
            valueField = _extractStringValue(arg.argumentExpression);
          } else if (argName == 'caseStyle') {
            caseStyle = _extractCaseStyle(arg.argumentExpression);
          }
        }
      }
    }

    return SerializeEnumInfo(
      valueField: valueField,
      caseStyle: caseStyle,
    );
  }

  DeserializeEnumInfo _parseDeserializeEnumAnnotation(Annotation annotation) {
    String? valueField;
    CaseStyle? caseStyle;

    if (annotation.arguments != null) {
      for (final arg in annotation.arguments!.arguments) {
        if (arg is NamedArgument) {
          final argName = arg.name.lexeme;
          if (argName == 'valueField') {
            valueField = _extractStringValue(arg.argumentExpression);
          } else if (argName == 'caseStyle') {
            caseStyle = _extractCaseStyle(arg.argumentExpression);
          }
        }
      }
    }

    return DeserializeEnumInfo(
      valueField: valueField,
      caseStyle: caseStyle,
    );
  }

  FieldConfig _parseFieldConfig(NodeList<Annotation> metadata) {
    String? serializeKey;
    String? deserializeKey;
    CaseStyle? serializeCaseStyle;
    CaseStyle? deserializeCaseStyle;
    String? defaultValueCode;
    String? serializeDefaultValueCode;
    String? converterCode;
    String? serializeConverterCode;
    var ignoreSerialize = false;
    var ignoreDeserialize = false;

    for (final annotation in metadata) {
      final annotName = _getAnnotationName(annotation);
      final isSerializeVal = annotName == 'SerializeValue';
      final isDeserializeVal = annotName == 'DeserializeValue';

      if (isSerializeVal || isDeserializeVal) {
        if (annotation.arguments != null) {
          for (final arg in annotation.arguments!.arguments) {
            if (arg is NamedArgument) {
              final argName = arg.name.lexeme;
              if (argName == 'name') {
                final strVal = _extractStringValue(arg.argumentExpression);
                if (isSerializeVal) serializeKey = strVal;
                if (isDeserializeVal) deserializeKey = strVal;
              } else if (argName == 'caseStyle') {
                final style = _extractCaseStyle(arg.argumentExpression);
                if (isSerializeVal) serializeCaseStyle = style;
                if (isDeserializeVal) deserializeCaseStyle = style;
              } else if (argName == 'defaultValue') {
                final code = arg.argumentExpression.toSource();
                if (isDeserializeVal) defaultValueCode = code;
                if (isSerializeVal) serializeDefaultValueCode = code;
              } else if (argName == 'converter') {
                final code = arg.argumentExpression.toSource();
                if (isDeserializeVal) converterCode = code;
                if (isSerializeVal) serializeConverterCode = code;
              } else if (argName == 'ignore') {
                final isTrue = arg.argumentExpression.toSource() == 'true';
                if (isSerializeVal && isTrue) ignoreSerialize = true;
                if (isDeserializeVal && isTrue) ignoreDeserialize = true;
              }
            }
          }
        }
      }
    }

    return FieldConfig(
      serializeKey: serializeKey,
      deserializeKey: deserializeKey,
      serializeCaseStyle: serializeCaseStyle,
      deserializeCaseStyle: deserializeCaseStyle,
      defaultValueCode: defaultValueCode,
      serializeDefaultValueCode: serializeDefaultValueCode,
      converterCode: converterCode,
      serializeConverterCode: serializeConverterCode,
      ignoreSerialize: ignoreSerialize,
      ignoreDeserialize: ignoreDeserialize,
    );
  }

  CaseStyle? _extractCaseStyle(Expression expr) {
    final source = expr.toSource();
    final name = source.split('.').last;
    for (final style in CaseStyle.values) {
      if (style.name == name) return style;
    }
    return null;
  }

  Set<String> _extractStringSet(Expression expr) {
    final result = <String>{};
    if (expr is ListLiteral) {
      for (final elem in expr.elements) {
        if (elem is Expression) {
          final str = _extractStringValue(elem);
          if (str != null) result.add(str);
        }
      }
    } else if (expr is SetOrMapLiteral) {
      for (final elem in expr.elements) {
        if (elem is Expression) {
          final str = _extractStringValue(elem);
          if (str != null) result.add(str);
        }
      }
    }
    return result;
  }

  String? _extractStringValue(Expression expr) {
    if (expr is SimpleStringLiteral) {
      return expr.value;
    } else if (expr is StringInterpolation) {
      return expr.toSource();
    }
    return null;
  }

  String _getParameterTypeString(FormalParameter param) {
    return param.type?.toSource() ?? 'dynamic';
  }

  String? _getParameterDefaultValue(FormalParameter param) {
    return param.defaultClause?.value.toSource();
  }
}
