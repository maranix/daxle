---
outline: deep
---

# Asynchronous Programming

Dart's built-in `Future` and `Stream` power asynchronous programming. But as your app grows, `Future`s become hard to compose, manage, and debug safely.

Daxle gives you **`Task`** and **`TaskEither`**. These tools bring lazy execution, unshakeable safety, and total control back to your asynchronous workflows.

---

## Take Control: Eager vs. Lazy Execution

The biggest difference between Dart's `Future` and Daxle's `Task` is **when** they run:
* **`Future` is eager**: Create a `Future`, and Dart runs it instantly. You lose control the moment you write it.
* **`Task` is lazy**: A `Task` defines your workflow. It waits patiently until you explicitly call `.run()`. You decide exactly when it executes.

Here is a comparison:

```dart
import 'package:daxle/daxle.dart';

Future<String> fetchData() async {
  print('Request started...');
  return 'data';
}

void main() async {
  // Eager: Prints "Request started..." immediately.
  final future = fetchData(); 

  // Lazy: Nothing is printed. The request is defined but not active.
  final task = Task(() => fetchData()); 

  print('Pipeline configured.');

  // The task only executes now when we call run().
  final result = await task.run(); 
}
```

### Why You Need Lazy Execution

Laziness splits **what** you want to do from **when** it happens. This unlocks massive architectural wins:

1. **Bulletproof Safety**: Build complex pipelines—database reads, API calls, validations—without triggering accidental side effects during setup.
2. **Infinite Reusability**: A standard `Future` resolves exactly once. If it fails, you must recreate it to retry. Because a `Task` simply wraps a function, you can run `.run()` as many times as you need on the same instance.
3. **Seamless Pipelining**: Chain transformations easily before execution. Your entire chain stays lazy and runs sequentially on your command.

---

## Choose Your Weapon: Task vs. TaskEither

Daxle arms you with two lazy asynchronous types:

* **`Task<T>`**: Delivers a guaranteed value of type `T`. It ignores explicit failure handling. If it throws an exception, standard Dart rules apply. Use `Task` when you treat failures as exceptions.
* **`TaskEither<L, R>`**: Built for workflows that fail. It safely wraps operations returning `Future<Either<L, R>>`. Use `TaskEither` for network I/O, database queries, and any domain operation where you expect—and need to handle—failures explicitly.

---

## Stop Making These Mistakes

Avoid these common traps when migrating from `Future`s to `Task`s.

### 1. Accidentally executing Futures eagerly

If you launch a `Future` before defining your `Task`, it runs immediately. You instantly lose the benefits of lazy evaluation.

```dart
// ❌ ANTI-PATTERN: The network call starts immediately!
final future = api.fetchData(); 
final task = TaskEither.fromFuture(
  () => future,
  (error, _) => 'Failed: $error',
);

//  PREFER: Defer the future instantiation inside the factory function
final task = TaskEither.fromFuture(
  () => api.fetchData(), // Only instantiated when .run() is called
  (error, _) => 'Failed: $error',
);
```

### 2. Awaiting inside mapping operations

Don't use `.map()` with async functions. It spawns messy, nested types like `Task<Future<T>>` or `TaskEither<L, Future<R>>` that ruin readability. Use `flatMap` to keep your chains clean.

```dart
// ❌ ANTI-PATTERN: Map returns a Future, creating nested types
final task = Task.right('id-123')
    .map((id) => api.fetchDetails(id)); // Result is Task<Future<Details>>

//  PREFER: Use flatMap to chain asynchronous operations
final task = Task.right('id-123')
    .flatMap((id) => Task(() => api.fetchDetails(id))); // Result is Task<Details>
```

---

## See It in Action

### Chaining Async Operations Safely

Here is a common scenario: read a configuration file containing a URL, fetch data from that URL, and save the result. We chain these operations using `flatMap`. If any step fails, the whole pipeline short-circuits safely.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:daxle/daxle.dart';

sealed class AppError {}
class FileError extends AppError { final String msg; FileError(this.msg); }
class NetworkError extends AppError { final String msg; NetworkError(this.msg); }

// 1. Read config file containing the target endpoint URL
TaskEither<AppError, String> readUrlFromConfig(String path) {
  return TaskEither.fromFuture(
    () => File(path).readAsString(),
    (err, _) => FileError('Cannot read file: $err'),
  ).flatMap((content) {
    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      final url = json['endpoint'] as String?;
      return url != null
          ? TaskEither.right(url)
          : TaskEither.left(FileError('Missing endpoint key'));
    } catch (e) {
      return TaskEither.left(FileError('Invalid json structure'));
    }
  });
}

// 2. Fetch data from URL
TaskEither<AppError, String> fetchData(String url) {
  return TaskEither.fromFuture(
    () => httpClient.read(Uri.parse(url)),
    (err, _) => NetworkError('Request failed: $err'),
  );
}

// 3. Compose the lazy pipeline
TaskEither<AppError, String> runPipeline(String configPath) {
  return readUrlFromConfig(configPath)
      .flatMap((url) => fetchData(url));
}
```

### Executing Tasks Sequentially (`sequence` and `traverse`)

If you have a collection of inputs and want to run an asynchronous operation on each, but need them to run **one after another** rather than concurrently (to avoid overwhelming a database or server), use `TaskEither.traverse`:

```dart
final filePaths = ['log_a.txt', 'log_b.txt', 'log_c.txt'];

// traverse converts List<String> to a single TaskEither returning List<String>
final TaskEither<AppError, List<String>> batchRead = TaskEither.traverse(
  filePaths,
  (path) => TaskEither.fromFuture(
    () => File(path).readAsString(),
    (err, _) => FileError('Error reading $path: $err'),
  ),
);

void main() async {
  // Executes each read sequentially
  final result = await batchRead.run();
  
  result.fold(
    (error) => print('Batch read failed!'),
    (contents) => print('Successfully read ${contents.length} files.'),
  );
}
```
