---
outline: deep
---

# TaskEither

Representing an asynchronous computation that can fail.

---

## What is it?

`TaskEither<L, R>` combines the laziness of `Task` with the explicit error handling of `Either`. It represents an asynchronous operation that, when executed, will yield either a failure of type `L` (represented as `Left`) or a success of type `R` (represented as `Right`).

Under the hood, it wraps a function returning a `Future` of an `Either`:
```dart
final class TaskEither<L, R> {
  final Future<Either<L, R>> Function() _run;
  // ...
}
```

`TaskEither` is the most widely used type in Daxle. It is the primary tool for modeling I/O operations—such as network requests, database queries, and file operations—where execution is asynchronous and failures are expected.

---

## Why use it?

Most I/O libraries in Dart throw untyped exceptions when things go wrong (e.g., `SocketException`, `DatabaseException`). If you forget to catch them, your app can crash. Even if you do catch them, the compiler does not help you remember to handle all failure cases.

`TaskEither` provides:

1. **Safety at Boundaries**: You catch low-level, untyped exceptions at the boundary of your system and convert them into explicit, typed domain errors.
2. **Declarative Pipelines**: You can chain database queries, network requests, validation steps, and logging into a single, clean pipeline.
3. **No Unhandled Failures**: The compiler forces you to handle the `Left` case before accessing the `Right` case.

Instead of nested try-catch blocks and manual tracking:

```dart
// Verbose and error-prone eager execution
Future<UserProfile?> getUser(String id) async {
  try {
    final rawUser = await api.fetchUserJson(id); // might throw SocketException
    if (rawUser == null) return null;
    return UserProfile.fromJson(rawUser); // might throw FormatException
  } catch (e) {
    logger.severe('Failed: $e');
    return null;
  }
}
```

You write a safe, declarative, lazy pipeline:

```dart
// Clear, typed, and deferred execution
TaskEither<AppError, UserProfile> getUserSafe(String id) {
  return TaskEither.fromFuture(
    () => api.fetchUserJson(id),
    (error, _) => AppError.network(error.toString()),
  )
  .flatMap((json) => Either.tryCatch(
        () => UserProfile.fromJson(json),
        (error, _) => AppError.parse(error.toString()),
      ).fold(
        (err) => TaskEither.left(err),
        (user) => TaskEither.right(user),
      ));
}
```

---

## Basic Example

Here is a practical example of reading, parsing, and validating a JSON configuration file asynchronously:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:daxle/daxle.dart';

// 1. Define domain errors
sealed class ConfigError {}
class FileNotFound extends ConfigError {
  final String path;
  FileNotFound(this.path);
}
class InvalidJson extends ConfigError {
  final String details;
  InvalidJson(this.details);
}

// 2. Define the lazy pipeline
TaskEither<ConfigError, Map<String, dynamic>> loadConfig(String path) {
  return TaskEither.fromFuture(
    () => File(path).readAsString(),
    (_, __) => FileNotFound(path),
  ).flatMap((content) {
    // tryCatch is synchronous, so we wrap its result in TaskEither
    return TaskEither.fromEither(Either.tryCatch(
      () => jsonDecode(content) as Map<String, dynamic>,
      (error, _) => InvalidJson(error.toString()),
    ));
  });
}

void main() async {
  final pipeline = loadConfig('config.json');

  // Trigger the execution
  final result = await pipeline.run();

  result.fold(
    (error) {
      switch (error) {
        case FileNotFound(:final path):
          print('Config file not found at: $path');
        case InvalidJson(:final details):
          print('Config is invalid: $details');
      }
    },
    (config) => print('Config loaded successfully! Port: ${config['port']}'),
  );
}
```

---

## Common Operations

### Creating TaskEithers

```dart
// 1. Direct wrapping of a lazy future returning an Either
final task = TaskEither(() async => Either.right(42));

// 2. Wrap an eager Either
final success = TaskEither.fromEither(Either.right('success'));
final failure = TaskEither.left('error');

// 3. Wrap a standard Future, catching exceptions and mapping to Left
final fetchTask = TaskEither.fromFuture(
  () => http.get(Uri.parse('https://daxle.dev/api')),
  (err, st) => 'Network error: $err',
);
```

### Transforming Success values (`map` / `flatMap`)

Modify success values in the pipeline. If a previous step failed (`Left`), these transformations are skipped:

```dart
final pipeline = TaskEither.right(' 100 ');

