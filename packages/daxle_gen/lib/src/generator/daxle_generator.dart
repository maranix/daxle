import 'dart:io';

import 'package:daxle_gen/src/models/annotation_info.dart';
import 'package:path/path.dart' as p;

import '../cache/content_cache.dart';
import '../cli/glob_filter.dart';
import '../parser/daxle_ast_parser.dart';
import '../models/parsed_element.dart';
import './file_generator.dart';

/// Result summary of a generation run.
class GenerationResult {
  final int filesScanned;
  final int filesGenerated;
  final int filesCached;
  final List<String> driftFiles;
  final List<String> errorFiles;

  const GenerationResult({
    this.filesScanned = 0,
    this.filesGenerated = 0,
    this.filesCached = 0,
    this.driftFiles = const [],
    this.errorFiles = const [],
  });

  bool get hasDrift => driftFiles.isNotEmpty;
  bool get hasErrors => errorFiles.isNotEmpty;
  bool get isSuccess => !hasDrift && !hasErrors;
}

/// Orchestrates the entire AST generation pipeline.
class DaxleGenerator {
  final DaxleAstParser parser;
  final FileGenerator fileGenerator;
  final ContentCache cache;

  DaxleGenerator({
    DaxleAstParser? parser,
    FileGenerator? fileGenerator,
    ContentCache? cache,
  }) : parser = parser ?? const DaxleAstParser(),
       fileGenerator = fileGenerator ?? FileGenerator(),
       cache = cache ?? ContentCache();

  /// Runs code generation across [targetPath] with glob filtering.
  Future<GenerationResult> run({
    String targetPath = '.',
    GlobFilter? filter,
    bool check = false,
    bool verbose = false,
    void Function(String msg)? log,
  }) async {
    final logger = log ?? (msg) => verbose ? print(msg) : null;
    final globFilter = filter ?? GlobFilter.fromPatterns([]);

    final targetFile = File(targetPath);
    final filesToProcess = <File>[];

    if (targetFile.existsSync()) {
      if (globFilter.matches(targetFile.path)) {
        filesToProcess.add(targetFile);
      }
    } else {
      final targetDir = Directory(targetPath);
      if (!targetDir.existsSync()) {
        throw ArgumentError('Target does not exist: $targetPath');
      }

      await for (final entity in targetDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.endsWith('.dart')) {
          if (globFilter.matches(entity.path)) {
            filesToProcess.add(entity);
          }
        }
      }
    }

    final projectEnums = <String>{};
    final projectClasses = <String>{};
    final projectCopyWithClasses = <String>{};
    final projectExtensionTypes = <String>{};
    final projectRecordAliases = <String, ParsedRecordAlias>{};
    final projectBundlesMap = <String, List<BundledAnnotation>>{};

