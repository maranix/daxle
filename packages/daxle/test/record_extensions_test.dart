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

    test('Option 4-tuple and 5-tuple operations', () {
      final Option<int> o1 = Option.some(1);
      final Option<int> o2 = Option.some(2);
      final Option<int> o3 = Option.some(3);
      final Option<int> o4 = Option.some(4);
      final Option<int> o5 = Option.some(5);

      final Option<(int, int, int, int)> zipped4 = (o1, o2, o3, o4).zipped();
      expect(zipped4, equals(Option.some((1, 2, 3, 4))));

      final mapped5 = (
        o1,
        o2,
        o3,
        o4,
        o5,
      ).map((a, b, c, d, e) => a + b + c + d + e);
      expect(mapped5, equals(Option.some(15)));
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

    test('Either 4-tuple and 5-tuple operations', () {
      final Either<String, int> e1 = Right(1);
      final Either<String, int> e2 = Right(2);
      final Either<String, int> e3 = Right(3);
      final Either<String, int> e4 = Right(4);
      final Either<String, int> e5 = Right(5);

      final zipped4 = (e1, e2, e3, e4).zipped();
      expect(
        zipped4,
        equals(const Right<String, (int, int, int, int)>((1, 2, 3, 4))),
      );

      final mapped5 = (
        e1,
        e2,
        e3,
        e4,
        e5,
      ).map((a, b, c, d, e) => a + b + c + d + e);
      expect(mapped5, equals(const Right<String, int>(15)));
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

    test('TaskEither 4-tuple and 5-tuple operations', () async {
      final t1 = TaskEither<String, int>.right(1);
      final t2 = TaskEither<String, int>.right(2);
      final t3 = TaskEither<String, int>.right(3);
      final t4 = TaskEither<String, int>.right(4);
      final t5 = TaskEither<String, int>.right(5);

      final zipped4 = await (t1, t2, t3, t4).zipped().run();
      expect(
        zipped4,
        equals(const Right<String, (int, int, int, int)>((1, 2, 3, 4))),
      );

      final mapped5 = await (
        t1,
        t2,
        t3,
        t4,
        t5,
      ).map((a, b, c, d, e) => a + b + c + d + e).run();
      expect(mapped5, equals(const Right<String, int>(15)));
    });
  });
}
