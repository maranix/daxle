---
layout: home

hero:
  name: Daxle
  text: Build predictable Dart apps without the boilerplate.
  tagline: Replace defensive null-checks and untracked exceptions with expressive, type-safe functional pipelines that feel native to modern Dart.
  actions:
    - theme: brand
      text: Start Writing Safer Code
      link: /getting-started/introduction
    - theme: alt
      text: View on GitHub
      link: https://github.com/maranix/daxle

features:
  - title: End Defensive Null-Checking
    details: Stop cluttering your code with repetitive `if (value == null)`. Use `Option` to chain, transform, and filter optional data with zero risk of null-pointer exceptions.
  - title: Catch Errors at Compile-Time
    details: Stop relying on untracked exceptions that crash in production. Use `Either` to make failure a first-class value the Dart compiler forces you to handle.
  - title: Lazy Async Blueprints
    details: Standard Futures fire immediately. `Task` and `TaskEither` act as deferred blueprints, making it trivial to compose, retry, and safely recover from network failures.
  - title: Sliding-Window Concurrency
    details: Control parallel workers with `Concurrency` (`.bounded`, `.sequential`, `.unbounded`). Available workers pull tasks dynamically, and early failures immediately abort unstarted queued tasks.
  - title: Zero-Cost Map & JSON Queries
    details: Traverse deeply nested maps, embedded arrays, and matrices using `QueryMap`. Get type-safe dot and bracket notation with zero runtime overhead.
  - title: Built for Modern Dart
    details: Built specifically for Dart 3.13+. Leverage sealed classes, exhaustive pattern matching, and constructor dot-shorthand syntax for code that feels completely native.
---

## Why Daxle?

Dart's modern type system is capable, but as apps grow, critical business logic gets buried beneath defensive noise.

Are you tired of:
- Guessing which functions might throw untracked exceptions at runtime?
- Writing repetitive null checks and type casts across nested JSON payloads?
- Unbounded `Future.wait` calls overloading your backend APIs or rate limits?
- Eager asynchronous operations that are hard to delay, compose, or retry?

**Daxle fixes this.** It provides clean, practical functional building blocks without confusing academic jargon. By modeling errors, optional values, and deferred workflows as explicit values, Daxle helps you build unbreakable Dart and Flutter applications.


## See it in Action

Here is how Daxle transforms fragile, error-prone Dart patterns into elegant, type-safe pipelines.

### 1. Safe Optional Chaining

Standard Dart relies on early returns, intermediate variables, and repetitive null-checking when transforming optional values. Daxle's `Option` lets you express your logic as a single, readable pipeline.

::: code-group
```dart [Daxle]
import 'package:daxle/daxle.dart';

// Clean, declarative, and focused entirely on domain intent
Option<int> parseValidPort(Map<String, String> env) {
  final port = int.tryParse(env['PORT'] ?? '');

  return Option(port)
      .filter((p) => p >= 1024 && p <= 65535);
}
```

```dart [Standard Dart]
// Visually noisy with defensive conditions and multiple returns
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

Instead of throwing untracked exceptions that can crash your app, Daxle uses `Either` to return errors as values. This guarantees at compile-time that both success and failure cases are handled.

::: code-group
```dart [Daxle]
import 'package:daxle/daxle.dart';

Either<String, double> safeDivide(double a, double b) {
  // Lazy callbacks prevent premature division evaluation
  return .cond(b != 0.0, () => a / b, () => 'Division by zero');
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

### 3. Resilient Async Pipelines & Controlled Concurrency

Standard `Future`s execute eagerly the moment they are instantiated. Daxle's `TaskEither` acts as a lazy blueprint with built-in worker pool concurrency controls (`.bounded(limit)`, `.sequential`, `.unbounded`) and early-abort protection.

```dart
import 'package:daxle/daxle.dart';

TaskEither<String, String> fetchHtml(String url) {
  return TaskEither.fromFuture(
    () => httpClient.read(Uri.parse(url)),
    (error, _) => 'Network request failed: $error',
  );
}

void main() async {
  // 1. Compose a lazy single-task pipeline
  final pipeline = fetchHtml('https://dart.dev')
      .map((html) => extractTitle(html))
      .tap((title) => print('Fetched Title: $title'))
      .orElse((err) => TaskEither.right('Fallback Title'));

  // The asynchronous work only begins here
  final result = await pipeline.run();

  // 2. Process batches of tasks with a sliding-window worker pool of 3.
  // If any task fails, unstarted queued tasks abort immediately:
  final urls = ['https://dart.dev', 'https://flutter.dev', 'https://pub.dev'];
  final batchResult = await TaskEither.traverse(
    urls,
    (url) => fetchHtml(url),
    mode: .bounded(3),
  ).run();
}
```

### 4. Zero-Cost Nested Map & JSON Querying

Manually traversing nested maps and embedded lists with standard casts (`as String?`) causes runtime `TypeError`s and `RangeError`s. `QueryMap` provides compile-time zero-cost dot notation, bracket indexing, and non-string key queries that safely return `null` on missing paths or type mismatches.

```dart
import 'package:daxle/daxle.dart';

void main() {
  final payload = {
    'services': {
      'server': {'host': 'https://api.internal', 'port': 8080},
    },
    'users': [
      {'name': 'Alice', 'roles': ['admin', 'dev']},
    ],
  };

  final query = QueryMap(payload);

  // 1. Dot notation:
  final host = query.get<String>('services.server.host'); // 'https://api.internal'

  // 2. Bracket indexing on embedded lists:
  final role = query.get<String>('users[0].roles[0]'); // 'admin'

  // 3. Type safety (returns null instead of throwing TypeError):
  final wrongType = query.get<int>('services.server.host'); // null

  // 4. Effortless composition with Option:
  final serverHost = Option(query.get<String>('services.server.host'))
      .getOrElse(() => 'https://fallback.internal');
}
```


## Get Started in Seconds

Daxle has **minimal external dependencies** (relying only on official Dart team packages like `async` and `meta`). This makes the library exceptionally stable, resilient to breaking changes, and keeps your application bundle small and production-ready.

```bash
dart pub add daxle
```

Ready to write cleaner, safer code? Head over to the [Getting Started guide](/getting-started/introduction).