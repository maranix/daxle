# StreamSplitter

`StreamSplitter` duplicates a single stream into multiple independent, identical copies.

## Why use StreamSplitter?

Standard broadcast streams (`asBroadcastStream()`) drop events if there are no listeners, and new listeners miss earlier events. `StreamSplitter` ensures that every split stream gets all events from the original stream, buffering them if necessary until they are consumed.

## Example

```dart
import 'package:daxle/daxle.dart';

void main() async {
  final originalStream = Stream.fromIterable([1, 2, 3]);
  final splitter = StreamSplitter(originalStream);

  final copy1 = splitter.split();
  final copy2 = splitter.split();

  // Close the splitter to let it know we won't request more copies
  splitter.close();

  copy1.listen((v) => print('Copy 1 received: $v'));
  
  // Even if we wait, copy2 will still get all events
  await Future.delayed(const Duration(seconds: 1));
  copy2.listen((v) => print('Copy 2 received: $v'));
}
```

## When to use it
- **Multiple Consumers:** Sending the same stream of data to multiple distinct systems (e.g., logging to a file and updating the UI).
- **Guaranteed Delivery:** When multiple components need the full history of a stream without missing early events.
