import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Entry in the code generation manifest.
class ManifestEntry {
  final String sourceHash;
  final String generatedPath;
  final String generatedHash;

  const ManifestEntry({
    required this.sourceHash,
    required this.generatedPath,
    required this.generatedHash,
  });

  Map<String, dynamic> toJson() => {
    'sourceHash': sourceHash,
    'generatedPath': generatedPath,
    'generatedHash': generatedHash,
  };

  factory ManifestEntry.fromJson(Map<String, dynamic> json) => ManifestEntry(
    sourceHash: json['sourceHash'] as String? ?? '',
    generatedPath: json['generatedPath'] as String? ?? '',
    generatedHash: json['generatedHash'] as String? ?? '',
  );
}

/// Cache manager for content hashes and drift detection.
class ContentCache {
  final String rootDir;
  late final File manifestFile;
  final Map<String, ManifestEntry> _entries = {};

  ContentCache({String? root}) : rootDir = root ?? Directory.current.path {
    final manifestPath = p.join(
      rootDir,
      '.dart_tool',
      'daxle_gen',
      'manifest.json',
    );
    manifestFile = File(manifestPath);
    load();
  }

  /// Calculates the SHA-256 hash of a file's contents.
  static String hashFile(File file) {
    if (!file.existsSync()) return '';
    return hashContent(file.readAsStringSync());
  }

  /// Calculates the SHA-256 hash of a string.
  static String hashContent(String content) {
    return sha256.convert(utf8.encode(content)).toString();
  }

  void load() {
    if (!manifestFile.existsSync()) return;
    try {
      final jsonStr = manifestFile.readAsStringSync();
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      for (final entry in data.entries) {
        if (entry.value is Map<String, dynamic>) {
          _entries[entry.key] = ManifestEntry.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      }
    } catch (_) {
      // If corrupted, reset
      _entries.clear();
    }
  }

  void save() {
    if (!manifestFile.parent.existsSync()) {
      manifestFile.parent.createSync(recursive: true);
    }
    final data = _entries.map((k, v) => MapEntry(k, v.toJson()));
    manifestFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  /// Checks if a source file is up-to-date with its generated counterpart.
  bool isUpToDate(String sourcePath, String generatedPath) {
    final relSource = p.relative(sourcePath, from: rootDir);
    final entry = _entries[relSource];
    if (entry == null) return false;

    final genFile = File(generatedPath);
    if (!genFile.existsSync()) return false;

    final currentSourceHash = hashFile(File(sourcePath));
    if (currentSourceHash != entry.sourceHash) return false;

    final currentGenHash = hashFile(genFile);
    return currentGenHash == entry.generatedHash;
  }

  /// Updates the cache entry for [sourcePath].
  void record(
    String sourcePath,
    String generatedPath,
    String generatedContent,
  ) {
    final relSource = p.relative(sourcePath, from: rootDir);
    final relGen = p.relative(generatedPath, from: rootDir);

    final sourceHash = hashFile(File(sourcePath));
    final genHash = hashContent(generatedContent);

    _entries[relSource] = ManifestEntry(
      sourceHash: sourceHash,
      generatedPath: relGen,
      generatedHash: genHash,
    );
  }

  /// Clears the entry for [sourcePath].
  void remove(String sourcePath) {
    final relSource = p.relative(sourcePath, from: rootDir);
    _entries.remove(relSource);
  }

  /// Removes all generated files tracked in the manifest, clears entries, and deletes the manifest file.
  /// Returns list of deleted file paths.
  List<String> clean() {
    final deleted = <String>[];
    for (final entry in _entries.values) {
      final genFile = File(p.join(rootDir, entry.generatedPath));
      if (genFile.existsSync()) {
        genFile.deleteSync();
        deleted.add(genFile.path);
      }
    }
    _entries.clear();
    if (manifestFile.existsSync()) {
      manifestFile.deleteSync();
    }
    return deleted;
  }
}
