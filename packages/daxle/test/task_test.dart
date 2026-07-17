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
  });
}
