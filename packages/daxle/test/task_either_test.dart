import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('TaskEither', () {
    test('constructors and basic run', () async {
      final taskRight = TaskEither.right(42);
      final taskLeft = TaskEither.left('err');

      expect(await taskRight.run(), equals(Right(42)));
      expect(await taskLeft.run(), equals(Left('err')));
    });

    test('fromFuture success and failure', () async {
      final taskRight = TaskEither.fromFuture(
        () async => 42,
        (e, st) => 'err: $e',
      );
      final taskLeft = TaskEither.fromFuture(
        () async => throw Exception('oops'),
        (e, st) => 'err',
      );

      expect(await taskRight.run(), equals(Right(42)));
      expect(await taskLeft.run(), equals(Left('err')));
    });

    test('map and flatMap', () async {
      final task = TaskEither.right(
        10,
      ).map((r) => r * 2).flatMap((r) => TaskEither.right(r + 5));

      expect(await task.run(), equals(Right(25)));
    });

    test('orElse fallback', () async {
      final task = TaskEither<String, int>.left(
        'error',
      ).orElse((l) => TaskEither.right(42));

      expect(await task.run(), equals(Right(42)));
    });

    test('fold projects values', () async {
      final taskRight = TaskEither<String, int>.right(42);
      final taskLeft = TaskEither<String, int>.left('err');

      expect(
        await taskRight.fold((l) => 'L: $l', (r) => 'R: $r'),
        equals('R: 42'),
      );
      expect(
        await taskLeft.fold((l) => 'L: $l', (r) => 'R: $r'),
        equals('L: err'),
      );
    });
  });
}
