import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('Right contains value and reports correct flags', () {
      final Either<String, int> val = Right(42);
      expect(val.isRight, isTrue);
      expect(val.isLeft, isFalse);
      expect(val.getOrElse((l) => 0), equals(42));
    });

    test('Left contains error and reports correct flags', () {
      final Either<String, int> val = Left('error');
      expect(val.isRight, isFalse);
      expect(val.isLeft, isTrue);
      expect(val.getOrElse((l) => 0), equals(0));
    });

    test('map transforms Right and leaves Left unchanged', () {
      final Either<String, int> right = Right(10);
      final Either<String, int> left = Left('err');

      expect(right.map((r) => r * 2).getOrElse((l) => 0), equals(20));
      expect(left.map((r) => r * 2).isLeft, isTrue);
    });

    test('mapLeft transforms Left and leaves Right unchanged', () {
      final Either<String, int> right = Right(10);
      final Either<String, int> left = Left('err');

      final mappedLeft = left.mapLeft((l) => '$l-modified');
      final mappedRight = right.mapLeft((l) => '$l-modified');

      expect(mappedLeft.fold((l) => l, (r) => ''), equals('err-modified'));
      expect(mappedRight.fold((l) => l, (r) => '$r'), equals('10'));
    });

    test('flatMap chains computations', () {
      final Either<String, int> right = Right(10);
      final Either<String, int> left = Left('err');

      final flatRight = right.flatMap((r) => Right<String, int>(r * 2));
      final flatLeft = left.flatMap((r) => Right<String, int>(r * 2));

      expect(flatRight.getOrElse((l) => 0), equals(20));
      expect(flatLeft.isLeft, isTrue);
    });

    test('fold projects values correctly', () {
      final Either<String, int> right = Right(42);
      final Either<String, int> left = Left('err');

      expect(right.fold((l) => 'L: $l', (r) => 'R: $r'), equals('R: 42'));
      expect(left.fold((l) => 'L: $l', (r) => 'R: $r'), equals('L: err'));
    });

    test('Either.left and Either.right factory constructors', () {
      final Either<String, int> leftVal = const Either.left('error');
      final Either<String, int> rightVal = const Either.right(42);

      expect(leftVal, equals(const Left<String, int>('error')));
      expect(rightVal, equals(const Right<String, int>(42)));
    });

    test('Either.cond factory constructor', () {
      final Either<String, int> condTrue = Either.cond(true, 42, 'error');
      final Either<String, int> condFalse = Either.cond(false, 42, 'error');

      expect(condTrue, equals(const Right<String, int>(42)));
      expect(condFalse, equals(const Left<String, int>('error')));
    });

    test('tryCatch handles success, errors, and propagates stack traces', () {
      final success = Either.tryCatch<String, int>(
        () => 42,
        (e, st) => 'error',
      );
      
      StackTrace? capturedStackTrace;
      final failure = Either.tryCatch<String, int>(
        () { throw StateError('oops'); },
        (e, st) {
          capturedStackTrace = st;
          return 'error';
        },
      );

      expect(success.getOrElse((_) => 0), equals(42));
      expect(failure.isLeft, isTrue);
      expect(failure.fold((l) => l, (r) => ''), equals('error'));
      expect(capturedStackTrace, isNotNull);
    });

    test('bimap transforms both sides', () {
      final Either<String, int> right = Right(10);
      final Either<String, int> left = Left('err');

      final mappedRight = right.bimap((l) => '$l!', (r) => r * 2);
      final mappedLeft = left.bimap((l) => '$l!', (r) => r * 2);

      expect(mappedRight.getOrElse((_) => 0), equals(20));
      expect(mappedLeft.fold((l) => l, (_) => ''), equals('err!'));
    });

    test('tap executes on Right exactly once and preserves identity', () {
      final Either<String, int> right = Right(10);
      final Either<String, int> left = Left('err');

      int rightCallCount = 0;
      final retRight = right.tap((r) => rightCallCount++);
      expect(rightCallCount, equals(1));
      expect(identical(right, retRight), isTrue);

      int leftCallCount = 0;
      final retLeft = left.tap((r) => leftCallCount++);
      expect(leftCallCount, equals(0));
      expect(identical(left, retLeft), isTrue);
    });

    test('tapLeft executes on Left exactly once and preserves identity', () {
      final Either<String, int> right = Right(10);
      final Either<String, int> left = Left('err');

      int leftCallCount = 0;
      final retLeft = left.tapLeft((l) => leftCallCount++);
      expect(leftCallCount, equals(1));
      expect(identical(left, retLeft), isTrue);

      int rightCallCount = 0;
      final retRight = right.tapLeft((l) => rightCallCount++);
      expect(rightCallCount, equals(0));
      expect(identical(right, retRight), isTrue);
    });

    test('ensure validates Right values and preserves instances appropriately', () {
      final Either<String, int> right = Right(10);
      final Either<String, int> left = Left('err');

      final valid = right.ensure((r) => r > 5, () => 'too small');
      final invalid = right.ensure((r) => r > 15, () => 'too small');
      final ensureLeft = left.ensure((r) => r > 5, () => 'too small');

      expect(valid.isRight, isTrue);
      expect(identical(valid, right), isTrue); // preserves original Right instance
      
      expect(invalid.isLeft, isTrue);
      expect(invalid.fold((l) => l, (_) => ''), equals('too small'));
      
      expect(identical(ensureLeft, left), isTrue); // existing Left remains unchanged
    });

    test('orElse recovers from Left', () {
      final Either<String, int> right = Right(10);
      final Either<String, int> left = Left('err');

      final recovered = left.orElse((l) => Right(99));
      final unchanged = right.orElse((l) => Right(99));
      final stillLeft = left.orElse((l) => Left('new err'));

      expect(recovered.getOrElse((_) => 0), equals(99));
      expect(unchanged.getOrElse((_) => 0), equals(10));
      expect(stillLeft.fold((l) => l, (_) => ''), equals('new err'));
    });

    test('sequence executes sequentially and short-circuits on first failure', () {
      final Either<String, int> right1 = Right(1);
      final Either<String, int> right2 = Right(2);
      final Either<String, int> left1 = Left('err1');
      final Either<String, int> left2 = Left('err2');

      final empty = Either.sequence<String, int>([]);
      final single = Either.sequence([right1]);
      final success = Either.sequence([right1, right2]);
      final fail1 = Either.sequence([right1, left1, right2]);
      final fail2 = Either.sequence([left1, left2]);

      expect(empty.getOrElse((_) => [99]), isEmpty);
      expect(single.getOrElse((_) => []), equals([1]));
      expect(success.getOrElse((_) => []), equals([1, 2]));
      expect(fail1.fold((l) => l, (_) => ''), equals('err1')); // short circuits
      expect(fail2.fold((l) => l, (_) => ''), equals('err1')); // first failure wins
    });

    test('traverse maps in order and short-circuits on first Left', () {
      final empty = Either.traverse<String, int, int>([], (i) => Right(i * 2));
      expect(empty.getOrElse((_) => [99]), isEmpty);

      final items = [1, 2, 3];
      final success = Either.traverse<String, int, int>(
        items,
        (i) => Right(i * 2),
      );
      
      final executedItems = <int>[];
      final failure = Either.traverse<String, int, int>(
        items,
        (i) {
          executedItems.add(i);
          return i == 2 ? Left('err on 2') : Right(i * 2);
        },
      );

      expect(success.getOrElse((_) => []), equals([2, 4, 6]));
      expect(failure.fold((l) => l, (_) => ''), equals('err on 2'));
      expect(executedItems, equals([1, 2])); // Stops exactly at the first failure
    });
  });
}
