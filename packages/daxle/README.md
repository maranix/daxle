# Daxle: Write Safer, Predictable Dart Code

[![Pub Version](https://img.shields.io/pub/v/daxle.svg)](https://pub.dev/packages/daxle)
[![Pub Points](https://img.shields.io/pub/points/daxle.svg)](https://pub.dev/packages/daxle)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Stop writing nested try/catch blocks and imperative state checks. Daxle is a lightweight, type-safe functional programming toolkit that helps you build predictable and composable Dart applications.

**[📚 Read the Official Documentation](https://daxle.maranix.in)**

---

## Why Daxle?

Dart's type system is great, but runtime exceptions and complex asynchronous workflows can still lead to unpredictable bugs. Daxle gives you explicit, declarative types to handle missing values and errors gracefully at compile-time.

### Stop Guessing What Can Fail
Instead of throwing exceptions that might crash your app in production, use `Either<L, R>` to make failures an explicit part of your function signature. The compiler will force you to handle both success and error states.

### Compose Values with Option
While Dart's null safety is excellent, `Option<T>` takes it further by allowing you to chain operations functionally. Replace imperative `if (val != null)` checks with clean, declarative pipelines that gracefully handle missing data.

### Compose Async Workflows Cleanly
Instead of nesting `await` and `try/catch` blocks, use `TaskEither` to chain asynchronous operations. If any step fails, the chain short-circuits gracefully without throwing exceptions.

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  daxle: ^3.1.0
```

Then run:

```bash
dart pub get
```

---

## How It Works

### Handle Missing Values with `Option<T>`
An alternative to nullable values (`T?`). Represents either the presence of a value (`Some`) or the absence of a value (`None`).

```dart
import 'package:daxle/daxle.dart';

void main() {
  final Option<int> someValue = .some(42);
  final Option<int> noValue = const .none();

  // Exhaustive pattern matching enforced at compile-time!
  final message = switch (someValue) {
    Some(value: final v) => 'Found: $v',
    None() => 'Nothing here',
  };
}
```

### Make Errors Explicit with `Either<L, R>`
By convention, `Right` is success and `Left` is an error.

```dart
import 'package:daxle/daxle.dart';

Either<String, int> divide(int a, int b) {
  if (b == 0) return const .left('Cannot divide by zero');
  return .right(a ~/ b);
}

void main() {
  final result = divide(10, 2);

  // Safely extract the value or handle the error
  final message = result.fold(
    (error) => 'Failure: $error',
    (value) => 'Result: $value',
  );
}
```

### Chain Async Operations Safely with `TaskEither<L, R>`
A lazy, asynchronous computation that returns an `Either<L, R>`. It embeds the `Either` state at each step, short-circuiting on failure.

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
  // Chain dependent async computations without nesting:
  final task = fetchUser(42)
      .flatMap((user) => fetchConfig(user));

  // The computation doesn't start until you run it
  final Either<String, String> result = await task.run();
}
```

---

## Ready to build safer apps?

Check out the full **[Documentation](https://daxle.maranix.in)** to explore `Task`, `Unit`, `Async Utilities`, and advanced combinators. 

---

## Contributing

Contributions are welcome! Please see the [monorepo workspace](https://github.com/maranix/daxle) for guidelines.

## License

Released under the [MIT License](LICENSE).