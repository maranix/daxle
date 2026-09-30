import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

import '../models/annotation_info.dart';
import '../models/parsed_element.dart';
import 'annotations/annotation_registry.dart';
import 'daxle_file_visitor.dart';

/// Parses Dart source files into [ParsedFile] structures using [DaxleFileVisitor].
final class DaxleAstParser {
  final AnnotationRegistry? registry;

  const DaxleAstParser({this.registry});

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
  ParsedFile parseContent(
    String content, {
    String filePath = 'source.dart',
    Map<String, List<BundledAnnotation>> externalBundleMap = const {},
  }) {
    final result = parseString(
      content: content,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    );
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    return parseUnit(
      result.unit,
      filePath: filePath,
      fileName: fileName,
      externalBundleMap: externalBundleMap,
    );
  }

  /// Parses a [CompilationUnit] directly using [DaxleFileVisitor].
  ParsedFile parseUnit(
    CompilationUnit unit, {
    required String filePath,
    required String fileName,
    Map<String, List<BundledAnnotation>> externalBundleMap = const {},
  }) {
    final visitor = DaxleFileVisitor(
      filePath,
      fileName,
      externalBundleMap: externalBundleMap,
      registry: registry,
    );
    unit.accept(visitor);
    return visitor.toParsedFile();
  }
}
