```dart
import 'package:daxle/daxle.dart';

void main() async {
  // 1. Option: Smart constructor converts null -> None() and non-null -> Some(value)
  final Option<int> someValue = Option(42);
  final Option<int> noValue = Option(null);
  final Option<int> fromPred = .fromPredicate(10, (v) => v > 5); // Some(10)

  // Filter option value conditionally:
  final filtered = someValue.filter((v) => v > 100); // None()

  // Transform with map:
  final mapped = someValue.map((v) => 'The answer is $v'); 
  print(mapped); // Some(The answer is 42)

  // Retrieve values safely with fallback:
  final int val = noValue.getOrElse(() => 0); // 0

  // Exhaustive pattern matching (enforced at compile-time):
  final message = switch (someValue) {
    Some(value: final v) => 'Found: $v',
    None() => 'Nothing here',
  };
  print(message);

  // 2. Either: Explicit error handling with lazy evaluation
  final Either<String, int> result = .cond(
    true,
    () => 100,
    () => 'Error occurred',
  );

  result.fold(
    (err) => print('Error: $err'),
    (data) => print('Success: $data'),
  );

  // 3. QueryMap: Zero-cost nested map and embedded list querying
  final payload = {
    'services': {
      'server': {'host': 'https://api.internal', 'port': 8080},
    },
    'users': [
      {'name': 'Alice', 'tags': ['admin', 'dev']},
    ],
  };

  final query = QueryMap(payload);
  final host = query.get<String>('services.server.host'); // 'https://api.internal'
  final firstTag = query.get<String>('users[0].tags[0]'); // 'admin'
  print('Host: $host, First tag: $firstTag');

  // 4. TaskEither: Asynchronous workflows with controlled concurrency
  final tasks = [
    TaskEither<String, int>.right(1),
    TaskEither<String, int>.right(2),
    TaskEither<String, int>.right(3),
  ];

  // Process tasks concurrently in worker batches of 2:
  final batchResult = await TaskEither.sequence(tasks, mode: .bounded(2)).run();
  print('Batch result: $batchResult'); // Right([1, 2, 3])
}
```
