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

    test('mapLeft transforms errors', () async {
      final taskRight = TaskEither<String, int>.right(42).mapLeft((err) => 'mapped $err');
      final taskLeft = TaskEither<String, int>.left('err').mapLeft((err) => 'mapped $err');

      expect(await taskRight.run(), equals(Right(42)));
      expect(await taskLeft.run(), equals(Left('mapped err')));
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

    test('tap and tapLeft executes side effects', () async {
      int tapCount = 0;
      int tapLeftCount = 0;
      int? tappedVal;
      String? tappedLeftErr;

      final taskRight = TaskEither<String, int>.right(42).tap((v) {
        tapCount++;
        tappedVal = v;
      }).tapLeft((err) {
        tapLeftCount++;
        tappedLeftErr = err;
      });

      final resRight = await taskRight.run();
      expect(resRight, equals(Right(42)));
      expect(tapCount, equals(1));
      expect(tappedVal, equals(42));
      expect(tapLeftCount, equals(0));
      expect(tappedLeftErr, isNull);

      // Async tap
      int asyncTapCount = 0;
      final taskRightAsync = TaskEither<String, int>.right(42).tap((v) async {
        await Future.delayed(const Duration(milliseconds: 1));
        asyncTapCount++;
      });
      await taskRightAsync.run();
      expect(asyncTapCount, equals(1));

      final taskLeft = TaskEither<String, int>.left('err').tap((v) {
        tapCount++;
      }).tapLeft((err) {
        tapLeftCount++;
        tappedLeftErr = err;
      });

      final resLeft = await taskLeft.run();
      expect(resLeft, equals(Left('err')));
      expect(tapCount, equals(1)); // remained 1 from previous run
      expect(tapLeftCount, equals(1));
      expect(tappedLeftErr, equals('err'));
    });

    test('ensure validates value (sync and async)', () async {
      final taskRight = TaskEither<String, int>.right(42);

      final ok = taskRight.ensure((v) => v > 40, () => 'too small');
      final fail = taskRight.ensure((v) => v < 40, () => 'too big');

      expect(await ok.run(), equals(Right(42)));
      expect(await fail.run(), equals(Left('too big')));

      // Async ensure
      final okAsync = taskRight.ensure((v) async {
        await Future.delayed(const Duration(milliseconds: 1));
        return v > 40;
      }, () => 'too small');
      final failAsync = taskRight.ensure((v) async {
        await Future.delayed(const Duration(milliseconds: 1));
        return v < 40;
      }, () => 'too big');

      expect(await okAsync.run(), equals(Right(42)));
      expect(await failAsync.run(), equals(Left('too big')));

      final taskLeft = TaskEither<String, int>.left('original error');
      final leftEnsure = taskLeft.ensure((v) => v > 40, () => 'too small');
      expect(await leftEnsure.run(), equals(Left('original error')));

      final leftEnsureAsync = taskLeft.ensure((v) async => v > 40, () => 'too small');
      expect(await leftEnsureAsync.run(), equals(Left('original error')));
    });

    test('sequence executes tasks sequentially and short-circuits', () async {
      final executionOrder = <int>[];

      TaskEither<String, int> makeTask(int id, Either<String, int> result) {
        return TaskEither(() async {
          executionOrder.add(id);
          return result;
        });
      }

      final tasksOk = [
        makeTask(1, Right(10)),
        makeTask(2, Right(20)),
        makeTask(3, Right(30)),
      ];

      final resOk = await TaskEither.sequence(tasksOk).run();
      expect(resOk.isRight, isTrue);
      expect(resOk.fold((l) => <int>[], (r) => r), equals([10, 20, 30]));
      expect(executionOrder, equals([1, 2, 3]));

      executionOrder.clear();

      final tasksFail = [
        makeTask(1, Right(10)),
        makeTask(2, Left('err')),
        makeTask(3, Right(30)),
      ];

      final resFail = await TaskEither.sequence(tasksFail).run();
      expect(resFail.isLeft, isTrue);
      expect(resFail.fold((l) => l, (r) => null), equals('err'));
      expect(executionOrder, equals([1, 2])); // task 3 should NOT execute
    });

    test('traverse maps and executes sequentially and short-circuits', () async {
      final executionOrder = <int>[];

      final items = [1, 2, 3];
      final resOk = await TaskEither.traverse(items, (item) {
        return TaskEither(() async {
          executionOrder.add(item);
          return Right(item * 10);
        });
      }).run();

      expect(resOk.isRight, isTrue);
      expect(resOk.fold((l) => <int>[], (r) => r), equals([10, 20, 30]));
      expect(executionOrder, equals([1, 2, 3]));

      executionOrder.clear();

      final resFail = await TaskEither.traverse(items, (item) {
        return TaskEither(() async {
          executionOrder.add(item);
          if (item == 2) {
            return Left('err');
          }
          return Right(item * 10);
        });
      }).run();

      expect(resFail.isLeft, isTrue);
      expect(resFail.fold((l) => l, (r) => null), equals('err'));
      expect(executionOrder, equals([1, 2])); // 3 should NOT execute
    });
  });
}
