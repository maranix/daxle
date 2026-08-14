import 'package:test/test.dart';
import 'package:daxle/daxle.dart';

void main() {
  group('Task', () {
    test('defers execution until run is called', () async {
      var executed = false;
      final task = Task(() async {
        executed = true;
        return 42;
      });

      expect(executed, isFalse);
      final result = await task.run();
      expect(executed, isTrue);
      expect(result, 42);
    });

    test('map transforms the value', () async {
      final task = Task(() async => 21).map((x) => x * 2);
      expect(await task.run(), 42);
    });

    test('flatMap chains computations', () async {
      final task = Task(() async => 21).flatMap((x) => Task(() async => x * 2));
      expect(await task.run(), 42);
    });

    test('tap executes side effects without modifying value', () async {
      var sideEffect = 0;
      final task = Task(() async => 42).tap((x) {
        sideEffect = x;
      });

      expect(await task.run(), 42);
      expect(sideEffect, 42);
    });

    test('sequence executes tasks sequentially', () async {
      final executions = <int>[];
      final tasks = [
        Task(() async {
          executions.add(1);
          return 'a';
        }),
        Task(() async {
          executions.add(2);
          return 'b';
        }),
      ];

      final task = Task.sequence(tasks);
      expect(executions, isEmpty);

      final result = await task.run();
      expect(executions, [1, 2]);
      expect(result, ['a', 'b']);
    });

    test('traverse maps and executes tasks sequentially', () async {
      final executions = <int>[];
      final items = [1, 2];

      final task = Task.traverse(items, (int item) {
        return Task(() async {
          executions.add(item);
          return item.toString();
        });
      });

      expect(executions, isEmpty);

      final result = await task.run();
      expect(executions, [1, 2]);
      expect(result, ['1', '2']);
    });

    test('propagates exceptions natively', () async {
      final task = Task(() async => throw Exception('test error'));
      expect(() => task.run(), throwsA(isA<Exception>()));
    });

    test('map preserves laziness', () async {
      bool executed = false;

      final task = Task(() async => 42).map((v) {
        executed = true;
        return v + 1;
      });

      expect(executed, false);

      await task.run();

      expect(executed, true);
    });

    test('map propagates sync exception', () async {
      final task = Task(() async => 42).map((_) => throw Exception());

      expect(task.run(), throwsException);
    });

    test('flatMap propagates sync exception', () async {
      final task = Task(() async => 42).flatMap((_) => throw Exception());

      expect(task.run(), throwsException);
    });

    test('flatMap propagates async exception', () async {
      final task = Task(() async => 42).flatMap(
        (_) => Task(() async {
          throw Exception();
        }),
      );

      expect(task.run(), throwsException);
    });

    test('map remains lazy', () async {
      var count = 0;

      final task = Task(() async => ++count).map((v) => v);

      expect(count, 0);

      await task.run();

      expect(count, 1);
    });

    test('single run() on chained pipeline executes root exactly once', () async {
      var rootRunCount = 0;
      var map1Count = 0;
      var map2Count = 0;
      var flatMapCount = 0;
      var tapCount = 0;

      final rootTask = Task(() async {
        rootRunCount++;
        return 10;
      });

      final pipeline = rootTask
          .map((x) {
            map1Count++;
            return x + 5;
          })
          .map((y) {
            map2Count++;
            return y * 2;
          })
          .flatMap((z) {
            flatMapCount++;
            return Task(() async => z + 100);
          })
          .tap((v) {
            tapCount++;
          });

      // Before run, nothing is executed
      expect(rootRunCount, equals(0));
      expect(map1Count, equals(0));
      expect(map2Count, equals(0));
      expect(flatMapCount, equals(0));
      expect(tapCount, equals(0));

      // Call run() ONCE
      final result1 = await pipeline.run();
      expect(result1, equals(130));

      // Each step executed EXACTLY ONCE
      expect(rootRunCount, equals(1));
      expect(map1Count, equals(1));
      expect(map2Count, equals(1));
      expect(flatMapCount, equals(1));
      expect(tapCount, equals(1));

      // Calling run() a SECOND time re-executes the pipeline
      final result2 = await pipeline.run();
      expect(result2, equals(130));

      expect(rootRunCount, equals(2));
      expect(map1Count, equals(2));
      expect(map2Count, equals(2));
      expect(flatMapCount, equals(2));
      expect(tapCount, equals(2));
    });

    test('Concurrency mode getters', () {
      expect(Concurrency.sequential.isSequential, isTrue);
      expect(Concurrency.sequential.isUnbounded, isFalse);
      expect(Concurrency.sequential.isBounded, isFalse);

      expect(Concurrency.unbounded.isSequential, isFalse);
      expect(Concurrency.unbounded.isUnbounded, isTrue);
      expect(Concurrency.unbounded.isBounded, isFalse);

      const bounded = Concurrency.bounded(5);
      expect(bounded.isSequential, isFalse);
      expect(bounded.isUnbounded, isFalse);
      expect(bounded.isBounded, isTrue);
      expect(bounded.poolSize, equals(5));
    });

    test('sequence with empty input returns empty list', () async {
      final task = Task.sequence<int>([]);
      final result = await task.run();
      expect(result, isEmpty);
    });

    test('sequence with Concurrency.sequential mode runs 1 by 1', () async {
      final activeTasks = <int>[];
      var maxConcurrent = 0;

      Task<int> makeTask(int id) {
        return Task(() async {
          activeTasks.add(id);
          if (activeTasks.length > maxConcurrent) {
            maxConcurrent = activeTasks.length;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
          activeTasks.remove(id);
          return id;
        });
      }

      final task = Task.sequence(
        [makeTask(1), makeTask(2), makeTask(3)],
        mode: .sequential,
      );
      final result = await task.run();

      expect(result, equals([1, 2, 3]));
      expect(maxConcurrent, equals(1));
    });

    test('sequence with Concurrency.unbounded mode runs all simultaneously', () async {
      final activeTasks = <int>[];
      var maxConcurrent = 0;

      Task<int> makeTask(int id) {
        return Task(() async {
          activeTasks.add(id);
          if (activeTasks.length > maxConcurrent) {
            maxConcurrent = activeTasks.length;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
          activeTasks.remove(id);
          return id;
        });
      }

      final task = Task.sequence(
        [makeTask(1), makeTask(2), makeTask(3)],
        mode: .unbounded,
      );
      final result = await task.run();

      expect(result, equals([1, 2, 3]));
      expect(maxConcurrent, equals(3));
    });

    test('sequence with Concurrency.bounded(2) processes in chunks of 2', () async {
      final activeTasks = <int>[];
      var maxConcurrent = 0;

      Task<int> makeTask(int id) {
        return Task(() async {
          activeTasks.add(id);
          if (activeTasks.length > maxConcurrent) {
            maxConcurrent = activeTasks.length;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
          activeTasks.remove(id);
          return id;
        });
      }

      final task = Task.sequence(
        [makeTask(1), makeTask(2), makeTask(3), makeTask(4), makeTask(5)],
        mode: .bounded(2),
      );
      final result = await task.run();

      expect(result, equals([1, 2, 3, 4, 5]));
      expect(maxConcurrent, equals(2));
    });

    test('sequence propagates exception eagerly in bounded mode', () async {
      final executed = <int>[];

      final tasks = [
        Task(() async {
          executed.add(1);
          return 1;
        }),
        Task(() async {
          executed.add(2);
          throw StateError('chunk 1 error');
        }),
        Task(() async {
          executed.add(3);
          return 3;
        }),
      ];

      final task = Task.sequence(tasks, mode: .bounded(2));
      expect(() => task.run(), throwsA(isA<StateError>()));
    });

    test('traverse maps elements and respects concurrency mode', () async {
      final items = [10, 20, 30];
      final task = Task.traverse(
        items,
        (n) => Task(() async => 'num:$n'),
        mode: .bounded(2),
      );

      final result = await task.run();
      expect(result, equals(['num:10', 'num:20', 'num:30']));
    });
  });
}
