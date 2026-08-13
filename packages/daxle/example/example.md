```dart
import 'package:daxle/daxle.dart';

void main() async {
  // Option: Smart constructor converts null -> None() and non-null -> Some(value)
  final Option<int> someValue = Option(42);
  final Option<int> noValue = Option(null);
  final Option<int> fromPred = .fromPredicate(10, (v) => v > 5); // Some(10)

  // Filter option value:
  final filtered = someValue.filter((v) => v > 100); // None

  // Transform with map or flatMap
  final mapped = someValue.map((v) => 'The answer is $v'); 
  print(mapped); // Some(The answer is 42)

  // Retrieve values safely
  final int val = noValue.getOrElse(0); // Returns 0

  // Exhaustive pattern matching (enforced at compile-time!)
  final message = switch (someValue) {
    Some(value: final v) => 'Found: $v',
    None() => 'Nothing here',
  };

  // Either: Explicit error handling
  final Either<String, int> result = .cond(true, 100, 'Error');

  // TaskEither with Controlled Concurrency:
  final tasks = [
    TaskEither<String, int>.right(1),
    TaskEither<String, int>.right(2),
    TaskEither<String, int>.right(3),
  ];

  // Process tasks concurrently in worker batches of 2:
  final batchResult = await TaskEither.sequence(tasks, mode: .bounded(2)).run();
  print(batchResult); // Right([1, 2, 3])
}
```
