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
    details: Go beyond nullable types (T?). Option offers an expressive API to filter, chain, and transform optional states, making invalid states unrepresentable.
  - title: Predictable Control Flow
    details: Write code that is simple to test and reason about. Localize your error handling and side effects, making your control flow deterministic.
---

## Why Daxle?

Dart's standard library is incredibly capable, but as codebases grow, reliability and readability can suffer from defensive patterns: nested null-checks, manual exception handling, and implicit side-effects.

**Daxle** (derived from **Dart** + **Axle**) acts as the missing connector. Just as an axle connects wheels and enables motion, Daxle links your application logic with expressive, type-safe primitives that keep your code moving forward cleanly.

Instead of introducing academic paradigms, Daxle embraces Dart's modern features—like sealed classes, pattern matching, and type inference—to provide developers with the building blocks they need to write safer, more predictable code that looks and feels native to the language.

## Elegant & Expressive APIs

See how Daxle transforms typical Dart patterns into clean, linear, and type-safe pipelines.

### Safe Optional Chaining

Avoid nested null-checks and intermediate variables. Use `Option` to safely chain transformations and filter values.

::: code-group
```dart [Daxle]
import 'package:daxle/daxle.dart';

// Parse and filter a port configuration securely
Option<int> getValidPort(String? rawInput) {
  return .fromNullable(rawInput)
      .flatMap((s) => .fromNullable(int.tryParse(s)))
      .filter((p) => p >= 1024 && p <= 65535);
}

void main() {
  final port = getValidPort("8080").getOrElse(80);
  print('Port: $port'); // Port: 8080
}
```

```dart [Standard Dart]
// Requires manual null checks and intermediate variables
int? getValidPort(String? rawInput) {
  if (rawInput == null) return null;
  final parsed = int.tryParse(rawInput);
  if (parsed == null) return null;
  if (parsed < 1024 || parsed > 65535) return null;
  return parsed;
}

void main() {
  final port = getValidPort("8080") ?? 80;
  print('Port: $port'); // Port: 8080
}
```
:::

### Explicit Error Handling

Model errors as values instead of throwing unhandled exceptions. Pattern-match exhaustively at compile-time to guarantee every failure case is handled.

::: code-group
```dart [Daxle]
import 'package:daxle/daxle.dart';

Either<String, double> safeDivide(double a, double b) {
  return .cond(b != 0.0, a / b, 'Division by zero');
}

void main() {
  final result = safeDivide(10, 0);

  // Enforced exhaustive matching
  final message = switch (result) {
    Left(value: final error) => 'Failed: $error',
    Right(value: final value) => 'Success: $value',
  };
  
  print(message); // Failed: Division by zero
}
```

```dart [Standard Dart]
double safeDivide(double a, double b) {
  if (b == 0.0) throw ArgumentError('Division by zero');
  return a / b;
}

void main() {
  try {
    final result = safeDivide(10, 0);
    print('Success: $result');
  } on ArgumentError catch (error) {
    print('Failed: ${error.message}'); // Failed: Division by zero
  }
}
```
:::

### Lazy & Resilient Async Pipelines

`Future` execution is eager and starts running immediately. `TaskEither` represents a lazy computation blueprint that catches exceptions automatically, supports async flat-mapping, and runs only when you call `run()`.

```dart
import 'package:daxle/daxle.dart';

// Represents a blueprint for an HTTP request
TaskEither<String, String> fetchHtml(String url) {
  return TaskEither.fromFuture(
    () => httpClient.read(Uri.parse(url)),
    (error, _) => 'Failed to fetch $url: $error',
  );
}

void main() async {
  // Chain async operations and recover seamlessly
  final pipeline = fetchHtml('https://dart.dev')
      .map((html) => extractTitle(html))
      .tap((title) => print('Page Title: $title'))
      .orElse((err) => TaskEither.right('Fallback Title'));

  // The request is only executed here
  final Either<String, String> result = await pipeline.run();
}
```

## Get Started in Seconds

Daxle has zero external dependencies other than standard Dart SDK packages, keeping your application bundle light and production-ready.

Add Daxle to your project:

```bash
dart pub add daxle
```

Ready to write cleaner, safer code? Get started by reading the [Introduction](/getting-started/introduction).