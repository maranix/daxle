import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Option Record Extensions', () {
    test('Option 2-tuple zipped', () {
      final Option<int> opt1 = Option.some(1);
      final Option<String> opt2 = Option.some('a');
      final Option<int> optNone = Option.none();

      expect((opt1, opt2).zipped(), equals(Option.some((1, 'a'))));
      expect((opt1, optNone).zipped().isNone, isTrue);
    });

    test('Option 3-tuple zipped', () {
      final Option<int> opt1 = Option.some(1);
      final Option<String> opt2 = Option.some('a');
      final Option<bool> opt3 = Option.some(true);
      final Option<int> optNone = Option.none();

      expect((opt1, opt2, opt3).zipped(), equals(Option.some((1, 'a', true))));
      expect((opt1, opt2, optNone).zipped().isNone, isTrue);
    });
  });

  group('Either Record Extensions', () {
    test('Either 2-tuple zipped', () {
      final Either<String, int> e1 = Right(1);
      final Either<String, String> e2 = Right('a');
      final Either<String, int> eLeft = Left('error');

      expect(
        (e1, e2).zipped(),
        equals(const Right<String, (int, String)>((1, 'a'))),
      );
      expect(
        (e1, eLeft).zipped(),
        equals(const Left<String, (int, int)>('error')),
      );
    });

    test('Either 3-tuple zipped', () {
      final Either<String, int> e1 = Right(1);
      final Either<String, String> e2 = Right('a');
      final Either<String, bool> e3 = Right(true);
      final Either<String, int> eLeft = Left('error');

      expect(
        (e1, e2, e3).zipped(),
        equals(const Right<String, (int, String, bool)>((1, 'a', true))),
      );
      expect(
        (e1, e2, eLeft).zipped(),
        equals(const Left<String, (int, String, int)>('error')),
      );
    });
  });

  group('TaskEither Record Extensions', () {
    test('TaskEither 2-tuple zipped', () async {
      final t1 = TaskEither<String, int>.right(1);
      final t2 = TaskEither<String, String>.right('a');
      final tLeft = TaskEither<String, int>.left('error');

      final success = await (t1, t2).zipped().run();
      final fail = await (t1, tLeft).zipped().run();

      expect(success, equals(const Right<String, (int, String)>((1, 'a'))));
      expect(fail, equals(const Left<String, (int, int)>('error')));
    });

    test('TaskEither 3-tuple zipped', () async {
      final t1 = TaskEither<String, int>.right(1);
      final t2 = TaskEither<String, String>.right('a');
      final t3 = TaskEither<String, bool>.right(true);
      final tLeft = TaskEither<String, int>.left('error');

      final success = await (t1, t2, t3).zipped().run();
      final fail = await (t1, t2, tLeft).zipped().run();

      expect(
        success,
        equals(const Right<String, (int, String, bool)>((1, 'a', true))),
      );
      expect(fail, equals(const Left<String, (int, String, int)>('error')));
    });
  });
}
