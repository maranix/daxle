---
outline: deep
---

# TaskEither

Build bulletproof asynchronous pipelines that never crash unexpectedly.


## What is TaskEither?

`TaskEither<L, R>` is the workhorse of Daxle. It marries the lazy execution of `Task` with the rigorous, type-safe error handling of `Either`.

It represents an asynchronous operation—like a database query or an API call—that will eventually yield either a clear failure (`L`) or a definite success (`R`). 

```dart
final class TaskEither<L, R> {
  final Future<Either<L, R>> Function() _run;
  // ...
}
```


## Why you need it

I/O operations break. Networks drop out, files disappear, and databases hit timeouts. Standard Dart libraries throw untyped exceptions when this happens. If you miss a single `try-catch` block, your app crashes and your users suffer.

`TaskEither` gives you total predictability over the unpredictable:

1. **Catch Errors at the Gate**: Trap messy, hidden exceptions (`SocketException`, etc.) immediately and convert them into clean, strongly-typed domain errors.
2. **Declarative, Flat Pipelines**: Chain network calls, validations, and database writes into one readable flow. Say goodbye to deeply nested `try-catch` spaghetti.
3. **Guaranteed Safety**: The compiler physically forces you to handle every failure scenario before you can access your success data.

```dart
// The Old Way: Verbose, untyped, and eager to crash
Future<UserProfile?> getUser(String id) async {
  try {
    final raw = await api.fetchJson(id); // Throws unexpectedly
    return UserProfile.fromJson(raw); 
  } catch (e) {
    return null; // Silent failure, lost context
  }
}

// The TaskEither Way: Typed, lazy, and 100% safe
TaskEither<AppError, UserProfile> getUserSafe(String id) {
  return TaskEither.fromFuture(
    () => api.fetchJson(id),
    (error, _) => AppError.network(error.toString()),
  ).map(
    UserProfile.fromJson,
    onError: (error, _) => AppError.parseError(error),
  );
}
```

## See it in action

Here is how you lazily read, parse, and validate a JSON file with zero risk of crashing.

```dart
import 'dart:convert' as convert;
import 'dart:io';
import 'package:daxle/daxle.dart';

// 1. Define specific errors
sealed class ConfigError {}
class FileNotFound extends ConfigError {}
class InvalidJson extends ConfigError {}

// 2. Build the lazy, crash-proof pipeline
TaskEither<ConfigError, Map<String, dynamic>> loadConfig(String path) {
  return TaskEither.fromFuture(
    () => File(path).readAsString(),
    (_, _) => FileNotFound(),
  ).map(
    convert.jsonDecode,
    onError: (_, __) => InvalidJson(),
  );
}

void main() async {
  // 3. Fire the execution
  final result = await loadConfig('config.json').run();

  // 4. Handle every possible outcome safely
  result.fold(
    (error) => print('Failed to load: $error'),
    (config) => print('App Port: ${config['port']}'),
  );
}
```


## Common Operations

### Create a TaskEither

```dart
// Wrap a risky Future and trap its exceptions
final fetchTask = TaskEither.fromFuture(
  () => http.get(Uri.parse('https://daxle.dev')),
  (err, st) => 'Network error: $err',
);

// Wrap an immediate value
final success = TaskEither.right('All good');
final failure = TaskEither.left('Denied');
```

### Chain Async Tasks (`flatMap`)

Chain dependent asynchronous tasks together cleanly. If the first task fails, the second one is never executed, and the error safely bypasses the rest of the pipeline.

```dart
final pipeline = fetchUser(userId)
    .map((user) => user.id)
    .flatMap(fetchUserPreferences); // Returns another TaskEither
```

### Transform Data and Errors (`map` / `mapLeft`)

```dart
// map: Modify success data synchronously
final parsed = pipeline.map((data) => data.trim());

// mapLeft: Elevate or alter errors for different app layers
final domainTask = fetchTask.mapLeft((err) => DomainError('Fetch failed: $err'));
```

### Validate In-Flight (`ensure`)

Enforce business rules mid-flight. If the data fails your test, the pipeline immediately switches to a failed state.

```dart
final validatedTask = fetchTask.ensure(
  (data) => data.isNotEmpty, 
  () => 'Received empty response'
);
```

### Recover and Resolve (`orElse` / `fold`)

Handle problems and extract your final result.

```dart
final task = TaskEither.left('cache_miss');

// orElse: Try a backup async task if the first one fails
final recovered = task.orElse((err) => fetchFromNetwork());

// fold: Resolve the entire pipeline into a single Future outcome
final result = await task.fold(
  (error) => 'Error handled: $error',
  (success) => 'Success: $success',
);
```


## Best Practices

* **Trap errors at the borders**: Use `TaskEither.fromFuture` right at your repository edges. Trap low-level exceptions there and translate them into typed domain errors.
* **Never nest**: Don't use `map` if the next step is asynchronous. That creates `TaskEither<L, Future<R>>`. Always use `flatMap` to keep your pipeline completely flat.
* **Keep it lazy**: Never start a Future outside of your `TaskEither` construction. Wrap the actual call `() => api.fetch()` inside the constructor so you maintain total execution control.


## Common Mistakes

* **Eager execution leakage**:
  ```dart
  // AVOID: The request fires immediately
  final future = api.getData(); 
  final task = TaskEither.fromFuture(() => future, ...); 
  
  // PREFER: Complete laziness
  final task = TaskEither.fromFuture(() => api.getData(), ...);
  ```
* **Forgetting to pull the trigger**: Writing `.flatMap()` builds the pipeline, but does not execute it. You must call `await task.run()` or `.fold()` to actually run the code.


## Related Types

* [Either](either) - The synchronous version of `TaskEither`.
* [Task](task) - Use this for asynchronous logic that is guaranteed not to fail.
