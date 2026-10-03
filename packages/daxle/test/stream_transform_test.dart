import 'dart:async';

import 'package:daxle/async.dart';
import 'package:test/test.dart';

void main() {
  group('Stream Transform Utilities (re-exported via daxle)', () {
    test('merge interleaves stream events', () async {
      final a = Stream.fromIterable([1, 3, 5]);
      final b = Stream.fromIterable([2, 4, 6]);

      final merged = a.merge(b);
      final results = await merged.toList();

      expect(results, containsAllInOrder([1, 3, 5]));
      expect(results, containsAllInOrder([2, 4, 6]));
      expect(results.length, 6);
    });

    test('combineLatest combines latest values from multiple streams', () async {
      final controllerA = StreamController<int>();
      final controllerB = StreamController<String>();

      final combined = controllerA.stream.combineLatest(
        controllerB.stream,
        (a, b) => '$a:$b',
      );

      final events = <String>[];
      final subscription = combined.listen(events.add);

      controllerA.add(1);
      controllerB.add('A');
      await pumpEventQueue();

      controllerA.add(2);
      await pumpEventQueue();

      controllerB.add('B');
      await pumpEventQueue();

      expect(events, ['1:A', '2:A', '2:B']);

      await subscription.cancel();
      await controllerA.close();
      await controllerB.close();
    });

    test('scan accumulates intermediate values', () async {
      final stream = Stream.fromIterable([1, 2, 3, 4]);
      final scanned = stream.scan<int>(0, (acc, val) => acc + val);

      expect(await scanned.toList(), [1, 3, 6, 10]);
    });

    test('whereType filters items by runtime type', () async {
      final stream = Stream<Object?>.fromIterable([1, 'two', 3, 'four', 5.0]);
      final strings = stream.whereType<String>();

      expect(await strings.toList(), ['two', 'four']);
    });

    test('tap allows inspecting stream elements with side effects', () async {
      final inspected = <int>[];
      final stream = Stream.fromIterable([10, 20, 30]).tap(inspected.add);

      final collected = await stream.toList();
      expect(collected, [10, 20, 30]);
      expect(inspected, [10, 20, 30]);
    });

    test('switchMap forwards values from the latest stream', () async {
      final controller = StreamController<int>();

      final switched = controller.stream.switchMap((val) {
        return Stream.fromIterable(['$val-A', '$val-B']);
      });

      final results = <String>[];
      final sub = switched.listen(results.add);

      controller.add(1);
      await pumpEventQueue();
      controller.add(2);
      await pumpEventQueue();

      expect(results, ['1-A', '1-B', '2-A', '2-B']);

      await sub.cancel();
      await controller.close();
    });
  });
}
