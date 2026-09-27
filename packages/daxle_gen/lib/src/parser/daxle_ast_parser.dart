import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:daxle/daxle.dart';

import '../models/annotation_info.dart';
import '../models/parsed_element.dart';
import '../models/parsed_type.dart';
import 'generation_error.dart';

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
        partDirectives.add(
          directive.uri.stringValue ?? directive.uri.toSource(),
        );
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
    EqualsAndHashCodeInfo? equalsAndHashCodeInfo;
    StringifyInfo? stringifyInfo;
    CopyWithInfo? copyWithInfo;
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
      } else if (name == 'EqualsAndHashCode' || name == 'equalsAndHashCode') {
        equalsAndHashCodeInfo = _parseEqualsAndHashCodeAnnotation(annotation);
      } else if (name == 'Stringify' || name == 'stringify') {
        stringifyInfo = _parseStringifyAnnotation(annotation);
      } else if (name == 'CopyWith' || name == 'copyWith') {
        copyWithInfo = _parseCopyWithAnnotation(annotation);
      } else if (name == 'SerializedValue' ||
          name == 'SerializeValue' ||
          name == 'DeserializeValue') {
        final cfg = _parseFieldConfig(
          declaration.metadata,
          memberName: className,
        );
        customDiscriminatorName ??= cfg.serializedKey;
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
        final fieldConfig = _parseFieldConfig(
          param.metadata,
          memberName: paramName,
        );
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
        fields.add(
          ParsedField(
            name: paramName,
            type: paramType,
            config: fieldConfig,
            isFinal: true,
            hasDefaultValue: defaultVal != null,
            defaultValueCode: defaultVal,
          ),
        );
      }
    }

    // Inspect class body
    if (declaration.body case BlockClassBody body) {
      // Collect field declarations
      for (final member in body.members) {
        if (member is FieldDeclaration && !member.isStatic) {
          final typeStr = member.fields.type?.toSource() ?? 'dynamic';
          final parsedType = ParsedType.parse(typeStr);
          final fieldAnnotations = _parseFieldConfig(
            member.metadata,
            memberName: 'field',
          );

          for (final variable in member.fields.variables) {
            final varName = variable.name.lexeme;
            final initCode = variable.initializer?.toSource();
            final varAnnotations = _parseFieldConfig(
              variable.metadata,
              memberName: varName,
            );
            final mergedConfig = fieldAnnotations.merge(
              varAnnotations,
              varName,
            );

            // Avoid duplicating if already populated by primary constructor
            if (!fields.any((f) => f.name == varName)) {
              fields.add(
                ParsedField(
                  name: varName,
                  type: parsedType,
                  config: mergedConfig,
                  isFinal: member.fields.isFinal || member.fields.isConst,
                  hasDefaultValue: initCode != null,
                  defaultValueCode: initCode,
                ),
              );
            }
          }
        }
      }

      // If not primary constructor, look for generative constructor
      if (!isPrimaryConstructor) {
        ConstructorDeclaration? targetConstructor;
        for (final member in body.members) {
          if (member is ConstructorDeclaration &&
              member.factoryKeyword == null) {
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

            final matchedField = fields
                .where((f) => f.name == paramName)
                .firstOrNull;
            if (paramTypeStr == 'dynamic' &&
                (param is FieldFormalParameter ||
                    param.toSource().startsWith('this.'))) {
              if (matchedField != null) {
                paramTypeStr = matchedField.type.rawType;
              }
            }

            final paramType = ParsedType.parse(paramTypeStr);
            final paramConfig = _parseFieldConfig(
              param.metadata,
              memberName: paramName,
            );
            final defaultVal = _getParameterDefaultValue(param);

            final effectiveConfig = matchedField != null
                ? matchedField.config.merge(paramConfig, paramName)
                : paramConfig;

            constructorParams.add(
              ParsedConstructorParam(
                name: paramName,
                type: paramType,
                isNamed: param.isNamed,
                isRequired: param.isRequired,
                hasDefault: defaultVal != null,
                defaultValueCode: defaultVal,
                config: effectiveConfig,
              ),
            );

            // Merge constructor parameter config into matching field config
            final fieldIndex = fields.indexWhere((f) => f.name == paramName);
            if (fieldIndex != -1) {
              fields[fieldIndex] = ParsedField(
                name: fields[fieldIndex].name,
                type: fields[fieldIndex].type,
                config: effectiveConfig,
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
      equalsAndHashCode: equalsAndHashCodeInfo,
      stringify: stringifyInfo,
      copyWith: copyWithInfo,
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
    StringifyInfo? stringifyInfo;
    String? fallbackCaseCode;

    for (final annotation in declaration.metadata) {
      final name = _getAnnotationName(annotation);
      if (name == 'EqualsAndHashCode' || name == 'equalsAndHashCode') {
        throw UnsupportedError(
          'Enums do not support @EqualsAndHashCode (found on enum $enumName)',
        );
      } else if (name == 'CopyWith' || name == 'copyWith') {
        throw UnsupportedError(
          'Enums do not support @CopyWith (found on enum $enumName)',
        );
      } else if (name == 'Stringify' || name == 'stringify') {
        stringifyInfo = _parseStringifyAnnotation(annotation);
      } else if (name == 'SerializeEnum' ||
          name == 'serializeEnum' ||
          name == 'Serialize' ||
          name == 'serialize') {
        serializeInfo = _parseSerializeEnumAnnotation(annotation);
      } else if (name == 'DeserializeEnum' ||
          name == 'deserializeEnum' ||
          name == 'Deserialize' ||
          name == 'deserialize') {
        deserializeInfo = _parseDeserializeEnumAnnotation(annotation);
      } else if (name == 'Fallback') {
        if (annotation.arguments != null &&
            annotation.arguments!.arguments.isNotEmpty) {
          final arg = annotation.arguments!.arguments.first;
          if (arg is NamedArgument) {
            fallbackCaseCode = arg.argumentExpression.toSource();
          } else {
            fallbackCaseCode = arg.toSource();
          }
        }
      }
    }

    final valueFieldName =
        serializeInfo?.valueField ?? deserializeInfo?.valueField;
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
          if (member is ConstructorDeclaration &&
              member.factoryKeyword == null) {
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

        // Check for annotations on enum constant
        final config = _parseFieldConfig(
          constant.metadata,
          memberName: constName,
        );
        if (config.effectiveSerializeKey != null) {
          explicitValCode = "'${config.effectiveSerializeKey}'";
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

        constants.add(
          ParsedEnumConstant(
            name: constName,
            explicitValueCode: explicitValCode,
            config: config,
          ),
        );
      }
    }

    return ParsedEnum(
      name: enumName,
      serialize: serializeInfo,
      deserialize: deserializeInfo,
      stringify: stringifyInfo,
      valueFieldName: valueFieldName,
      valueFieldType: valueFieldType,
      constants: constants,
      fallbackCaseCode: fallbackCaseCode,
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

  EqualsAndHashCodeInfo _parseEqualsAndHashCodeAnnotation(
    Annotation annotation,
  ) {
    var ignoreFields = <String>{};
    if (annotation.arguments != null) {
      for (final arg in annotation.arguments!.arguments) {
        if (arg is NamedArgument && arg.name.lexeme == 'ignoreFields') {
          ignoreFields = _extractStringSet(arg.argumentExpression);
        }
      }
    }
    return EqualsAndHashCodeInfo(ignoreFields: ignoreFields);
  }

  StringifyInfo _parseStringifyAnnotation(Annotation annotation) {
    var ignoreFields = <String>{};
    if (annotation.arguments != null) {
      for (final arg in annotation.arguments!.arguments) {
        if (arg is NamedArgument && arg.name.lexeme == 'ignoreFields') {
          ignoreFields = _extractStringSet(arg.argumentExpression);
        }
      }
    }
    return StringifyInfo(ignoreFields: ignoreFields);
  }

  CopyWithInfo _parseCopyWithAnnotation(Annotation annotation) {
    var ignoreFields = <String>{};
    if (annotation.arguments != null) {
      for (final arg in annotation.arguments!.arguments) {
        if (arg is NamedArgument && arg.name.lexeme == 'ignoreFields') {
          ignoreFields = _extractStringSet(arg.argumentExpression);
        }
      }
    }
    return CopyWithInfo(ignoreFields: ignoreFields);
  }

  FieldConfig _parseFieldConfig(
    NodeList<Annotation> metadata, {
    String memberName = 'member',
  }) {
    String? serializedKey;
    String? fallbackCode;
    String? converterCode;
    var isIgnored = false;
    var hasSerializedValue = false;
    var hasFallback = false;

    for (final annotation in metadata) {
      final annotName = _getAnnotationName(annotation);
      if (annotName == 'ignore' || annotName == 'Ignore') {
        isIgnored = true;
      } else if (annotName == 'SerializedValue' ||
          annotName == 'SerializeValue' ||
          annotName == 'DeserializeValue') {
        hasSerializedValue = true;
        if (annotation.arguments != null) {
          for (final arg in annotation.arguments!.arguments) {
            if (arg is NamedArgument) {
              final argName = arg.name.lexeme;
              if (argName == 'value' || argName == 'name') {
                final strVal = _extractStringValue(arg.argumentExpression);
                serializedKey = strVal ?? arg.argumentExpression.toSource();
              } else if (argName == 'converter') {
                converterCode = arg.argumentExpression.toSource();
              }
            } else if (arg is Expression) {
              final strVal = _extractStringValue(arg);
              serializedKey = strVal ?? arg.toSource();
            } else {
              serializedKey = arg.toSource();
            }
          }
        }
      } else if (annotName == 'Fallback') {
        hasFallback = true;
        if (annotation.arguments != null) {
          for (final arg in annotation.arguments!.arguments) {
            if (arg is NamedArgument) {
              final argName = arg.name.lexeme;
              if (argName == 'value' || argName == 'fallback') {
                fallbackCode = arg.argumentExpression.toSource();
              }
            } else {
              fallbackCode = arg.toSource();
            }
          }
        }
      }
    }

    if (isIgnored && (hasSerializedValue || hasFallback)) {
      throw InvalidGenerationSourceError(
        '@ignore cannot coexist with @SerializedValue or @Fallback on "$memberName".',
        todo:
            'Remove either @ignore or @SerializedValue/@Fallback from "$memberName".',
      );
    }

    return FieldConfig(
      serializedKey: serializedKey,
      fallbackCode: fallbackCode,
      converterCode: converterCode,
      isIgnored: isIgnored,
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
