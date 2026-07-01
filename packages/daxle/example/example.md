```dart
import 'package:daxle/daxle.dart';

void main() {
  final Option<int> someValue = .some(42);
  final Option<int> noValue = .none();
  final Option<int> fromNull = .fromNullable(null); // Resolves to None
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
}
```
