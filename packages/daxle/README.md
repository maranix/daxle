# daxle

[![Pub Version](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle)
[![Pub Points](https://img.shields.io/pub/points/daxle.svg)](https://pub.dev/packages/daxle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A lightweight, type-safe functional programming toolkit for Dart. Designed to replace unsafe patterns (like throwing exceptions or abusing `null`) with explicit, declarative types and pipelines.

Inspired by functional features in Rust, Haskell, and Scala.

---

## What's New in v2.0 🚀

Version 2.0 represents a complete API redesign to leverage modern Dart features (such as **sealed classes**, **pattern matching**, and **records**).

*   **Removed types**: `Result<T, E>` and `Lazy<T>` have been removed to stream-line error handling and composition.
*   **Sealed Option & Either**: `Option` and `Either` are now sealed classes. You can utilize compile-time exhaustive switch-matching.
*   **Added TaskEither**: Introduces lazy, asynchronous computations that can fail (`Future<Either<L, R>>`), ensuring safe and composable async logic.
*   **Added Pipelines**: `Pipeline` (synchronous) and `AsyncPipeline` (asynchronous) provide type-safe deferred operation chaining, logging/observability taps, error recovery, and concurrent execution.
*   **Added Unit**: Represents the absence of a value, allowing type-safe generic returns.

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  daxle: ^2.0.0
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
  final Option<int> noValue = .none();
  final Option<int> fromNull = .fromNullable(null); // Resolves to None

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

### 3. `TaskEither<L, R>`
Represents a **lazy, asynchronous computation** that returns an `Either<L, R>`. It provides significant advantages over a raw `Future<Either<L, R>>` and [AsyncPipeline]:
*   **Lazy Execution**: Both `TaskEither` and [AsyncPipeline] are lazy blueprints. They do not run until `.run()` is called, allowing easy retries or fallbacks via `.orElse`.
*   **Monadic Error Short-Circuiting**: Unlike [AsyncPipeline] (which relies on standard exceptions propagating until caught by `recover`), `TaskEither` embeds the `Either` state at each step. If a step resolves to a `Left`, subsequent steps are short-circuited.
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

### 4. `Pipeline<T>` & `AsyncPipeline<T>`
Deferred, type-safe pipelines to chain operations sequentially. Supports logging (`tap`), error translation (`mapError`), fallback recovery (`recover`/`recoverWith`), cleanup (`finalize`), and concurrent combinations (`zip`).

```dart
import 'package:daxle/daxle.dart';

void main() async {
  // 1. Synchronous Pipeline
  final syncVal = Pipeline(() => 10)
      .pipe((x) => x * 2)
      .tap((x) => print('Stage: $x')) // Observational side-effect
      .recover((err, stack) => -1)    // Recovers if any error occurred
      .run();                         // Pipeline evaluates lazily here

  // 2. Asynchronous Pipeline
  final asyncVal = await AsyncPipeline(() => Future.value(100))
      .pipe((x) async => x + 50)
      .run();

  // 3. Concurrent pipelines execution
  final p1 = AsyncPipeline(() => Future.value(10));
  final p2 = AsyncPipeline(() => Future.value(20));

  final zipped = p1.zip(p2, (a, b) => a + b);
  final sum = await zipped.run(); // Concurrently waits and combines: 30
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

### 6. Record Extensions
Provides built-in utility extensions on Dart 3 `Record` tuples of size 2, 3, 4, and 5 containing [Option], [Either], or [TaskEither]. 

These extensions allow you to zip, map, flatMap, and filter values directly on the tuples:
*   **`.zipped()`**: Combines multiple instances into a single instance containing a record of values (concurrently runs [TaskEither] tasks).
*   **`.map()`**: Transforms the zipped record of values when all are successful.
*   **`.flatMap()`**: Chains a new computation when all are successful.
*   **`.filter()`** (Option only): Retains the record only if it satisfies a predicate.

```dart
// 1. Zipping: Option<(int, String)>
final Option<(int, String)> opt = (Option.some(1), Option.some('a')).zipped();

// 2. Mapping: Either<String, int>
final Either<String, int> either = (Right(10), Right(20)).map((a, b) => a + b);

// 3. FlatMapping concurrently: TaskEither<String, Order>
final TaskEither<String, Order> task = (getUser(1), getProfile(1))
    .flatMap((user, profile) => createOrder(user, profile));
```

---


## Contributing

Contributions are welcome! This package is part of the `daxle` monorepo workspace. Please see the root repository for workspace contribution guidelines.

## License

`daxle` is released under the [MIT License](LICENSE).