// map: Transforms the success value synchronously
final mapped = pipeline.map((s) => s.trim()).map(int.parse);

// flatMap: Chains another asynchronous fallible computation
final saved = mapped.flatMap((number) {
  return TaskEither.fromFuture(
    () => saveToDatabase(number),
    (err, _) => 'DB Error: $err',
  );
});
```

::: tip Custom Exception Handling in Transformations
Both `map` and `flatMap` accept an optional `onError` callback. If the transformation function throws an exception, it is automatically caught and mapped to a `Left`:

```dart
final task = TaskEither.right('invalid_json').map(
  (s) => jsonDecode(s),
  onError: (err, _) => 'Decode error: $err',
); // Resolves to Left('Decode error: ...')
```
:::

### Transforming Errors (`mapLeft` / `bimap`)

Map intermediate error types to represent changes in the architectural layer (e.g., repository level mapping database errors to domain errors):

```dart
// mapLeft: Map error values
final domainTask = fetchTask.mapLeft((netErr) => DomainError('Network call failed: $netErr'));

// bimap: Transform both success and failure outcomes simultaneously
final updatedTask = fetchTask.bimap(
  (err) => 'Mapped Error: $err',
  (data) => 'Mapped Success: $data',
);
```

### Asynchronous Validation (`ensure`)

Ensure the success value satisfies a predicate (can be synchronous or asynchronous). If it fails, the pipeline transitions to a `Left`:

```dart
final checkTokenTask = TaskEither.right('token_data');

final validatedTask = checkTokenTask
    .ensure((token) => token.isNotEmpty, () => 'Token cannot be empty')
    .ensure((token) => verifyTokenInDatabase(token), () => 'Token is expired');
```

### Side Effects (`tap` / `tapLeft`)

Perform side effects (like updating local databases, analytics, caching, or logging) without altering the values inside the pipeline:

```dart
final task = TaskEither.right('content');

final loggedTask = task
    .tap((data) => cache.save(data)) // Executes on success
    .tapLeft((err) async => logger.severe('Pipeline failed with: $err')); // Executes on error
```

### Recovery (`orElse` / `fold`)

Handle errors and recover:

* `orElse`: Fall back to an alternative `TaskEither` computation if the current one fails.
* `fold`: Resolve both Left and Right states into a single final type.

```dart
final task = TaskEither.left('cache_miss');

// orElse: Recovers with a fallback TaskEither (e.g., fetch from network on cache miss)
final recovered = task.orElse((err) => fetchFromNetwork());

// fold: Resolves the pipeline and returns a Future of the final value
final Future<String> result = task.fold(
  (error) => 'Failure state: $error',
  (success) => 'Success state: $success',
);
```

### Batch Operations (`sequence` / `traverse`)

Run multiple `TaskEither` operations sequentially:

* `sequence`: Turns a list of `TaskEither`s into a single `TaskEither` returning a list of values. If any task returns a `Left`, execution stops and returns that error.
* `traverse`: Maps a list of items to `TaskEither`s and executes them sequentially.

```dart
final tasks = [
  saveItem(itemA),
  saveItem(itemB),
  saveItem(itemC),
];

// sequence: executes sequentially; fails fast if any task returns Left
final TaskEither<SaveError, List<Unit>> saveAll = TaskEither.sequence(tasks);