    final discoveryFiles = <File>[...filesToProcess];
    if (targetFile.existsSync()) {
      var dir = targetFile.parent;
      while (dir.path != dir.parent.path) {
        if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
          break;
        }
        dir = dir.parent;
      }
      if (dir.existsSync()) {
        try {
          for (final entity in dir.listSync(
            recursive: true,
            followLinks: false,
          )) {
            if (entity is File &&
                entity.path.endsWith('.dart') &&
                !entity.path.endsWith('.daxle.dart')) {
              discoveryFiles.add(entity);
            }
          }
        } catch (_) {}
      }
    }

    final seenDiscoveryPaths = <String>{};
    for (final file in discoveryFiles) {
      final normPath = p.normalize(file.path);
      if (!seenDiscoveryPaths.add(normPath)) continue;

      try {
        final fileContent = file.readAsStringSync();
        if (fileContent.contains('enum') ||
            fileContent.contains('class') ||
            fileContent.contains('extension type') ||
            fileContent.contains('typedef') ||
            fileContent.contains('AnnotationBundle')) {
          final parsed = parser.parseContent(fileContent, filePath: normPath);
          projectEnums.addAll(parsed.enums.map((e) => e.name));
          projectClasses.addAll(parsed.classes.map((c) => c.name));
          projectExtensionTypes.addAll(
            parsed.extensionTypes.map((e) => e.name),
          );
          for (final r in parsed.recordAliases) {
            projectRecordAliases[r.name] = r;
          }
          projectBundlesMap.addAll(parsed.bundleDeclarations);

          for (final clazz in parsed.classes) {
            if (clazz.shouldCopyWith) {
              projectCopyWithClasses.add(clazz.name);
            }
          }
        }
      } catch (_) {}
    }

    var scanned = 0;
    var generated = 0;
    var cached = 0;
    final driftList = <String>[];
    final errorList = <String>[];
    final processedRoots = <String>{};

    for (final file in filesToProcess) {
      scanned++;
      final srcPath = p.normalize(file.path);
      final genPath = _computeGeneratedPath(srcPath);

      // Fast check: does source file contain any annotation keywords?
      final content = await file.readAsString();
      if (!content.contains('serialize') &&
          !content.contains('Serialize') &&
          !content.contains('deserialize') &&
          !content.contains('Deserialize') &&
          !content.contains('equalsAndHashCode') &&
          !content.contains('EqualsAndHashCode') &&
          !content.contains('stringify') &&
          !content.contains('Stringify') &&
          !content.contains('copyWith') &&
          !content.contains('CopyWith') &&
          !content.contains('SerializedValue') &&
          !content.contains('Fallback') &&
          !content.contains('ignore') &&
          !content.contains('Ignore')) {
        // Check if content references any known bundle alias
        final hasBundleRef = projectBundlesMap.keys.any(
          (name) => content.contains(name),
        );
        if (!hasBundleRef) continue;
      }

      try {
        var parsedFile = parser.parseContent(
          content,
          filePath: srcPath,
          externalBundleMap: projectBundlesMap,
        );

        var effectiveSrcPath = srcPath;
        var effectiveGenPath = genPath;

        if (parsedFile.partOfPath != null) {
          final rootPath = p.normalize(
            p.join(p.dirname(srcPath), parsedFile.partOfPath!),
          );

          if (!File(rootPath).existsSync()) continue;
          effectiveSrcPath = rootPath;
          effectiveGenPath = _computeGeneratedPath(rootPath);
        }

        if (!processedRoots.add(effectiveSrcPath)) continue;

        // Check cache for instant hit
        if (!check && cache.isUpToDate(effectiveSrcPath, effectiveGenPath)) {
          cached++;
          logger('[CACHE HIT] $effectiveSrcPath');
          continue;
        }

        parsedFile = _parseLibraryWithParts(
          effectiveSrcPath,
          externalBundleMap: projectBundlesMap,
        );

        if (!parsedFile.hasDaxleAnnotations) {
          continue;
        }

        final expectedGenFileName = p.basename(effectiveGenPath);
        if (!parsedFile.hasDaxlePartDirective) {
          logger(
            '[DIAGNOSTIC] $srcPath is missing directive: part \'$expectedGenFileName\';',
          );
        }

        final generatedCode = fileGenerator.generate(
          parsedFile,
          projectEnums: projectEnums,
          projectClasses: projectClasses,
          projectCopyWithClasses: projectCopyWithClasses,
          projectExtensionTypes: projectExtensionTypes,
          projectRecordAliases: projectRecordAliases,
        );
        if (generatedCode == null) continue;

        if (check) {
          final genFile = File(effectiveGenPath);
          if (!genFile.existsSync() ||
              genFile.readAsStringSync() != generatedCode) {
            driftList.add(effectiveSrcPath);
            logger(
              '[DRIFT DETECTED] $effectiveGenPath is missing or out-of-date',
            );
          } else {
            cached++;
          }
        } else {
          final genFile = File(effectiveGenPath);
          await genFile.writeAsString(generatedCode);
          cache.record(effectiveSrcPath, effectiveGenPath, generatedCode);
          generated++;
          logger('[GENERATED] $effectiveGenPath');
        }
      } catch (e, st) {
        errorList.add(srcPath);
        logger('[ERROR] Failed generating for $srcPath: $e\n$st');
      }
    }

    if (!check) {
      cache.save();
    }

    return GenerationResult(
      filesScanned: scanned,
      filesGenerated: generated,
      filesCached: cached,
      driftFiles: driftList,
      errorFiles: errorList,
    );
  }

  /// Converts a `.dart` path to `.daxle.dart`.
  static String _computeGeneratedPath(String sourcePath) {
    if (sourcePath.endsWith('.dart')) {
      final withoutExt = sourcePath.substring(0, sourcePath.length - 5);
      return '$withoutExt.daxle.dart';
    }
    return '$sourcePath.daxle.dart';
  }

  ParsedFile _parseLibraryWithParts(
    String rootPath, {
    Map<String, List<BundledAnnotation>> externalBundleMap = const {},
  }) {
    final rootContent = File(rootPath).readAsStringSync();
    final rootParsed = parser.parseContent(
      rootContent,
      filePath: rootPath,
      externalBundleMap: externalBundleMap,
    );

    final allClasses = [...rootParsed.classes];
    final allEnums = [...rootParsed.enums];
    final allExtTypes = [...rootParsed.extensionTypes];
    final allRecordAliases = [...rootParsed.recordAliases];

    for (final partUri in rootParsed.partDirectives) {
      if (partUri.endsWith('.daxle.dart')) continue; // skip our own output
      final partPath = p.normalize(p.join(p.dirname(rootPath), partUri));
      if (!File(partPath).existsSync()) continue;

      final partContent = File(partPath).readAsStringSync();
      final partParsed = parser.parseContent(
        partContent,
        filePath: partPath,
        externalBundleMap: externalBundleMap,
      );
      allClasses.addAll(partParsed.classes);
      allEnums.addAll(partParsed.enums);
      allExtTypes.addAll(partParsed.extensionTypes);
      allRecordAliases.addAll(partParsed.recordAliases);
    }

    return ParsedFile(
      filePath: rootPath,
      fileName: p.basename(rootPath),
      classes: allClasses,
      enums: allEnums,
      extensionTypes: allExtTypes,
      recordAliases: allRecordAliases,
      partDirectives: rootParsed.partDirectives,
      bundleDeclarations: rootParsed.bundleDeclarations,
    );
  }
}

