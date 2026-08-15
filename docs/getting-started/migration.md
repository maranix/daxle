---
outline: deep
---

# Daxle v4 Migration Guide

Daxle v4.0.0 is a major release focused on strict non-nullability, fine-grained concurrency control for asynchronous pipelines, safe conditional evaluation, and performance enhancements. 

This guide outlines breaking changes and migration steps to upgrade your codebase from Daxle v3.x to v4.0.0.

---

## Summary of Major Changes

| Feature | Change in v4.0.0 | Impact |
| :--- | :--- | :--- |
| **`Option<T extends Object>`** | Strictly enforces `T extends Object`. Storing `null` inside `Some` is prohibited. | Compile-time check |
| **`Option.fromNullable`** | Removed. Use the smart factory constructor `Option(T? value)` instead. | Breaking API Change |
| **`Concurrency` Control** | Introduced `Concurrency` extension type (`.sequential`, `.unbounded`, `.bounded(limit)`). Default mode is `const .bounded(3)`. | New Feature |
| **`Either.cond`** | Signature updated to accept lazy callbacks `(bool condition, R Function() right, L Function() left)`. | Breaking API Change |
| **`QueryMap`** | Zero-cost extension type for type-safe nested map, embedded list, and non-string key queries. | New Feature |
| **`flatMapFuture`** | Added to `Task` and `TaskEither` for chaining raw `Future` computations without nested constructors. | New Feature |
| **Primary Constructors** | All core types (`Unit`, `Option`, `Either`, `Task`, `TaskEither`) now leverage Dart 3.13+ primary constructors. | Performance & Internal Refactor |

---

## 1. `Option<T extends Object>` Non-nullability & `Option.fromNullable` Removal

In Daxle v4, `Option<T extends Object>` strictly enforces non-nullable type parameters (`T extends Object`). Attempting to store a `null` value inside a `Some` instance is prohibited at compile-time and runtime.

Additionally, `Option.fromNullable(T? value)` has been removed. Use the smart factory constructor `Option(T? value)` instead.

### How to Migrate
Replace calls to `Option.fromNullable(value)` with `Option(value)`. The smart constructor evaluates `value`: if `null`, it yields `None()`; if non-null, it yields `Some(value)`.

::: code-group
```dart [v3.x (Before)]
String? nullableName = getName();
// Removed in v4
final option = Option.fromNullable(nullableName);
```

```dart [v4.0.0 (After)]
String? nullableName = getName();
// Smart constructor automatically maps null -> None() and non-null -> Some(value)
final option = Option(nullableName);
```
:::

---

## 2. Worker Pool `Concurrency` Modes in `Task` and `TaskEither`

`Task.sequence`, `Task.traverse`, `TaskEither.sequence`, and `TaskEither.traverse` now accept an optional `Concurrency mode` parameter with a default value of `const .bounded(3)`.

### Concurrency Modes Available
- **`Concurrency.bounded(int limit)`** (`mode: .bounded(limit)`): Processes tasks in parallel worker chunks of size `limit`.
- **`Concurrency.sequential`** (`mode: .sequential`): Executes tasks 1 by 1 sequentially.
- **`Concurrency.unbounded`** (`mode: .unbounded`): Executes all tasks concurrently without worker limits.

### How to Migrate
Existing calls to `sequence` and `traverse` will work out-of-the-box using the new default bounded concurrency of 3 workers. If your workflow requires single-threaded sequential execution or unlimited parallelism, pass the explicit `mode` parameter:

```dart
// 1. Sequential execution (1 worker at a time)
final results = await Task.sequence(tasks, mode: .sequential).run();

// 2. Unbounded parallel execution
final results = await TaskEither.sequence(tasks, mode: .unbounded).run();

// 3. Custom worker pool limit (e.g. 5 concurrent workers)
final results = await TaskEither.traverse(
  items, 
  (item) => processItem(item), 
  mode: .bounded(5),
).run();
```

---

## 3. `Either.cond` Lazy Callback Signature

`Either.cond` has been updated to accept parameterless lazy evaluation callbacks `(bool condition, R Function() right, L Function() left)` instead of eager positional values `(bool condition, R right, L left)`.

### Why This Change Was Made
Eager value parameters caused early-evaluation bugs where throwing expressions (e.g. `a ~/ b` when `b == 0` or `json.decode(str)`) evaluated synchronously at the call site before entering `Either.cond`, throwing unhandled runtime exceptions. Lazy callbacks guarantee that the unchosen branch is never evaluated.

### How to Migrate
Wrap `right` and `left` arguments in parameterless closures `() => ...`:

::: code-group
```dart [v3.x (Before)]
Either<String, int> divide(int a, int b) {
  // Throws IntegerDivisionByZeroException when b == 0!
  return Either.cond(b != 0, a ~/ b, 'Cannot divide by zero'); 
}
```

```dart [v4.0.0 (After)]
Either<String, int> divide(int a, int b) {
  // Lazy evaluation prevents premature execution of a ~/ b
  return Either.cond(b != 0, () => a ~/ b, () => 'Cannot divide by zero'); 
}
```
:::

---

## 4. Upgrade Checklist

1. **Update `pubspec.yaml`**:
   ```yaml
   dependencies:
     daxle: ^4.0.0
   ```
2. **Ensure Dart SDK Compatibility**: Upgrade environment constraints to `sdk: '>=3.13.0 <4.0.0'`.
3. **Run Static Analysis**: Run `dart analyze` to surface any remaining `Option.fromNullable` calls or eager `Either.cond` invocations.
4. **Run Test Suite**: Run `dart test` to verify your updated pipelines.
