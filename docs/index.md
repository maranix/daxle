---
layout: home

hero:
  name: Daxle
  text: The missing companion to Dart's standard library.
  tagline: Expressive, type-safe, and composable abstractions that feel native to Dart.
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/introduction
    - theme: alt
      text: GitHub
      link: https://github.com/maranix/daxle

features:
  - title: Native & Approachable
    details: Designed specifically for modern Dart. Leveraging sealed classes, exhaustive pattern matching, and shorthand constructors to feel like a natural extension of the language.
  - title: Composable Pipelines
    details: Swap complex nesting, statements, and mutable state for clean, linear pipelines. Chain calculations effortlessly using map, flatMap, and fold.
  - title: Explicit Error Handling
    details: Stop relying on unhandled exceptions and side-effects. Use Either to model success and failure as first-class values, enforcing compile-time safety.
  - title: Lazy Async Computations
    details: Defer asynchronous work with Task and TaskEither. Build pipelines that act as blueprints, executing or recovering only when you explicitly call run().
  - title: Safer Null Handling
    details: Go beyond nullable types (T?). Option offers an expressive API to filter, chain, and transform optional states, reducing the cognitive load of defensive null-checks.
  - title: Predictable Control Flow
    details: Write code that is simple to test and reason about. Localize your error handling and side effects, making your control flow deterministic.
---

## Why Daxle?

Dart's standard library is incredibly capable. However, as applications scale in complexity, business logic often gets buried under boilerplate. Developers find themselves constantly writing defensive null checks, guarding against untracked runtime exceptions, and juggling eager asynchronous states.

**Daxle** provides the building blocks you need to write robust, declarative code without introducing heavy academic paradigms. By treating errors and missing data as first-class values, Daxle helps you create clean, predictable pipelines that naturally reveal your code's intent.

---

## See it in Action

Don't just take our word for it. Here is how Daxle transforms typical, defensive Dart patterns into elegant and type-safe pipelines.

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

Daxle is self-contained and has **zero external dependencies** other than the standard Dart SDK. Keep your application bundle light and production-ready.

```bash
dart pub add daxle
```

Ready to write cleaner, safer code? Head over to the [Getting Started guide](/getting-started/introduction).