---
layout: home

hero:
  name: Daxle
  text: Build predictable Dart apps without the boilerplate.
  tagline: Replace defensive null-checks and untracked exceptions with expressive, type-safe pipelines that feel native to Dart.
  actions:
    - theme: brand
      text: Start Writing Safer Code
      link: /getting-started/introduction
    - theme: alt
      text: View on GitHub
      link: https://github.com/maranix/daxle

features:
  - title: End Defensive Null-Checking
    details: Stop littering your code with `if (value == null)`. Use `Option` to gracefully chain and transform optional data without the cognitive load.
  - title: Catch Errors at Compile-Time
    details: Stop relying on untracked exceptions that crash in production. Use `Either` to make failure a first-class value the compiler forces you to handle.
  - title: Chain Logic, Not If-Statements
    details: Swap complex nesting and mutable state for clean, linear pipelines. Chain your business logic effortlessly using `map`, `flatMap`, and `fold`.
  - title: Take Control of Async Work
    details: Standard Futures run immediately. `Task` and `TaskEither` act as lazy blueprints, making it trivial to compose, retry, and safely recover from network failures.
  - title: Feels Like Native Dart
    details: Designed specifically for modern Dart. Daxle leverages sealed classes and exhaustive pattern matching so you never feel like you're fighting the language.
  - title: Test with Confidence
    details: Localize your side effects and error handling. Write deterministic code that is simple to reason about and a joy to test.
---

## Why Daxle?

Dart's standard library is incredibly capable. But as your application grows, your core business logic often gets buried under noise. 

Are you tired of:
- Guessing which functions might throw untracked exceptions?
- Writing the same defensive null-checks over and over?
- Juggling eager async states that are hard to compose and retry?

**Daxle** fixes this. It provides the building blocks you need to write robust, declarative code without introducing confusing academic jargon. By treating errors and missing data as values, Daxle helps you create clean pipelines that reveal exactly what your code is trying to do.

---

## See it in Action

Don't just take our word for it. Here is how Daxle transforms typical, fragile Dart patterns into elegant and unbreakable pipelines.

### 1. Safe Optional Chaining

Standard Dart relies on early returns and repetitive null-checking when transforming optional values. Daxle's `Option` allows you to chain operations gracefully, keeping the focus entirely on your logic.

::: code-group
```dart [Daxle]
import 'package:daxle/daxle.dart';

// Clean, declarative, and focused on the intent
Option<int> parseValidPort(Map<String, String> env) {
  final port = int.tryParse(env['PORT'] ?? '');

  return .fromNullable(port)
      .filter((p) => p >= 1024 && p <= 65535);
}
```

```dart [Standard Dart]
// Visually noisy with defensive conditions
int? parseValidPort(Map<String, String> env) {
  final raw = env['PORT'];
  if (raw == null) return null;
  
  final port = int.tryParse(raw);
  if (port == null || port < 1024 || port > 65535) {
    return null;
  }
  
  return port;
}
```
:::

### 2. Explicit Error Handling

Instead of throwing untracked exceptions that could crash your app at runtime, Daxle uses `Either` to return errors as values. This forces you to handle failure cases explicitly at compile-time.

::: code-group
```dart [Daxle]
import 'package:daxle/daxle.dart';

Either<String, double> safeDivide(double a, double b) {
  return .cond(b != 0.0, a / b, 'Division by zero');
}

void main() {
  final result = safeDivide(10, 0);

  // The compiler ensures both cases are handled exhaustively
  final message = switch (result) {
    Left(value: final error) => 'Failed: $error',
    Right(value: final value) => 'Success: $value',
  };
}
```

```dart [Standard Dart]
double safeDivide(double a, double b) {
  if (b == 0.0) throw ArgumentError('Division by zero');
  return a / b;
}

void main() {
  // Easy to forget the try-catch, potentially causing runtime crashes
  try {
    final result = safeDivide(10, 0);
    print('Success: $result');
  } on ArgumentError catch (e) {
    print('Failed: ${e.message}');
  }
}
```
:::

### 3. Resilient Async Pipelines

Standard `Future`s execute eagerly the moment they are created. Daxle's `TaskEither` acts as a lazy blueprint. It won't run until you tell it to, making it incredibly easy to compose, retry, and safely recover from asynchronous failures.

```dart
import 'package:daxle/daxle.dart';

TaskEither<String, String> fetchHtml(String url) {
  return TaskEither.fromFuture(
    () => httpClient.read(Uri.parse(url)),
    (error, _) => 'Network request failed: $error',
  );
}

void main() async {
  // Construct the pipeline blueprint
  final pipeline = fetchHtml('https://dart.dev')
      .map((html) => extractTitle(html))
      .tap((title) => print('Fetched Title: $title'))
      .orElse((err) => TaskEither.right('Fallback Title'));

  // The asynchronous work only begins here
  final result = await pipeline.run();
}
```

---

## Get Started in Seconds

Daxle has **minimal external dependencies** (relying only on official Dart team packages like `async` and `meta`). This makes the library exceptionally stable, resilient to breaking changes, and keeps your application bundle small and production-ready.

```bash
dart pub add daxle
```

Ready to write cleaner, safer code? Head over to the [Getting Started guide](/getting-started/introduction).