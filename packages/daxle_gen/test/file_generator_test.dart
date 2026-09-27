import 'package:daxle_gen/src/generator/file_generator.dart';
import 'package:daxle_gen/src/parser/daxle_ast_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = DaxleAstParser();
  final generator = FileGenerator();

  test(
    'generates preamble, fromJson and toMap for primary constructor model',
    () {
      const code = '''
import 'package:daxle/daxle.dart';

part 'user.daxle.dart';

@serialize
@deserialize
class User(
  @SerializedValue('user_id')
  final String id,
  final String name,
  final DateTime createdAt,
  final Option<String> nickname, {
  final int age = 18,
});
''';

      final parsedFile = parser.parseContent(code, filePath: 'lib/user.dart');
      final generated = generator.generate(parsedFile);

      expect(generated, isNotNull);
      expect(generated, contains('// coverage:ignore-file'));
      expect(generated, contains('// GENERATED CODE - DO NOT MODIFY BY HAND'));
      expect(generated, contains("part of 'user.dart';"));
      expect(
        generated,
        contains('User userFromJson(Map<String, dynamic> json)'),
      );
      expect(
        generated,
        contains('Map<String, dynamic> userToMap(User instance)'),
      );
      expect(generated, contains("'user_id': instance.id"));
      expect(generated, contains("'user_id': final String idRaw"));
      expect(generated, contains('createdAt.toIso8601String()'));
    },
  );

  test('generates enum mappings and conversions', () {
    const code = '''
import 'package:daxle/daxle.dart';

part 'status.daxle.dart';

@serializeEnum
@deserializeEnum
enum Status { pending, active, completed }

@SerializeEnum(valueField: 'code')
@DeserializeEnum(valueField: 'code')
enum const Priority(final int code) {
  low(10),
  high(20);
}
''';

    final parsedFile = parser.parseContent(code, filePath: 'lib/status.dart');
    final generated = generator.generate(parsedFile);

    expect(generated, isNotNull);
    expect(generated, contains('const _statusEnumMap ='));
    expect(generated, contains('Status statusFromValue(Object? value)'));
    expect(generated, contains('dynamic statusToValue(Status instance)'));
    expect(generated, contains('const _priorityEnumMap ='));
    expect(generated, contains('Priority.low: 10'));
    expect(generated, contains('Priority.high: 20'));
  });

  test('generates sealed class polymorphism', () {
    const code = '''
import 'package:daxle/daxle.dart';

part 'shape.daxle.dart';

@Serialize(discriminator: 'kind')
@Deserialize(discriminator: 'kind')
sealed class Shape {}

class Circle extends Shape {
  final double radius;
  Circle(this.radius);
}

class Square extends Shape {
  final double side;
  Square(this.side);
}
''';

    final parsedFile = parser.parseContent(code, filePath: 'lib/shape.dart');
    final generated = generator.generate(parsedFile);

    expect(generated, isNotNull);
    expect(
      generated,
      contains('Shape shapeFromJson(Map<String, dynamic> json)'),
    );
    expect(generated, contains("{'kind': 'Circle'} => circleFromJson(json)"));
    expect(generated, contains("{'kind': 'Square'} => squareFromJson(json)"));
    expect(
      generated,
      contains('Map<String, dynamic> shapeToMap(Shape instance)'),
    );
    expect(generated, contains("circleToMap(circle)..['kind'] = 'Circle'"));
  });

  test('generates case conversion and ignores fields', () {
    const code = '''
import 'package:daxle/daxle.dart';

part 'member.daxle.dart';

@Serialize(caseStyle: CaseStyle.snakeCase, ignoreFields: ['internalToken'])
@Deserialize(caseStyle: CaseStyle.snakeCase, ignoreFields: ['internalToken'])
class Member(
  final String memberName,
  final int loginCount,
  final String internalToken,
);
''';

    final parsedFile = parser.parseContent(code, filePath: 'lib/member.dart');
    final generated = generator.generate(parsedFile);

    expect(generated, isNotNull);
    expect(generated, contains("'member_name': instance.memberName"));
    expect(generated, contains("'login_count': instance.loginCount"));
    expect(generated, isNot(contains('internalToken')));
    expect(generated, isNot(contains('internal_token')));
  });

  test('generates enum mappings with fallback custom values and always throws on unknown', () {
    const code = '''
import 'package:daxle/daxle.dart';

part 'state.daxle.dart';

@serializeEnum
@deserializeEnum
enum TaskState {
  @SerializedValue('in_progress')
  inProgress,
  @SerializedValue(101)
  codeEntry,
  unknown,
}
''';

    final parsedFile = parser.parseContent(code, filePath: 'lib/state.dart');
    final generated = generator.generate(parsedFile);

    expect(generated, isNotNull);
    expect(generated, contains("TaskState.inProgress: 'in_progress'"));
    expect(generated, contains("TaskState.codeEntry: 101"));
    expect(generated, contains("TaskState.unknown: 'unknown'"));
    expect(generated, contains("'in_progress' => TaskState.inProgress"));
    expect(generated, contains("101 => TaskState.codeEntry"));
    expect(generated, contains("'unknown' => TaskState.unknown"));
    expect(
      generated,
      contains("_ => throw ArgumentError('Unknown TaskState value: \$value')"),
    );
    expect(generated, isNot(contains("_ => TaskState.unknown")));
    expect(generated, isNot(contains("_ => TaskState.inProgress")));
  });

  test('generates fallback for missing or null value in fromJson', () {
    const code = '''
import 'package:daxle/daxle.dart';

part 'user.daxle.dart';

@Serialize()
@Deserialize()
class Profile(
  final String id,
  @Fallback('guest')
  final String? role,
  @Fallback(0)
  final int? loginCount,
);
''';

    final parsedFile = parser.parseContent(code, filePath: 'lib/user.dart');
    final generated = generator.generate(parsedFile);

    expect(generated, isNotNull);
    expect(
      generated,
      contains("json['role'] == null ? 'guest' : (json['role'] as String?)"),
    );
    expect(
      generated,
      contains(
        "json['loginCount'] == null ? 0 : ((json['loginCount'] as num?)?.toInt())",
      ),
    );
  });

  test('generates enum mappings with @Fallback on enum declaration and @ignore on enum cases', () {
    const code = '''
import 'package:daxle/daxle.dart';

part 'single.daxle.dart';

@Fallback(SingleConfig.fallbackCase)
@serializeEnum
@deserializeEnum
enum SingleConfig {
  @SerializedValue('std')
  standard,

  @SerializedValue(202)
  numericCase,

  @ignore
  ignoredCase,

  fallbackCase,
}
''';

    final parsedFile = parser.parseContent(code, filePath: 'lib/single.dart');
    final generated = generator.generate(parsedFile);

    expect(generated, isNotNull);
    expect(generated, contains("SingleConfig.standard: 'std'"));
    expect(generated, contains("'std' => SingleConfig.standard"));
    expect(generated, contains("SingleConfig.numericCase: 202"));
    expect(generated, contains("202 => SingleConfig.numericCase"));
    expect(generated, isNot(contains("ignoredCase")));
    expect(generated, contains("_ => SingleConfig.fallbackCase"));
  });
}
