import 'dart:io';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// Handles inclusion and exclusion matching based on glob patterns.
class GlobFilter {
  final List<Glob> includeGlobs;
  final List<Glob> excludeGlobs;
  final String baseDir;

  GlobFilter({
    required this.includeGlobs,
    required this.excludeGlobs,
    required this.baseDir,
  });

  /// Creates a [GlobFilter] from pattern strings. Patterns starting with `!` are treated as exclusions.
  /// System default exclusions (*.daxle.dart, .dart_tool, build outputs) are always enforced.
  factory GlobFilter.fromPatterns(
    Iterable<String> patterns, {
    String context = '.',
  }) {
    final baseDir = FileSystemEntity.isDirectorySync(context)
        ? p.normalize(p.absolute(context))
        : p.normalize(p.absolute(p.dirname(context)));
    final includes = <Glob>[];
    final excludes = <Glob>[
      // Always exclude generated files and internal caches
      Glob('*.daxle.dart'),
      Glob('**/*.daxle.dart'),
      Glob('*.g.dart'),
      Glob('**/*.g.dart'),
      Glob('.dart_tool/**'),
      Glob('**/.dart_tool/**'),
      Glob('build/**'),
      Glob('**/build/**'),
    ];

    for (final pattern in patterns) {
      final trimmed = pattern.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('!')) {
        excludes.add(Glob(trimmed.substring(1)));
      } else {
        includes.add(Glob(trimmed));
      }
    }

    // Default inclusions if none specified
    if (includes.isEmpty) {
      includes.addAll([
        Glob('*.dart'),
        Glob('**/*.dart'),
      ]);
    }

    return GlobFilter(
      includeGlobs: includes,
      excludeGlobs: excludes,
      baseDir: baseDir,
    );
  }

  /// Checks whether [filePath] matches the filter rules.
  bool matches(String filePath) {
    if (!filePath.endsWith('.dart')) {
      return false;
    }

    final normalized = p.normalize(filePath);
    final relativePath = p.isAbsolute(normalized)
        ? p.relative(normalized, from: baseDir)
        : normalized;

    final filename = p.basename(filePath);

    // If matches any exclusion, reject
    for (final glob in excludeGlobs) {
      if (glob.matches(normalized) ||
          glob.matches(relativePath) ||
          glob.matches(filename)) {
        return false;
      }
    }

    // Must match at least one inclusion
    for (final glob in includeGlobs) {
      if (glob.matches(normalized) ||
          glob.matches(relativePath) ||
          glob.matches(filename)) {
        return true;
      }
    }

    return false;
  }
}
