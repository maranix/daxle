---
outline: deep
---

# Introduction

**Daxle** is the missing companion to the Dart standard library. It provides expressive, type-safe, and composable abstractions designed to feel like a native extension of the language. 

The name **Daxle** (derived from **Dart** + **Axle**) represents its primary purpose: just as a physical axle connects wheels and transmits power to keep a vehicle moving forward, Daxle acts as the connector for your application logic, linking data flows, error handling, and asynchronous operations into a clean, predictable pipeline.

---

## The Problem

Modern Dart is a powerful language with robust features like null safety, pattern matching, and sealed classes. However, as applications grow, developers frequently fall back on patterns that introduce fragility and clutter:

* **Defensive Null Handling**: Repetitive null-checks (`??`, `?.`, `if (val != null)`) that obscure the core business logic.
* **Implicit Side Effects**: Exceptions that can be thrown anywhere at runtime, forcing you to write defensive `try-catch` blocks without compile-time guarantees that all errors are handled.
* **Eager Asynchronous Side Effects**: Dart `Future`s begin executing the moment they are created. This makes them difficult to retry, pass around safely, or compose before they start running.

---

## The Daxle Philosophy

Daxle's goal is **not** to teach academic functional programming theory. You will not find discussions about Category Theory, Monads, or Functors here. 

Instead, Daxle focuses on **practical software engineering**. It provides tools to help you write code that is:

1. **Safer**: Force compile-time handling of missing values and error states.
2. **More Expressive**: Write clean, declarative pipelines that reveal the intent of your code.
3. **More Composable**: Chain operations seamlessly without deep nesting or temporary variables.
4. **More Predictable**: Control exactly when asynchronous side effects run and how they recover.

---

## Core Abstractions

Daxle provides a small, highly cohesive set of types to solve these problems:

### Option\<T\>
An alternative to nullable types (`T?`). An `Option` represents a value that is either present (`Some`) or absent (`None`). It provides an expressive API to map, flat-map, filter, and fold values without nested null checks.

```dart
// Safely parse and filter a port number
Option<int> getValidPort(String? input) {
  return .fromNullable(input)
      .flatMap((s) => .fromNullable(int.tryParse(s)))
      .filter((port) => port >= 1024 && port <= 65535);
}
```

### Either\<L, R\>
A sum type representing a value of one of two possible types. By convention, `Right` represents success (the expected result) and `Left` represents failure (the error). It replaces throwing exceptions by treating errors as first-class values.

```dart
Either<String, double> safeDivide(double a, double b) {
  return .cond(b != 0.0, a / b, 'Division by zero');
}
```

### Task\<T\>
A lazy, asynchronous computation that produces a value of type `T`. Unlike a standard `Future`, a `Task` is a blueprint. The underlying computation does not run until you call `.run()`.

```dart
final task = Task(() async => fetchConfigurationFile());
// Nothing has run yet.
final config = await task.run(); // Computation starts here.
```

### TaskEither\<L, R\>
A lazy, asynchronous computation that can fail. It wraps a function returning a `Future<Either<L, R>>`, combining lazy execution with automatic exception guarding and short-circuiting pipelines.

```dart
TaskEither<AppError, User> loadUser(String id) {
  return TaskEither.fromFuture(
    () => api.fetchUser(id),
    (error, stack) => AppError.network(error.toString()),
  );
}
```

### Unit
A singleton type containing exactly one value: `unit`. It represents the absence of a meaningful value in generic contexts (for example, returning `Either<DatabaseError, Unit>` when saving a record).

### Async Utilities
A curated set of re-exports from `package:async` (such as `FutureGroup`, `AsyncCache`, `AsyncMemoizer`, and stream utilities) to orchestrate complex asynchronous control flows natively alongside Daxle's types.

---

## How the Documentation is Organized

The documentation is structured to help you learn Daxle sequentially and use it as a reference:

1. **Getting Started**: Walk through installation and a complete Quick Start guide to build your first Daxle pipeline.
2. **Core Types**: Detailed reference pages for `Unit`, `Option`, `Either`, `Task`, and `TaskEither`. Each page explains the motivation, basic examples, common operations, and best practices.
3. **Utilities**: Reference guides for re-exported asynchronous utilities.
4. **Guides**: In-depth explanations of architectural concepts like error-handling strategies and asynchronous composition.
5. **Cookbooks**: Real-world recipes showing how to apply Daxle in validation, networking, repositories, and state management.