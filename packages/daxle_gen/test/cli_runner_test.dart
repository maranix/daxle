import 'dart:io';

import 'package:daxle_gen/src/cli/cli_runner.dart';
import 'package:daxle_gen/src/cli/glob_filter.dart';
import 'package:test/test.dart';

void main() {
  group('GlobFilter', () {
    test('supports standard inclusions and default exclusions', () {
      final filter = GlobFilter.fromPatterns(['**/*.dart']);

      expect(filter.matches('lib/user.dart'), true);
      expect(filter.matches('lib/nested/model.dart'), true);

      // Exclusions
      expect(filter.matches('lib/user.daxle.dart'), false);
      expect(filter.matches('lib/user.g.dart'), false);
      expect(filter.matches('.dart_tool/some.dart'), false);
      expect(filter.matches('build/some.dart'), false);
      expect(filter.matches('lib/readme.md'), false);
    });

    test('supports negation with ! prefix', () {
      final filter = GlobFilter.fromPatterns([
        '**/*.dart',
        '!**/ignored/**',
        '!lib/special_*.dart',
      ]);

      expect(filter.matches('lib/user.dart'), true);
      expect(filter.matches('lib/ignored/user.dart'), false);
      expect(filter.matches('lib/special_item.dart'), false);
      // Ensure system default exclusions are still retained
      expect(filter.matches('lib/user.daxle.dart'), false);
      expect(filter.matches('.dart_tool/some.dart'), false);
    });

    test('findPackageRoot finds pubspec.yaml ascending tree', () {
      final root = DaxleCliRunner.findPackageRoot(
        'packages/daxle_gen/test/cli_runner_test.dart',
      );
      expect(File('$root/pubspec.yaml').existsSync(), true);
    });
  });

  group('DaxleCliRunner', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('daxle_cli_test_');
      File('${tempDir.path}/pubspec.yaml')
          .writeAsStringSync('name: test_pkg\n');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'generates .daxle.dart file with preamble and correct naming',
      () async {
        final sourceFile = File('${tempDir.path}/item.dart');
        sourceFile.writeAsStringSync('''
import 'package:daxle/daxle.dart';

part 'item.daxle.dart';

@serialize
@deserialize
class Item(final String id, final int price);
''');

        final runner = DaxleCliRunner();
        final exitCode = await runner.run(['generate', tempDir.path]);
        expect(exitCode, 0);

        final genFile = File('${tempDir.path}/item.daxle.dart');
        expect(genFile.existsSync(), true);

        final content = genFile.readAsStringSync();
        expect(content, contains('// coverage:ignore-file'));
        expect(content, contains('// GENERATED CODE - DO NOT MODIFY BY HAND'));
        expect(content, contains("part of 'item.dart';"));
        expect(
          content,
          contains('Item itemFromMap(Map<String, dynamic> json)'),
        );
        expect(
          content,
          contains(
            'Map<String, dynamic> itemToMap(Item instance, {bool excludeNull = false})',
          ),
        );
      },
    );

    test(
      '--check reports drift and exits with code 1 if file missing or changed',
      () async {
        final sourceFile = File('${tempDir.path}/item.dart');
        sourceFile.writeAsStringSync('''
import 'package:daxle/daxle.dart';

part 'item.daxle.dart';

@serialize
@deserialize
class Item(final String id, final int price);
''');

        final runner = DaxleCliRunner();
        // First generation
        var code = await runner.run(['generate', tempDir.path]);
        expect(code, 0);

        // Check should pass
        code = await runner.run(['generate', tempDir.path, '--check']);
        expect(code, 0);

        // Modify generated file -> drift!
        final genFile = File('${tempDir.path}/item.daxle.dart');
        genFile.writeAsStringSync('// Tampered');

        code = await runner.run(['generate', tempDir.path, '--check']);
        expect(code, 1);
      },
    );

    test('--help exits with code 0', () async {
      final runner = DaxleCliRunner();
      final code = await runner.run(['--help']);
      expect(code, 0);
    });

    test('--clean deletes all generated files and manifest', () async {
      final sourceFile = File('${tempDir.path}/item.dart');
      sourceFile.writeAsStringSync('''
import 'package:daxle/daxle.dart';

part 'item.daxle.dart';

@serialize
class Item(final String id);
''');

      final runner = DaxleCliRunner();
      var code = await runner.run(['generate', tempDir.path]);
      expect(code, 0);

      final genFile = File('${tempDir.path}/item.daxle.dart');
      expect(genFile.existsSync(), true);

      code = await runner.run(['generate', tempDir.path, '--clean']);
      expect(code, 0);
      expect(genFile.existsSync(), false);
    });

    test('--force regenerates even if cache is up-to-date', () async {
      final sourceFile = File('${tempDir.path}/item.dart');
      sourceFile.writeAsStringSync('''
import 'package:daxle/daxle.dart';

part 'item.daxle.dart';

@serialize
class Item(final String id);
''');

      final runner = DaxleCliRunner();
      var code = await runner.run(['generate', tempDir.path]);
      expect(code, 0);

      final genFile = File('${tempDir.path}/item.daxle.dart');
      expect(genFile.existsSync(), true);

      // Overwrite generated file with comment
      genFile.writeAsStringSync(
        '// modified comment\n${genFile.readAsStringSync()}',
      );

      // Normal run skips because source didn't change (if cached) or updates cache
      // Running with --force will overwrite and restore pure generated content
      code = await runner.run(['generate', tempDir.path, '--force']);
      expect(code, 0);
      expect(genFile.readAsStringSync().contains('// modified comment'), false);
    });
  });
}
