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
  });
}
