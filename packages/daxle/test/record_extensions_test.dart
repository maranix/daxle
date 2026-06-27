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

    test('Option tuple map, flatMap, and filter', () {
      final Option<int> opt1 = Option.some(10);
      final Option<int> opt2 = Option.some(20);

      // map
      final mapped = (opt1, opt2).map((a, b) => a + b);
      expect(mapped, equals(Option.some(30)));

      // flatMap
      final flatMapped = (opt1, opt2).flatMap((a, b) => Option.some(a * b));
      expect(flatMapped, equals(Option.some(200)));

      // filter success
      final filteredSuccess = (opt1, opt2).filter((a, b) => a + b > 15);
      expect(filteredSuccess, equals(Option.some((10, 20))));

      // filter failure
      final filteredFail = (opt1, opt2).filter((a, b) => a + b > 50);
      expect(filteredFail.isNone, isTrue);
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

    test('Either tuple map and flatMap', () {
      final Either<String, int> e1 = Right(10);
      final Either<String, int> e2 = Right(20);

      final mapped = (e1, e2).map((a, b) => a + b);
      expect(mapped, equals(const Right<String, int>(30)));

      final flatMapped = (e1, e2).flatMap((a, b) => Right<String, int>(a * b));
      expect(flatMapped, equals(const Right<String, int>(200)));
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

    test('TaskEither tuple map and flatMap', () async {
      final t1 = TaskEither<String, int>.right(10);
      final t2 = TaskEither<String, int>.right(20);

      final mapped = await (t1, t2).map((a, b) => a + b).run();
      expect(mapped, equals(const Right<String, int>(30)));

      final flatMapped = await (
        t1,
        t2,
      ).flatMap((a, b) => TaskEither.right(a * b)).run();
      expect(flatMapped, equals(const Right<String, int>(200)));
    });
  });
}
