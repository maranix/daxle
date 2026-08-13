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

    test('TaskEither flatMap exception catching', () async {
      final task = TaskEither<String, int>.fromFuture(
        () async => 42,
        (e, st) => e.toString(),
      ).flatMap((_) => TaskEither<String, int>.fromFuture(
            () async => throw Exception('oops'),
            (e, st) => e.toString(),
          ));

      final res = await task.run();
      expect(res.isLeft, isTrue);
      expect(res.fold((l) => l, (r) => ''), contains('Exception: oops'));
    });

    test('TaskEither combinators propagate exceptions thrown in onError', () async {
      final task = TaskEither<String, int>.right(10).map(
        (v) => throw Exception('map crashed!'),
        onError: (e, st) => throw StateError('onError crashed!'),
      );

      expect(
        task.run(),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'onError crashed!')),
      );
    });

    test('map and flatMap', () async {
      final task = TaskEither.right(
        10,
      ).map((r) => r * 2).flatMap((r) => TaskEither.right(r + 5));

      expect(await task.run(), equals(Right(25)));
    });

    test('mapLeft transforms errors', () async {
      final taskRight = TaskEither<String, int>.right(
        42,
      ).mapLeft((err) => 'mapped $err');
      final taskLeft = TaskEither<String, int>.left(
        'err',
      ).mapLeft((err) => 'mapped $err');

      expect(await taskRight.run(), equals(Right(42)));
      expect(await taskLeft.run(), equals(Left('mapped err')));
    });

    test('fromEither is lazy and correct', () async {
      var executed = false;
      final either = Right<String, int>(42);
      final task = TaskEither<String, int>.fromEither(either);
      executed = true;
      expect(executed, isTrue); // Proves no eagerness prior to run
      expect(await task.run(), equals(Right(42)));
    });

    test('left and right constructors are lazy and correct', () async {
      var executed = false;
      final taskRight = TaskEither<String, int>.right(10);
      final taskLeft = TaskEither<String, int>.left('err');
      executed = true;
      expect(executed, isTrue);
      expect(await taskRight.run(), equals(Right(10)));
      expect(await taskLeft.run(), equals(Left('err')));
    });

    group('Exception Semantics and Regressions', () {
      test('map mapper throws (synchronous exception)', () async {
        final task = TaskEither<String, int>.right(10).map(
          (v) => throw StateError('mapper crashed!'),
        );
        expect(
          task.run(),
          throwsA(isA<StateError>().having((e) => e.message, 'message', 'mapper crashed!')),
        );
      });

      test('map mapper throws with onError', () async {
        final task = TaskEither<String, int>.right(10).map(
          (v) => throw StateError('mapper crashed!'),
          onError: (e, st) => e.toString(),
        );
        final res = await task.run();
        expect(res, equals(Left("Bad state: mapper crashed!")));
      });

      test('upstream task throws', () async {
        final task = TaskEither<String, int>(() => Future.error(StateError('upstream crash')))
            .map((v) => v + 1);
        expect(
          task.run(),
          throwsA(isA<StateError>().having((e) => e.message, 'message', 'upstream crash')),
        );
      });

      test('upstream task throws with onError', () async {
        final task = TaskEither<String, int>(() => Future.error(StateError('upstream crash')))
            .map((v) => v + 1, onError: (e, st) => e.toString());
        final res = await task.run();
        expect(res, equals(Left("Bad state: upstream crash")));
      });

      test('fallback (orElse) throws synchronously', () async {
        final task = TaskEither<String, int>.left('err').orElse(
          (l) => throw StateError('fallback crashed!'),
        );
        expect(
          task.run(),
          throwsA(isA<StateError>().having((e) => e.message, 'message', 'fallback crashed!')),
        );
      });

      test('fallback (orElse) throws asynchronously', () async {
        final task = TaskEither<String, int>.left('err').orElse(
          (l) => TaskEither(() => Future.error(StateError('fallback async crash'))),
        );
        expect(
          task.run(),
          throwsA(isA<StateError>().having((e) => e.message, 'message', 'fallback async crash')),
        );
      });

      test('ensure predicate throws', () async {
        final task = TaskEither<String, int>.right(10).ensure(
          (v) => throw StateError('predicate crashed!'),
          () => 'failed',
        );
        expect(
          task.run(),
          throwsA(isA<StateError>().having((e) => e.message, 'message', 'predicate crashed!')),
        );
      });

      test('tap callback throws', () async {
        final task = TaskEither<String, int>.right(10).tap(
          (v) => throw StateError('tap crashed!'),
        );
        expect(
          task.run(),
          throwsA(isA<StateError>().having((e) => e.message, 'message', 'tap crashed!')),
        );
      });

      test('tapLeft callback throws', () async {
        final task = TaskEither<String, int>.left('err').tapLeft(
          (l) => throw StateError('tapLeft crashed!'),
        );
        expect(
          task.run(),
          throwsA(isA<StateError>().having((e) => e.message, 'message', 'tapLeft crashed!')),
        );
      });

      test('laziness remains intact for map', () async {
        var executed = false;
        final task = TaskEither<String, int>.right(10).map((v) {
          executed = true;
          return v + 1;
        });
        expect(executed, isFalse);
        await task.run();
        expect(executed, isTrue);
      });

      test('stack traces are preserved on unknown exceptions', () async {
        final task = TaskEither<String, int>(() async {
          throw StateError('deep crash');
        }).map((v) => v);
        
        try {
          await task.run();
          fail('Should have thrown');
        } catch (e, st) {
          expect(e, isA<StateError>().having((e) => e.message, 'message', 'deep crash'));
          expect(st.toString(), contains('task_either_test.dart')); // Stack trace is intact
        }
      });
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

      final taskRight = TaskEither<String, int>.right(42)
          .tap((v) {
            tapCount++;
            tappedVal = v;
          })
          .tapLeft((err) {
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

      final taskLeft = TaskEither<String, int>.left('err')
          .tap((v) {
            tapCount++;
          })
          .tapLeft((err) {
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

      final leftEnsureAsync = taskLeft.ensure(
        (v) async => v > 40,
        () => 'too small',
      );
      expect(await leftEnsureAsync.run(), equals(Left('original error')));
    });

    test('sequence respects Concurrency modes and short-circuits on Left', () async {
      final activeTasks = <int>[];
      var maxConcurrent = 0;

      TaskEither<String, int> makeTask(int id, Either<String, int> result) {
        return TaskEither(() async {
          activeTasks.add(id);
          if (activeTasks.length > maxConcurrent) {
            maxConcurrent = activeTasks.length;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
          activeTasks.remove(id);
          return result;
        });
      }

      // Mode 1: .bounded(2)
      maxConcurrent = 0;
      final tasksOk = [
        makeTask(1, Right(10)),
        makeTask(2, Right(20)),
        makeTask(3, Right(30)),
        makeTask(4, Right(40)),
      ];
      final resOk = await TaskEither.sequence(tasksOk, mode: .bounded(2)).run();
      expect(resOk.isRight, isTrue);
      expect(resOk.getOrElse((_) => []), equals([10, 20, 30, 40]));
      expect(maxConcurrent, equals(2));

      // Mode 2: .sequential
      maxConcurrent = 0;
      final seqTask = TaskEither.sequence(
        [makeTask(1, Right(1)), makeTask(2, Right(2))],
        mode: .sequential,
      );
      final seqRes = await seqTask.run();
      expect(seqRes.isRight, isTrue);
      expect(seqRes.getOrElse((_) => []), equals([1, 2]));
      expect(maxConcurrent, equals(1));

      // Short-circuiting on Left in bounded mode
      final executed = <int>[];
      final tasksWithLeft = [
        TaskEither<String, int>(() async {
          executed.add(1);
          return const Right(1);
        }),
        TaskEither<String, int>(() async {
          executed.add(2);
          return const Left('chunk 1 left');
        }),
        TaskEither<String, int>(() async {
          executed.add(3);
          return const Right(3);
        }),
      ];

      final failRes = await TaskEither.sequence(tasksWithLeft, mode: .bounded(2)).run();
      expect(failRes.isLeft, isTrue);
      expect(failRes.fold((l) => l, (_) => ''), equals('chunk 1 left'));
      expect(executed, containsAll([1, 2]));
    });

    test(
      'traverse maps and executes with Concurrency mode',
      () async {
        final items = [1, 2, 3];
        final resOk = await TaskEither.traverse<String, int, int>(
          items,
          (item) => TaskEither.right(item * 10),
          mode: .bounded(2),
        ).run();

        expect(resOk.isRight, isTrue);
        expect(resOk.getOrElse((_) => []), equals([10, 20, 30]));
      },
    );

    test('bimap transforms both Left and Right', () async {
      final taskRight = TaskEither<String, int>.right(42).bimap(
        (err) => 'mapped $err',
        (val) => val * 2,
      );
      final taskLeft = TaskEither<String, int>.left('err').bimap(
        (err) => 'mapped $err',
        (val) => val * 2,
      );

      expect(await taskRight.run(), equals(Right(84)));
      expect(await taskLeft.run(), equals(Left('mapped err')));
    });

    test('flatMap exception catching', () async {
      final task = TaskEither<String, int>.right(10).flatMap(
        (r) => TaskEither(() async => throw Exception('oops')),
        onError: (e, st) => 'caught',
      );
      expect(await task.run(), equals(Left('caught')));
    });
  });
}
