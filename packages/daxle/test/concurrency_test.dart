import 'package:daxle/daxle.dart';
import 'package:test/test.dart';

void main() {
  group('Concurrency', () {
    group('getters and constructors', () {
      test('sequential getters', () {
        const mode = Concurrency.sequential;
        expect(mode.isSequential, isTrue);
        expect(mode.isUnbounded, isFalse);
        expect(mode.isBounded, isFalse);
        expect(mode.poolSize, equals(1));
      });

      test('unbounded getters', () {
        const mode = Concurrency.unbounded;
        expect(mode.isSequential, isFalse);
        expect(mode.isUnbounded, isTrue);
        expect(mode.isBounded, isFalse);
        expect(mode.poolSize, equals(0));
      });

      test('bounded getters', () {
        const mode = Concurrency.bounded(4);
        expect(mode.isSequential, isFalse);
        expect(mode.isUnbounded, isFalse);
        expect(mode.isBounded, isTrue);
        expect(mode.poolSize, equals(4));
      });

      test('negative poolSize throws ArgumentError in process', () {
        const mode = Concurrency.bounded(-1);
        expect(() => mode.process([]), throwsArgumentError);
      });
    });

    group('empty and single item processing', () {
      test('empty task list returns empty list across all modes', () async {
        expect(await Concurrency.sequential.process([]), isEmpty);
        expect(await Concurrency.unbounded.process([]), isEmpty);
        expect(await const Concurrency.bounded(3).process([]), isEmpty);
      });

      test('single item task returns single result across all modes', () async {
        final task = [() async => 42];
        expect(await Concurrency.sequential.process(task), equals([42]));
        expect(await Concurrency.unbounded.process(task), equals([42]));
        expect(await const Concurrency.bounded(3).process(task), equals([42]));
      });
    });

    group('execution modes & concurrency limits', () {
      test('sequential mode executes strictly 1 by 1', () async {
        final activeTasks = <int>[];
        var maxConcurrent = 0;

        Future<int> makeTask(int id) async {
          activeTasks.add(id);
          if (activeTasks.length > maxConcurrent) {
            maxConcurrent = activeTasks.length;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
          activeTasks.remove(id);
          return id;
        }

        final tasks = [
          () => makeTask(1),
          () => makeTask(2),
          () => makeTask(3),
        ];

        final result = await Concurrency.sequential.process(tasks);
        expect(result, equals([1, 2, 3]));
        expect(maxConcurrent, equals(1));
      });

      test('unbounded mode executes all tasks simultaneously', () async {
        final activeTasks = <int>[];
        var maxConcurrent = 0;

        Future<int> makeTask(int id) async {
          activeTasks.add(id);
          if (activeTasks.length > maxConcurrent) {
            maxConcurrent = activeTasks.length;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
          activeTasks.remove(id);
          return id;
        }

        final tasks = [
          () => makeTask(1),
          () => makeTask(2),
          () => makeTask(3),
          () => makeTask(4),
        ];

        final result = await Concurrency.unbounded.process(tasks);
        expect(result, equals([1, 2, 3, 4]));
        expect(maxConcurrent, equals(4));
      });

      test(
        'bounded(2) processes items in chunks of 2 with exact division',
        () async {
          final activeTasks = <int>[];
          var maxConcurrent = 0;

          Future<int> makeTask(int id) async {
            activeTasks.add(id);
            if (activeTasks.length > maxConcurrent) {
              maxConcurrent = activeTasks.length;
            }
            await Future<void>.delayed(const Duration(milliseconds: 10));
            activeTasks.remove(id);
            return id;
          }

          final tasks = [
            () => makeTask(1),
            () => makeTask(2),
            () => makeTask(3),
            () => makeTask(4),
          ];

          final result = await const Concurrency.bounded(2).process(tasks);
          expect(result, equals([1, 2, 3, 4]));
          expect(maxConcurrent, equals(2));
        },
      );

      test(
        'bounded(2) processes items in chunks of 2 with remainder tail',
        () async {
          final activeTasks = <int>[];
          var maxConcurrent = 0;

          Future<int> makeTask(int id) async {
            activeTasks.add(id);
            if (activeTasks.length > maxConcurrent) {
              maxConcurrent = activeTasks.length;
            }
            await Future<void>.delayed(const Duration(milliseconds: 10));
            activeTasks.remove(id);
            return id;
          }

          final tasks = [
            () => makeTask(1),
            () => makeTask(2),
            () => makeTask(3),
            () => makeTask(4),
            () => makeTask(5),
          ];

          final result = await const Concurrency.bounded(2).process(tasks);
          expect(result, equals([1, 2, 3, 4, 5]));
          expect(maxConcurrent, equals(2));
        },
      );
    });

    group('exception handling & laziness', () {
      test(
        'process propagates exceptions eagerly and halts subsequent execution',
        () async {
          var chunk2Executed = false;

          final tasks = [
            () async => 1,
            () async => throw StateError('chunk 1 failed'),
            () async {
              chunk2Executed = true;
              return 3;
            },
          ];

          expect(
            () => const Concurrency.bounded(2).process(tasks),
            throwsA(isA<StateError>()),
          );
          expect(chunk2Executed, isFalse);
        },
      );

      test('process defers execution of subsequent chunks until previous chunk completes', () async {
        final log = <String>[];

        final tasks = [
          () async {
            log.add('chunk1-start');
            await Future<void>.delayed(const Duration(milliseconds: 10));
            log.add('chunk1-end');
            return 1;
          },
          () async {
            log.add('chunk2-start');
            log.add('chunk2-end');
            return 2;
          },
        ];

        final task = Task(() => const Concurrency.bounded(1).process(tasks));
        expect(log, isEmpty); // lazy before run()

        final results = await task.run();
        expect(results, equals([1, 2]));
        expect(
          log,
          equals(['chunk1-start', 'chunk1-end', 'chunk2-start', 'chunk2-end']),
        );
      });

      test('shouldStop halts sequential execution immediately', () async {
        final executed = <int>[];
        final tasks = [
          () async {
            executed.add(1);
            return 1;
          },
          () async {
            executed.add(2);
            return 2;
          },
          () async {
            executed.add(3);
            return 3;
          },
        ];

        final results = await Concurrency.sequential.process(
          tasks,
          shouldStop: (res) => res == 2,
        );

        expect(results, equals([1, 2]));
        expect(executed, equals([1, 2])); // Task 3 was never called
      });

      test('shouldStop halts bounded worker pool from pulling unstarted jobs', () async {
        final executed = <int>[];
        final tasks = [
          () async {
            executed.add(1);
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return 1;
          },
          () async {
            executed.add(2);
            await Future<void>.delayed(const Duration(milliseconds: 5));
            return 2; // stops queue
          },
          () async {
            executed.add(3);
            return 3;
          },
          () async {
            executed.add(4);
            return 4;
          },
        ];

        final results = await const Concurrency.bounded(2).process(
          tasks,
          shouldStop: (res) => res == 2,
        );

        expect(results, containsAll([1, 2]));
        expect(executed, equals([1, 2])); // Tasks 3 and 4 were never started
      });
    });
  });
}
