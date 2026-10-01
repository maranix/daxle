import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../models/annotation_info.dart';
import '../models/parsed_element.dart';
import '../models/parsed_type.dart';
import 'annotations/annotation_registry.dart';
import 'annotations/member_annotation_handlers.dart';
import 'generation_error.dart';

/// AST visitor that parses Dart syntax trees into [ParsedFile] structures.
final class DaxleFileVisitor extends RecursiveAstVisitor<void> {
  final String filePath;
  final String fileName;
  final AnnotationRegistry registry;
  final Map<String, List<BundledAnnotation>> bundleMap;

  final List<ParsedClass> classes = [];
  final List<ParsedEnum> enums = [];
  final List<ParsedExtensionType> extensionTypes = [];
  final List<ParsedRecordAlias> recordAliases = [];
  final List<String> partDirectives = [];
  String? partOfPath;

  DaxleFileVisitor(
    this.filePath,
    this.fileName, {
    Map<String, List<BundledAnnotation>> externalBundleMap = const {},
    AnnotationRegistry? registry,
  })  : registry = registry ?? AnnotationRegistry(),
        bundleMap = Map.from(externalBundleMap);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    for (final directive in node.directives) {
      directive.accept(this);
    }

    // Pass 1: Extract AnnotationBundle constants so they can be expanded
    for (final declaration in node.declarations) {
      if (declaration is TopLevelVariableDeclaration) {
        declaration.accept(this);
      }
    }

    // Pass 2: Visit classes, enums, and extension types
    for (final declaration in node.declarations) {
      if (declaration is! TopLevelVariableDeclaration) {
        declaration.accept(this);
      }
    }

