# StreamZip

`StreamZip` combines multiple streams into a single stream of lists. It waits for each input stream to emit an event, then bundles them together.

## Why use StreamZip?

When you have multiple independent data sources (e.g., a stream of user actions and a stream of system metrics) and you need to process them together in lockstep, `StreamZip` ensures you always get a paired set of events.

## Example

```dart
import 'package:daxle/daxle.dart';

void main() async {
  final names = Stream.fromIterable(['Alice', 'Bob', 'Charlie']);
  final ages = Stream.fromIterable([25, 30, 35]);

  final zipped = StreamZip([names, ages]);

  await for (final pair in zipped) {
    print('${pair[0]} is ${pair[1]} years old');
  }
  // Output:
  // Alice is 25 years old
  // Bob is 30 years old
  // Charlie is 35 years old
}
```

## When to use it
- **Coordinating Streams:** When downstream logic requires synchronized data from multiple streams.
- **Pagination / Chunking:** Pairing paginated results with their corresponding metadata streams.
