# FutureGroup

`FutureGroup` provides a dynamic way to manage multiple concurrent asynchronous tasks. It acts as a collection of futures that waits for all added futures to complete.

## Why use FutureGroup?

Standard Dart provides `Future.wait`, which is excellent when you know all your futures upfront. However, if you need to spawn and track tasks dynamically over time, `Future.wait` falls short. 

`FutureGroup` solves this by letting you add tasks continuously and then signal when you're finished.

## Example

```dart
import 'package:daxle/daxle.dart';

void main() async {
  final group = FutureGroup<int>();

  // Dynamically add tasks
  group.add(Future.delayed(const Duration(seconds: 1), () => 1));
  group.add(Future.delayed(const Duration(seconds: 2), () => 2));

  // Signal that no more tasks will be added
  group.close();

  // Wait for all tasks to complete
  final results = await group.future;
  print(results); // [1, 2]
}
```

## When to use it
- **Dynamic Task Queues:** When processing a stream of events where each event spawns an async task.
- **Batched Operations:** When downloading or processing multiple files concurrently but discovering the files dynamically.