    _validateRootAnnotations();
  }

  @override
  void visitPartDirective(PartDirective node) {
    partDirectives.add(node.uri.stringValue ?? node.uri.toSource());
  }

  @override
  void visitPartOfDirective(PartOfDirective node) {
    partOfPath = node.uri?.stringValue;
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      ArgumentList? arguments;

      if (variable.initializer case MethodInvocation(
        methodName: Identifier(name: 'AnnotationBundle'),
        argumentList: final args,
      )) {
        arguments = args;
      } else if (variable.initializer case InstanceCreationExpression(
        constructorName: final ctor,
        argumentList: final args,
      ) when ctor.type.toSource().split('.').last == 'AnnotationBundle') {
        arguments = args;
      }

      if (arguments != null &&
          arguments.arguments.isNotEmpty &&
          arguments.arguments.first is ListLiteral) {
        final elems = (arguments.arguments.first as ListLiteral).elements;
        final constituents = <BundledAnnotation>[];

        for (final e in elems) {
          if (e case MethodInvocation(:final methodName, :final argumentList)) {
            constituents.add(
              BundledAnnotation(methodName.name, argumentList),
            );
          } else if (e case InstanceCreationExpression(:final constructorName, :final argumentList)) {
            final ctorName = constructorName.type.toSource().split('.').last;
            constituents.add(
              BundledAnnotation(ctorName, argumentList),
            );
          } else if (e case SimpleIdentifier(:final name)) {
            constituents.add(BundledAnnotation(name, null));
          } else if (e case PrefixedIdentifier(:final identifier)) {
            constituents.add(BundledAnnotation(identifier.name, null));
          }
        }

        bundleMap[variable.name.lexeme] = constituents;
      }
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final className = node.namePart.typeName.lexeme;
    final isSealed = node.sealedKeyword != null;
    final superclass = node.extendsClause?.superclass.name.lexeme;

    final interfaces = <String>[
      if (node.implementsClause != null)
        for (final interface in node.implementsClause!.interfaces)
          interface.name.lexeme,
      if (node.withClause != null)
        for (final mixinType in node.withClause!.mixinTypes)
          mixinType.name.lexeme,
    ];

    SerializeInfo? serializeInfo;
    DeserializeInfo? deserializeInfo;
    EqualsAndHashCodeInfo? equalsAndHashCodeInfo;
    StringifyInfo? stringifyInfo;
    CopyWithInfo? copyWithInfo;
    String? customDiscriminatorName;

    for (final (name, arguments) in registry.resolveAnnotations(
      node.metadata,
      bundleMap,
    )) {
      switch (name) {
        case 'Serialize' || 'serialize':
          serializeInfo = registry.parseAnnotation<SerializeInfo>(
            name: name,
            arguments: arguments,
            memberName: className,
          );
        case 'Deserialize' || 'deserialize':
          deserializeInfo = registry.parseAnnotation<DeserializeInfo>(
            name: name,
            arguments: arguments,
            memberName: className,
          );
        case 'EqualsAndHashCode' || 'equalsAndHashCode':
          equalsAndHashCodeInfo = registry.parseAnnotation<EqualsAndHashCodeInfo>(
            name: name,
            arguments: arguments,
            memberName: className,
          );
        case 'Stringify' || 'stringify':
          stringifyInfo = registry.parseAnnotation<StringifyInfo>(
            name: name,
            arguments: arguments,
            memberName: className,
          );
        case 'CopyWith' || 'copyWith':
          copyWithInfo = registry.parseAnnotation<CopyWithInfo>(
            name: name,
            arguments: arguments,
            memberName: className,
          );
        case 'SerializedValue':
          final cfg = registry.parseFieldConfig(
            node.metadata,
            bundleMap,
            memberName: className,
          );
          customDiscriminatorName ??= cfg.serializedKey;
        default:
          registry.parseAnnotation(
            name: name,
            arguments: arguments,
            memberName: className,
          );
      }
    }

    final fields = <ParsedField>[];
    final constructorParams = <ParsedConstructorParam>[];
    var isPrimaryConstructor = false;
    var constructorName = '';

    // Check for primary constructor
    if (node.namePart case PrimaryConstructorDeclaration primary) {
      isPrimaryConstructor = true;
      if (primary.constructorName != null) {
        constructorName = primary.constructorName!.name.lexeme;
      }

      for (final param in primary.formalParameters.parameters) {
        final paramName = param.name?.lexeme ?? '';
        final paramTypeStr = _getParameterTypeString(param);
        final paramType = ParsedType.parse(paramTypeStr);
        final fieldConfig = registry.parseFieldConfig(
          param.metadata,
          bundleMap,
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
    if (node.body case BlockClassBody body) {
      for (final member in body.members) {
        if (member is FieldDeclaration && !member.isStatic) {
          final typeStr = member.fields.type?.toSource() ?? 'dynamic';
          final parsedType = ParsedType.parse(typeStr);
          final fieldAnnotations = registry.parseFieldConfig(
            member.metadata,
            bundleMap,
            memberName: 'field',
          );

          for (final variable in member.fields.variables) {
            final varName = variable.name.lexeme;
            final initCode = variable.initializer?.toSource();
            final varAnnotations = registry.parseFieldConfig(
              variable.metadata,
              bundleMap,
              memberName: varName,
            );
            final mergedConfig = fieldAnnotations.merge(varAnnotations, varName);

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

            final matchedField = fields.where((f) => f.name == paramName).firstOrNull;
            if (paramTypeStr == 'dynamic' &&
                (param is FieldFormalParameter ||
                    param.toSource().startsWith('this.'))) {
              if (matchedField != null) {
                paramTypeStr = matchedField.type.rawType;
              }
            }

            final paramType = ParsedType.parse(paramTypeStr);
            final paramConfig = registry.parseFieldConfig(
              param.metadata,
              bundleMap,
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

    // Validate @Flatten target contract
    for (final field in fields) {
      if (field.config.isFlattened) {
        final t = field.type;
        if (t.isPrimitive ||
            t.isList ||
            t.isSet ||
            t.isMap ||
            t.isQueryMap ||
            t.isDynamic ||
            t.isObject) {
          throw InvalidGenerationSourceError(
            '@Flatten cannot be used on field "${field.name}" of type "${t.rawType}". '
            'The target type must be a custom class implementing toMap({bool excludeNull = false}) and fromMap(Map<String, dynamic> map).',
            todo: 'Remove @Flatten from "${field.name}" or use a custom class type.',
          );
        }
      }
    }

    // Validate duplicate wire keys and aliases
    final seenClassKeys = <String, String>{};
    for (final field in fields) {
      if (field.config.isIgnored || field.config.isFlattened) continue;
      final wireKey = field.resolvedSerializeKey(serializeInfo?.caseStyle);
      if (seenClassKeys.containsKey(wireKey)) {
        throw InvalidGenerationSourceError(
          'Duplicate wire key or alias "$wireKey" found on field "${field.name}" in class "$className" (conflicts with "${seenClassKeys[wireKey]}").',
          todo: 'Ensure all serialized keys and aliases within "$className" are unique.',
        );
      }
      seenClassKeys[wireKey] = field.name;

      for (final alias in field.config.aliases) {
        if (seenClassKeys.containsKey(alias)) {
          throw InvalidGenerationSourceError(
            'Duplicate wire key or alias "$alias" found on field "${field.name}" in class "$className" (conflicts with "${seenClassKeys[alias]}").',
            todo: 'Ensure all serialized keys and aliases within "$className" are unique.',
          );
        }
        seenClassKeys[alias] = field.name;
      }
    }

    classes.add(
      ParsedClass(
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
      ),
    );
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    final enumName = node.namePart.typeName.lexeme;

    SerializeInfo? serializeInfo;
    DeserializeInfo? deserializeInfo;
    StringifyInfo? stringifyInfo;
    String? fallbackCaseCode;

    for (final (name, arguments) in registry.resolveAnnotations(
      node.metadata,
      bundleMap,
    )) {
      switch (name) {
        case 'EqualsAndHashCode' || 'equalsAndHashCode':
          throw UnsupportedError(
            'Enums do not support @EqualsAndHashCode (found on enum $enumName)',
          );
        case 'CopyWith' || 'copyWith':
          throw UnsupportedError(
            'Enums do not support @CopyWith (found on enum $enumName)',
          );
        case 'Stringify' || 'stringify':
          stringifyInfo = registry.parseAnnotation<StringifyInfo>(
            name: name,
            arguments: arguments,
            memberName: enumName,
          );
        case 'Serialize' || 'serialize':
          serializeInfo = registry.parseAnnotation<SerializeInfo>(
            name: name,
            arguments: arguments,
            memberName: enumName,
          );
        case 'Deserialize' || 'deserialize':
          deserializeInfo = registry.parseAnnotation<DeserializeInfo>(
            name: name,
            arguments: arguments,
            memberName: enumName,
          );
        case 'Fallback':
          final code = const FallbackAnnotationHandler().parse((
            name: name,
            arguments: arguments,
            memberName: enumName,
          ));
          if (code != null) {
            fallbackCaseCode = code;
          }
        default:
          registry.parseAnnotation(
            name: name,
            arguments: arguments,
            memberName: enumName,
          );
      }
    }

    final valueFieldName =
        serializeInfo?.valueField ?? deserializeInfo?.valueField;
    ParsedType? valueFieldType;
    final constants = <ParsedEnumConstant>[];

    if (node.body case BlockEnumBody body) {
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
      if (node.namePart case PrimaryConstructorDeclaration primary) {
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

        final config = registry.parseFieldConfig(
          constant.metadata,
          bundleMap,
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

    // Validate duplicate wire keys and aliases
    final seenEnumKeys = <String, String>{};
    for (final constant in constants) {
      if (constant.isIgnored) continue;
      final wireVal = constant.resolvedSerializeValue(serializeInfo?.caseStyle);
      final cleanWireVal = wireVal.replaceAll("'", '').replaceAll('"', '');
      if (seenEnumKeys.containsKey(cleanWireVal)) {
        throw InvalidGenerationSourceError(
          'Duplicate wire key or alias "$cleanWireVal" found on enum constant "${constant.name}" in enum "$enumName" (conflicts with "${seenEnumKeys[cleanWireVal]}").',
          todo: 'Ensure all wire values and aliases within "$enumName" are unique.',
        );
      }
      seenEnumKeys[cleanWireVal] = constant.name;

      for (final alias in constant.config.aliases) {
        if (seenEnumKeys.containsKey(alias)) {
          throw InvalidGenerationSourceError(
            'Duplicate wire key or alias "$alias" found on enum constant "${constant.name}" in enum "$enumName" (conflicts with "${seenEnumKeys[alias]}").',
            todo: 'Ensure all wire values and aliases within "$enumName" are unique.',
          );
        }
        seenEnumKeys[alias] = constant.name;
      }
    }

    enums.add(
      ParsedEnum(
        name: enumName,
        serialize: serializeInfo,
        deserialize: deserializeInfo,
        stringify: stringifyInfo,
        valueFieldName: valueFieldName,
        valueFieldType: valueFieldType,
        constants: constants,
        fallbackCaseCode: fallbackCaseCode,
      ),
    );
  }

  @override
  void visitExtensionTypeDeclaration(ExtensionTypeDeclaration node) {
    final name = node.namePart.typeName.lexeme;

    SerializeInfo? serializeInfo;
    DeserializeInfo? deserializeInfo;

    for (final (annotName, arguments) in registry.resolveAnnotations(
      node.metadata,
      bundleMap,
    )) {
      if (annotName == 'Serialize' || annotName == 'serialize') {
        serializeInfo = registry.parseAnnotation<SerializeInfo>(
          name: annotName,
          arguments: arguments,
          memberName: name,
        );
      } else if (annotName == 'Deserialize' || annotName == 'deserialize') {
        deserializeInfo = registry.parseAnnotation<DeserializeInfo>(
          name: annotName,
          arguments: arguments,
          memberName: name,
        );
      }
    }

    if (serializeInfo == null && deserializeInfo == null) return;

    if (node.namePart case PrimaryConstructorDeclaration primary) {
      final params = primary.formalParameters.parameters;
      if (params.isEmpty) return;
      final param = params.first;
      final fieldName = param.name?.lexeme ?? '';
      final fieldTypeStr = _getParameterTypeString(param);
      final fieldType = ParsedType.parse(fieldTypeStr);

      extensionTypes.add(
        ParsedExtensionType(
          name: name,
          representationFieldName: fieldName,
          representationType: fieldType,
          serialize: serializeInfo,
          deserialize: deserializeInfo,
        ),
      );
    }
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    final name = node.name.lexeme;

    SerializeInfo? serializeInfo;
    DeserializeInfo? deserializeInfo;

    for (final (annotName, arguments) in registry.resolveAnnotations(
      node.metadata,
      bundleMap,
    )) {
      if (annotName == 'Serialize' || annotName == 'serialize') {
        serializeInfo = registry.parseAnnotation<SerializeInfo>(
          name: annotName,
          arguments: arguments,
          memberName: name,
        );
      } else if (annotName == 'Deserialize' || annotName == 'deserialize') {
        deserializeInfo = registry.parseAnnotation<DeserializeInfo>(
          name: annotName,
          arguments: arguments,
          memberName: name,
        );
      }
    }

    if (serializeInfo == null && deserializeInfo == null) return;

    final typeStr = node.type.toSource();
    ParsedType recordType;

    if (node.type case RecordTypeAnnotation recordNode) {
      recordType = _parseRecordTypeAnnotation(recordNode, typeStr);
    } else {
      recordType = ParsedType.parse(typeStr);
    }

    recordAliases.add(
      ParsedRecordAlias(
        name: name,
        recordType: recordType,
        serialize: serializeInfo,
        deserialize: deserializeInfo,
      ),
    );
  }

  ParsedType _parseRecordTypeAnnotation(
    RecordTypeAnnotation recordNode,
    String typeStr,
  ) {
    final fields = <ParsedRecordField>[];
    var posIndex = 1;

    for (final f in recordNode.positionalFields) {
      final fieldTypeStr = f.type.toSource();
      final fieldType = f.type is RecordTypeAnnotation
          ? _parseRecordTypeAnnotation(
              f.type as RecordTypeAnnotation,
              fieldTypeStr,
            )
          : ParsedType.parse(fieldTypeStr);
      final fieldName = f.name?.lexeme;
      final cfg = registry.parseFieldConfig(
        f.metadata,
        bundleMap,
        memberName: fieldName ?? '\$$posIndex',
      );
      fields.add(
        ParsedRecordField(
          name: fieldName,
          type: fieldType,
          isNamed: false,
          position: posIndex++,
          serializedKey: cfg.serializedKey,
        ),
      );
    }

    if (recordNode.namedFields case RecordTypeAnnotationNamedFields named) {
      for (final f in named.fields) {
        final fieldTypeStr = f.type.toSource();
        final fieldType = f.type is RecordTypeAnnotation
            ? _parseRecordTypeAnnotation(
                f.type as RecordTypeAnnotation,
                fieldTypeStr,
              )
            : ParsedType.parse(fieldTypeStr);
        final fieldName = f.name.lexeme;
        final cfg = registry.parseFieldConfig(
          f.metadata,
          bundleMap,
          memberName: fieldName,
        );
        fields.add(
          ParsedRecordField(
            name: fieldName,
            type: fieldType,
            isNamed: true,
            position: posIndex++,
            serializedKey: cfg.serializedKey,
          ),
        );
      }
    }

    final isNullable = typeStr.endsWith('?');
    final baseName = isNullable
        ? typeStr.substring(0, typeStr.length - 1).trim()
        : typeStr.trim();

    return ParsedType(
      rawType: typeStr.trim(),
      baseName: baseName,
      isNullable: isNullable,
      recordFields: fields,
    );
  }

  void _validateRootAnnotations() {
    final sealedClasses = classes.where((c) => c.isSealed).toList();
    for (final clazz in classes) {
      final isSubclassOfAnnotatedSealed =
          !clazz.isSealed &&
          sealedClasses.any(
            (sc) =>
                clazz.isSubclassOf(sc.name) &&
                (sc.shouldSerialize ||
                    sc.shouldDeserialize ||
                    sc.shouldEqualsAndHashCode ||
                    sc.shouldStringify ||
                    sc.shouldCopyWith),
          );

      final hasRootAnnotation =
          clazz.shouldSerialize ||
          clazz.shouldDeserialize ||
          clazz.shouldEqualsAndHashCode ||
          clazz.shouldStringify ||
          clazz.shouldCopyWith ||
          isSubclassOfAnnotatedSealed;

      if (!hasRootAnnotation) {
        for (final field in clazz.fields) {
          if (field.config.hasAnyAnnotation) {
            throw InvalidGenerationSourceError(
              'Field "${field.name}" in class "${clazz.name}" is annotated with a Daxle member annotation, '
              'but "${clazz.name}" is not marked with any root annotation (@serialize, @deserialize, @equalsAndHashCode, @stringify, @copyWith).',
              todo:
                  'Add a root annotation to "${clazz.name}" or remove the annotation from "${field.name}".',
            );
          }
        }
        for (final param in clazz.constructorParams) {
          if (param.config.hasAnyAnnotation) {
            throw InvalidGenerationSourceError(
              'Parameter "${param.name}" in class "${clazz.name}" constructor is annotated with a Daxle member annotation, '
              'but "${clazz.name}" is not marked with any root annotation (@serialize, @deserialize, @equalsAndHashCode, @stringify, @copyWith).',
              todo:
                  'Add a root annotation to "${clazz.name}" or remove the annotation from "${param.name}".',
            );
          }
        }
      }
    }

    for (final enumEl in enums) {
      final hasRootAnnotation =
          enumEl.shouldSerialize ||
          enumEl.shouldDeserialize ||
          enumEl.shouldStringify ||
          enumEl.fallbackCaseCode != null;

      if (!hasRootAnnotation) {
        for (final constant in enumEl.constants) {
          if (constant.config.hasAnyAnnotation) {
            throw InvalidGenerationSourceError(
              'Enum case "${constant.name}" in enum "${enumEl.name}" is annotated with a Daxle member annotation, '
              'but "${enumEl.name}" is not marked with any root annotation (@serialize, @deserialize, @stringify, @Fallback).',
              todo:
                  'Add a root annotation to "${enumEl.name}" or remove the annotation from "${constant.name}".',
            );
          }
        }
      }
    }
  }

  String _getParameterTypeString(FormalParameter param) {
    return param.type?.toSource() ?? 'dynamic';
  }

  String? _getParameterDefaultValue(FormalParameter param) {
    return param.defaultClause?.value.toSource();
  }

  ParsedFile toParsedFile() => ParsedFile(
        filePath: filePath,
        fileName: fileName,
        classes: classes,
        enums: enums,
        extensionTypes: extensionTypes,
        recordAliases: recordAliases,
        partDirectives: partDirectives,
        bundleDeclarations: bundleMap,
        partOfPath: partOfPath,
      );
}
