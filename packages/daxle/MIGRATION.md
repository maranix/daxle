# Daxle v4 Migration Guide

Daxle v4 introduces strict non-nullability for `Option<T extends Object>`, smart constructor initialization, primary constructor migration, and fine-grained `Concurrency` control for `Task` and `TaskEither` operations.

## 1. `Option<T extends Object>` Non-nullability & `Option.fromNullable` Removal

`Option<T extends Object>` now enforces that `T` is non-nullable (`T extends Object`). Storing `null` inside `Some` is prohibited.
`Option.fromNullable` has been removed. Use the smart factory constructor `Option(T? value)` instead.

### How to migrate:
- Replace `Option.fromNullable(value)` with `Option(value)`.
- The smart constructor `Option(value)` automatically evaluates `value`: if `null`, it returns `None()`; if non-null, it returns `Some(value)`.

**Before (v3):**
```dart
String? nullableName = getName();
final option = Option.fromNullable(nullableName);
```

**After (v4):**
```dart
String? nullableName = getName();
final option = Option(nullableName);
```

## 2. Concurrency Modes in `Task` and `TaskEither`

`Task.sequence`, `Task.traverse`, `TaskEither.sequence`, and `TaskEither.traverse` now accept an optional `Concurrency mode` parameter with default value `const .bounded(3)`.

### How to migrate:
Existing calls to `sequence` and `traverse` will work out-of-the-box using the default bounded concurrency of 3 workers. If you want sequential execution (v3 behavior) or unlimited parallelism, pass the explicit mode parameter:

**Sequential Execution (1 worker):**
```dart
final results = await Task.sequence(tasks, mode: .sequential).run();
```

**Unbounded Parallel Execution:**
```dart
final results = await TaskEither.sequence(tasks, mode: .unbounded).run();
```

**Custom Worker Limit (e.g. 5 workers):**
```dart
final results = await TaskEither.traverse(items, (item) => process(item), mode: .bounded(5)).run();
```

## 3. `Either.cond` Lazy Callback Signature

`Either.cond` has been updated to accept lazy evaluation callbacks `(bool condition, R Function() right, L Function() left)` instead of eager values `(bool condition, R right, L left)`.

### Why this change was made:
Eager value parameters caused early-evaluation bugs where throwing expressions (e.g., `a ~/ b` when `b == 0` or `json.decode(str)`) evaluated synchronously at the call site before entering `Either.cond`, throwing unhandled runtime exceptions. Lazy callbacks fix this issue by guaranteeing that the unchosen branch is never evaluated.

### How to migrate:
Wrap `right` and `left` arguments in parameterless callbacks `() => ...`:

**Before (v3):**
```dart
Either<String, int> divide(int a, int b) {
  return Either.cond(b != 0, a ~/ b, 'Cannot divide by zero'); // Throws exception when b == 0!
}
```

**After (v4):**
```dart
Either<String, int> divide(int a, int b) {
  return Either.cond(b != 0, () => a ~/ b, () => 'Cannot divide by zero'); // Lazy and safe!
}
```

---

# Daxle v3 Migration Guide

Daxle v3 focuses on simplifying the library by removing overlapping abstractions and strictly separating responsibilities. If you are migrating from v2, this guide will help you update your codebase.

## 1. `Result<T, E>` is removed

`Result` duplicated nearly all the functionality of `Either`. It has been completely removed to ensure there is only one way to model explicit success and failure.

### How to migrate:
Replace all instances of `Result<T, E>` with `Either<E, T>`.

**Before (v2):**
```dart
Result<String, Exception> fetchData() {
  try {
    return Ok('data');
  } catch (e) {
    return Err(Exception(e));
  }
}

final result = fetchData();
result.fold(
  onOk: (data) => print(data),
  onErr: (err) => print(err),
);
```

**After (v3):**
```dart
Either<Exception, String> fetchData() {
  try {
    return Either.right('data');
  } catch (e) {
    return Either.left(Exception(e));
  }
}

final result = fetchData();
result.fold(
  (err) => print(err),
  (data) => print(data),
);
```
*(Note: `Either` places the failure type first: `Either<Left, Right>`)*

## 2. `Pipeline` and `AsyncPipeline` are removed

These classes combined too many concerns (lazy execution, recovery, finalization, concurrency). They have been removed in favor of `Task` and `TaskEither`.

### How to migrate:
- For lazy, asynchronous operations that **model explicit failures**, use `TaskEither<L, R>`.
- For lazy, asynchronous operations that **do not model failures** (exceptions propagate naturally), use the new `Task<T>` primitive.

**Before (v2):**
```dart
final pipeline = AsyncPipeline(() => fetchUser())
  .map((user) => user.name)
  .recover((e) => 'Unknown');

final name = await pipeline.run();
```

**After (v3):**
```dart
// Using TaskEither
final task = TaskEither.tryCatch(
  () => fetchUser(),
  (e, s) => Exception(e),
)
.map((user) => user.name)
.orElse((e) => TaskEither.right('Unknown'));

final result = await task.run(); // Returns Either<Exception, String>
```

## 3. Explicit Control Flow (`fold` vs `switch`)

Daxle v3 makes a strict distinction between value transformations and control flow.

### How to migrate:
- Use `.fold()` when you are **transforming** both sides into a unified return value.
- Use an exhaustive `switch` statement when you are executing side effects or explicit branching control flow.

**Transformation (Use `fold`):**
```dart
final message = either.fold(
  (err) => 'Error: $err',
  (val) => 'Success: $val',
);
```

**Control Flow (Use `switch`):**
```dart
switch (either) {
  case Left(value: final err):
    handleError(err);
  case Right(value: final val):
    process(val);
}
```

## 4. Static `sequence` and `traverse`

Instead of relying on extensions, `sequence` and `traverse` are now standard static methods on `Either`, `Task`, and `TaskEither`. This improves discoverability and avoids the need to import separate extension files.

**Before (v2):**
```dart
final items = [Either.right(1), Either.right(2)];
// Relied on extensions
```

**After (v3):**
```dart
final items = [Either.right(1), Either.right(2)];
final sequenced = Either.sequence(items); // Returns Either<L, List<R>>
```

## Summary

The goal of v3 is to provide exactly one way to solve a problem. By standardizing on `Option`, `Either`, `Task`, `TaskEither`, and `Unit`, your code should become more consistent, idiomatic, and easier to maintain.
