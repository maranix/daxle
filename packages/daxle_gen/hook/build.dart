import 'dart:convert';
import 'dart:io';

import 'package:daxle_gen/daxle_gen.dart';

/// Dart build hook entrypoint (Trait #1: Compile-time Auto-heal mode).
/// Automatically validates and regenerates stale or missing `.daxle.dart` files
/// before compilation during `dart run`, `dart test`, and `dart build`.
void main(List<String> args) async {
  String? outFilePath;
  var rootDir = Directory.current.path;

  // Check if --config was passed by Dart hooks runner
  for (final arg in args) {
    if (arg.startsWith('--config=')) {
      final configPath = arg.substring('--config='.length);
      final configFile = File(configPath);
      if (configFile.existsSync()) {
        try {
          final data = json.decode(
            configFile.readAsStringSync(),
          ) as Map<String, dynamic>;
          outFilePath = data['out_file'] as String?;
          if (data['package_root'] case String pkgRoot) {
            rootDir = pkgRoot;
          }
        } catch (_) {}
      }
    }
  }

  final cache = ContentCache(root: rootDir);
  final generator = DaxleGenerator(cache: cache);

  try {
    final result = await generator.run(
      targetPath: rootDir,
      check: false,
      verbose: false,
      log: (msg) {
        if (msg.startsWith('[ERROR]') || msg.startsWith('[DIAGNOSTIC]')) {
          stderr.writeln('[daxle_gen:hook] $msg');
        }
      },
    );

    if (result.hasErrors) {
      stderr.writeln(
        '[daxle_gen:hook] Errors during auto-heal code generation:',
      );
      for (final err in result.errorFiles) {
        stderr.writeln(' - $err');
      }
      exit(1);
    }

    // Write output.json required by Dart build hook protocol
    if (outFilePath != null) {
      final outFile = File(outFilePath);
      if (!outFile.parent.existsSync()) {
        outFile.parent.createSync(recursive: true);
      }
      final hookOutput = {
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'status': 'success',
        'assets': [],
        'dependencies': [],
      };
      outFile.writeAsStringSync(json.encode(hookOutput));
    }
  } catch (e) {
    stderr.writeln('[daxle_gen:hook] Unexpected error in build hook: $e');
    exit(1);
  }
}
