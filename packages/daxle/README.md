# daxle

[![Pub Version](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle)
[![Pub Points](https://img.shields.io/pub/points/daxle.svg)](https://pub.dev/packages/daxle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A lightweight, type-safe functional programming toolkit for Dart. Designed to replace unsafe patterns (like throwing exceptions or abusing `null`) with explicit, declarative types and pipelines.

Inspired by functional features in Rust, Haskell, and Scala.

---

## What's New in v3.0 🚀

Version 3.0 represents a complete architectural review focused on producing a small, coherent, production-quality functional programming library for Dart.

*   **Removed overlapping types**: `Result<T, E>`, `Pipeline<T>`, and `AsyncPipeline<T>` have been removed to ensure exactly one way to model explicit success/failure and lazy computations.
*   **Sealed Option & Either**: `Option` and `Either` remain the core sealed classes for explicit control flow using compile-time exhaustive switch-matching.
*   **Added Task**: Introduces lazy, asynchronous computations (`Future<T>`) without explicit failures.
*   **Enhanced TaskEither**: Added powerful combinators (`sequence`, `traverse`, `bimap`, `tap`, `ensure`) for lazy, asynchronous computations that can fail (`Future<Either<L, R>>`).
*   **Unit**: Represents the absence of a value, allowing type-safe generic returns.
*   **Standardized API**: Consistent use of `fold` for value transformations and exhaustive `switch` for explicit branching.

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  daxle: ^3.0.0
```

Then, run:

```bash
dart pub get
```

---

## Core Types

### 1. `Option<T>`
An alternative to nullable values (`T?`). Represents either the presence of a value (`Some`) or the absence of a value (`None`).

```dart
import 'package:daxle/daxle.dart';

void main() {
  final Option<int> someValue = .some(42);
  final Option<int> noValue = const .none();
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

### 2. `Either<L, R>`
Represents a value of one of two possible types. By convention, `Right` is success/expected and `Left` is error/failure.

```dart
import 'package:daxle/daxle.dart';

Either<String, int> divide(int a, int b) {
  if (b == 0) return const .left('Cannot divide by zero');
  return .right(a ~/ b);
}

void main() {
  final result = divide(10, 2);

  // Construct based on boolean condition:
  final resultCond = .cond(true, 5, 'Cannot divide by zero');

  // Check state
  if (result.isRight) {
    print('Successful division!');
  }

  // Fold to extract values safely
  final message = result.fold(
    (leftError) => 'Failure: $leftError',
    (rightVal) => 'Result: $rightVal',
  );
}
```

### 3. `Task<T>`
Represents a **lazy, asynchronous computation** that produces a value of type `T`.
*   **Lazy Execution**: `Task` defers execution until `.run()` is called.
*   **No Explicit Failures**: Exceptions propagate naturally. For explicit error handling, use `TaskEither`.

```dart
import 'package:daxle/daxle.dart';

void main() async {
  final task = Task(() async {
    print('Fetching data...');
    return 42;
  }).map((x) => x * 2);

  // The computation hasn't started yet.
  
  final result = await task.run(); // Now it runs.
  print(result); // 84
}
```

### 4. `TaskEither<L, R>`
Represents a **lazy, asynchronous computation** that returns an `Either<L, R>`. It provides significant advantages over a raw `Future<Either<L, R>>`:
*   **Lazy Execution**: `TaskEither` is a lazy blueprint. It does not run until `.run()` is called, allowing easy retries or fallbacks via `.orElse`.
*   **Monadic Error Short-Circuiting**: `TaskEither` embeds the `Either` state at each step. If a step resolves to a `Left`, subsequent steps are short-circuited.
*   **Linear Chaining**: Allows chaining dependent async operations via `flatMap` without nesting `await` and `fold` blocks.
*   **Exception Guarding**: Automatically catches runtime exceptions and maps them to a safe `Left(L)`.

```dart
import 'package:daxle/daxle.dart';

TaskEither<String, String> fetchUser(int id) => .fromFuture(
  () async => 'User #$id',
  (err, _) => 'User not found',
);

TaskEither<String, String> fetchConfig(String role) => .fromFuture(
  () async => 'Config for $role',
  (err, _) => 'Config not found',
);

void main() async {
  // Chain dependent async computations flatly:
  final task = fetchUser(42)
      .flatMap((user) => fetchConfig(user));

  final Either<String, String> result = await task.run();
}
```

### 5. `Unit`
A singleton type containing exactly one value: `unit`. Used in functional programming to represent the absence of a meaningful value in generic constructs (like returning `Either<String, Unit>`).

```dart
import 'package:daxle/daxle.dart';

Either<String, Unit> saveRecord(String data) {
  try {
    // Save logic...
    return const .right(unit);
  } catch (e) {
    return .left('Failed to save: $e');
  }
}
```

### 6. Async Utilities
Provides re-exported utilities from `package:async` to simplify asynchronous control flow and stream handling:

*   **Future Utilities**:
    *   `FutureGroup`: A collection of futures that waits for all added futures to complete.
    *   `AsyncCache`: Caches the results of asynchronous operations.
    *   `AsyncMemoizer`: Memorizes the result of an asynchronous closure to run it only once.
*   **Stream Utilities**:
    *   `StreamZip`: Combines multiple streams into a single stream of zipped lists.
    *   `StreamQueue`: Simplifies pull-based stream consumption.
    *   `StreamGroup`: Merges multiple streams into a single output stream.
    *   `StreamSplitter`: Splits a stream into multiple identical, independent copies.

```dart
import 'package:daxle/daxle.dart';

void main() async {
  final streamA = Stream.fromIterable([1, 2]);
  final streamB = Stream.fromIterable(['A', 'B']);
  
  // StreamZip is re-exported from package:async
  final zipped = StreamZip([streamA, streamB]);
  
  await for (final pair in zipped) {
    print(pair); // [1, 'A'], then [2, 'B']
  }
}
```

---


## Contributing

Contributions are welcome! This package is part of the `daxle` monorepo workspace. Please see the root repository for workspace contribution guidelines.

## License

`daxle` is released under the [MIT License](LICENSE).