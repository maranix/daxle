import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

import '../cache/content_cache.dart';
import '../generator/daxle_generator.dart';
import 'glob_filter.dart';

/// Command-line argument runner for Daxle code generation.
class DaxleCliRunner {
  final ArgParser argParser;

  DaxleCliRunner() : argParser = _createArgParser();

  static ArgParser _createArgParser() {
    final parser = ArgParser();

    parser.addFlag(
      'watch',
      abbr: 'w',
      negatable: false,
      help: 'Watch directory for file changes and regenerate incrementally.',
    );

    parser.addMultiOption(
      'filter',
      abbr: 'f',
      help: 'Glob patterns to include or exclude files (use ! for negation).',
    );

    parser.addFlag(
      'check',
      negatable: false,
      help: 'Verifies whether generated code is up-to-date without writing files.',
    );

    parser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Prints detailed timing and processing metrics.',
    );

    parser.addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Display usage help information.',
    );

    return parser;
  }

  /// Executes the CLI with provided arguments.
  Future<int> run(List<String> rawArgs) async {
    // If first argument is 'generate', strip it
    var args = List<String>.from(rawArgs);
    if (args.isNotEmpty && args.first == 'generate') {
      args.removeAt(0);
    }

    ArgResults results;
    try {
      results = argParser.parse(args);
    } on FormatException catch (e) {
      stderr.writeln('Error: ${e.message}');
      stderr.writeln(argParser.usage);
      return 64; // ExitCode.usage
    }

    if (results['help'] as bool) {
      print('Daxle Code Generator');
      print('Usage: dart run daxle_gen generate [target] [flags]');
      print('       dart run daxle:generate [target] [flags]');
      print('');
      print(argParser.usage);
      return 0;
    }

    final target = results.rest.isNotEmpty ? results.rest.first : '.';
    final watch = results['watch'] as bool;
    final check = results['check'] as bool;
    final verbose = results['verbose'] as bool;
    final filterPatterns = results['filter'] as List<String>;

    final globFilter = GlobFilter.fromPatterns(filterPatterns, context: target);
    final cacheRoot = findPackageRoot(target);
    final cache = ContentCache(root: cacheRoot);
    final generator = DaxleGenerator(cache: cache);

    if (watch) {
      return await _runWatch(
        target: target,
        filter: globFilter,
        verbose: verbose,
        generator: generator,
      );
    }

    final stopwatch = Stopwatch()..start();
    final result = await generator.run(
      targetPath: target,
      filter: globFilter,
      check: check,
      verbose: verbose,
      log: print,
    );
    stopwatch.stop();

    if (check) {
      if (result.hasDrift) {
        stderr.writeln(
          'Drift detected in ${result.driftFiles.length} file(s). Run `dart run daxle:generate` to resolve.',
        );
        for (final file in result.driftFiles) {
          stderr.writeln(' - $file');
        }
        return 1;
      }
      print('Check passed: all generated files are up-to-date.');
      return 0;
    }

    if (result.hasErrors) {
      stderr.writeln(
        'Errors encountered in ${result.errorFiles.length} file(s).',
      );
      return 1;
    }

    print(
      'Daxle generation complete: ${result.filesGenerated} generated, ${result.filesCached} cached (${stopwatch.elapsedMilliseconds}ms)',
    );
    return 0;
  }

  Future<int> _runWatch({
    required String target,
    required GlobFilter filter,
    required bool verbose,
    required DaxleGenerator generator,
  }) async {
    print('Watching $target for file changes... (Press Ctrl+C to exit)');

    // Run initial generation pass
    await generator.run(
      targetPath: target,
      filter: filter,
      verbose: verbose,
      log: print,
    );

    final targetDir = Directory(target);
    if (!targetDir.existsSync()) {
      stderr.writeln('Target directory does not exist: $target');
      return 1;
    }

    final watcher = DirectoryWatcher(target);
    Timer? debounceTimer;
    final changedPaths = <String>{};

    final completer = Completer<int>();

    // Handle SIGINT
    ProcessSignal.sigint.watch().listen((_) {
      if (!completer.isCompleted) {
        completer.complete(0);
      }
    });

    watcher.events.listen((event) {
      final path = event.path;
      if (!path.endsWith('.dart') || path.endsWith('.daxle.dart')) {
        return;
      }
      if (!filter.matches(path)) {
        return;
      }

      changedPaths.add(path);
      debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 150), () async {
        final toProcess = List<String>.from(changedPaths);
        changedPaths.clear();

        for (final filePath in toProcess) {
          if (File(filePath).existsSync()) {
            print('[CHANGE DETECTED] ${p.relative(filePath)}');
            await generator.run(
              targetPath: filePath,
              filter: filter,
              verbose: verbose,
              log: print,
            );
          }
        }
      });
    });

    return await completer.future;
  }

  /// Traverses upwards from [startPath] to locate the project or package root containing `pubspec.yaml`.
  static String findPackageRoot(String startPath) {
    var dir = Directory(startPath).existsSync()
        ? Directory(startPath)
        : File(startPath).parent;
    while (true) {
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir.path;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return Directory.current.path;
  }
}