final filePaths = ['log1.json', 'log2.json', 'log3.json'];
// traverse: maps and executes sequentially
final TaskEither<ConfigError, List<Map>> parsedConfigs = TaskEither.traverse(
  filePaths,
  (path) => loadConfig(path),
);
```

---

## Composition

`TaskEither` integrates smoothly with sync Daxle types. Here, we fetch data asynchronously and apply synchronous validation:

```dart
TaskEither<String, int> fetchAndValidate(String id) {
  return TaskEither.fromFuture(
    () => api.fetchRawValue(id),
    (err, _) => 'Failed to fetch: $err',
  ).flatMap((raw) {
    // Chain sync Either validation
    return TaskEither.fromEither(
      Either.cond(raw > 0, raw, 'Value must be positive'),
    );
  });
}
```

---

## Best Practices

* **Always map exceptions early**: Wrap standard futures in `TaskEither.fromFuture` at the boundary of your class or repository. Map raw exceptions (like socket timeouts) to structured domain errors immediately.
* **Keep pipelines flat**: Avoid nesting. Use `flatMap` to chain dependent tasks. If you call `.run()` or `.fold()` inside a transformation, you are breaking the pipeline and eagerness starts leaking.
* **Avoid `map` with async closures**: Never pass an asynchronous closure (returning a `Future` or another `Task`) to `.map()`. If the next step is asynchronous, use `flatMap`.

---

## Common Mistakes

* **Creating eager futures outside `TaskEither`**:
  ```dart
  // AVOID: starts running immediately
  final future = api.getData(); 
  final task = TaskEither.fromFuture(() => future, (e, st) => ...); 
  
  // PREFER: defer execution
  final task = TaskEither.fromFuture(() => api.getData(), (e, st) => ...);
  ```
* **Forgetting to call `run()`**: A `TaskEither` will do nothing until `run()` or `fold()` is called. If your pipeline is not executing, check if you forgot to call `await task.run()`.
* **Rethrowing errors inside map/flatMap**: Do not throw exceptions inside your `map` or `flatMap` functions manually unless you capture them with the `onError` parameter. Return a `Left` or use `ensure` instead.

---

## When to Use

* For repository layers executing API calls, local SQLite queries, or Firestore lookups.
* For complex sequences of actions where the success of step B depends on the output of step A, and both can fail.
* When you want a unified, compile-time enforced way to handle asynchronous failures in Flutter controllers or backend route handlers.

### When NOT to Use

* For purely synchronous calculations (use `Either`).
* For asynchronous tasks that cannot fail (use `Task`).

---

## API Overview

### Constructors & Factories

| Constructor | Description |
|---|---|
| `TaskEither(Future<Either<L, R>> Function() run)` | Wraps a lazy asynchronous function returning an `Either`. |
| `TaskEither.fromEither(Either<L, R> either)` | Creates a `TaskEither` resolving immediately to the given `either`. |
| `TaskEither.fromFuture(Future<R> Function() future, L Function(Object, StackTrace) onError)` | Wraps a standard future, catching exceptions and converting them to `Left`. |
| `TaskEither.left(L left)` | Creates a `TaskEither` that resolves to a `Left` containing `left`. |
| `TaskEither.right(R right)` | Creates a `TaskEither` that resolves to a `Right` containing `right`. |

### Methods

| Method | Return Type | Description |
|---|---|---|
| `run()` | `Future<Either<L, R>>` | Executes the deferred asynchronous computation. |
| `map<B>(B Function(R) f, {L Function(Object, StackTrace)? onError})` | `TaskEither<L, B>` | Transforms the success value (`Right`). |
| `mapLeft<L2>(L2 Function(L) mapper)` | `TaskEither<L2, R>` | Transforms the error value (`Left`). |
| `bimap<L2, R2>(L2 Function(L), R2 Function(R))` | `TaskEither<L2, R2>` | Transforms both Left and Right values simultaneously. |
| `flatMap<B>(TaskEither<L, B> Function(R), {L Function(Object, StackTrace)? onError})` | `TaskEither<L, B>` | Chains another async fallible task on success. |
| `tap(FutureOr<void> Function(R))` | `TaskEither<L, R>` | Runs a callback on success without modifying the value. |
| `tapLeft(FutureOr<void> Function(L))` | `TaskEither<L, R>` | Runs a callback on failure without modifying the error. |
| `ensure(FutureOr<bool> Function(R), L Function() onFailure)` | `TaskEither<L, R>` | Asserts that the success value satisfies a condition. |
| `orElse(TaskEither<L, R> Function(L), {L Function(Object, StackTrace)? onError})` | `TaskEither<L, R>` | Recovers from a `Left` error using a fallback task. |
| `fold<B>(B Function(L), B Function(R), {B Function(Object, StackTrace)? onError})` | `Future<B>` | Resolves the computation, projecting it into a value of type `B`. |

### Static Methods

| Method | Return Type | Description |
|---|---|---|
| `sequence<L, R>(Iterable<TaskEither<L, R>> tasks)` | `TaskEither<L, List<R>>` | Runs a list of tasks sequentially and collects successes. |
| `traverse<L, A, B>(Iterable<A> items, TaskEither<L, B> Function(A) mapper)` | `TaskEither<L, List<B>>` | Maps items to tasks and executes them sequentially. |

---

## Related Types

* [Either](either) - The synchronous equivalent of `TaskEither`.
* [Task](task) - Asynchronous computation that does not fail (always succeeds or propagates exceptions).
* [Unit](unit) - Frequently used as `R` in `TaskEither<L, Unit>` to indicate successful execution of side effects.
