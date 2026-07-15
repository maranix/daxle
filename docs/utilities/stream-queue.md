# StreamQueue

`StreamQueue` turns a push-based stream into a pull-based queue, allowing you to explicitly request the next event when you are ready for it.

## Why use StreamQueue?

Streams in Dart push events to listeners as quickly as they are generated. If processing an event takes time, you might miss events or need complex buffering. `StreamQueue` solves this by letting you safely pause and request the next event (`next`) only when you are done processing the current one.

## Example

```dart
import 'package:daxle/daxle.dart';

void main() async {
  final stream = Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(5);
  final queue = StreamQueue(stream);

  print('Pulling first event...');
  final first = await queue.next;
  print(first); // 0

  print('Simulating heavy work...');
  await Future.delayed(const Duration(seconds: 2));

  print('Pulling second event...');
  final second = await queue.next;
  print(second); // 1

  await queue.cancel();
}
```

## When to use it
- **Throttled Processing:** Processing heavy data pipelines where you cannot handle events as fast as they arrive.
- **Stateful Parsing:** Parsing protocols or chunked data where the parsing logic changes based on the previous event.
