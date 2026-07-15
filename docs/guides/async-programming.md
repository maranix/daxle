---
outline: deep
---

# Asynchronous Programming

In Dart, asynchronous programming is centered around `Future` and `Stream`. While `Future` is excellent for single asynchronous operations, it has properties that make it difficult to compose and manage safely in complex applications. 

Daxle introduces **`Task`** and **`TaskEither`** to bring safety, laziness, and execution control to your asynchronous workflows.

---

## Eager vs. Lazy Execution

The key conceptual difference between Dart's `Future` and Daxle's `Task` is **execution timing**:
* **`Future` is eager**: As soon as you create a `Future`, the Dart event loop schedules it for execution. It is already running.
* **`Task` is lazy**: A `Task` is a description of an asynchronous computation. It does not start running until you explicitly call its `.run()` method.

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

### Why Laziness Matters

Laziness separates **what** you want to do from **when** you want to do it. This provides major architectural benefits:

1. **Safety**: You can construct complex pipelines of database reads, API requests, and validations without triggering side effects during the setup phase.
2. **Reusability**: Because a `Task` is just a function wrapper, you can run it multiple times. A standard `Future` can only resolve once. If you want to retry a failed operation with a `Future`, you have to call the original function again. With a `Task`, you simply call `.run()` again on the same task instance.
3. **Pipelining**: You can chain transformations together before executing them. The entire chain remains lazy and executes sequentially when triggered.

---

## Task vs. TaskEither

Daxle provides two lazy asynchronous types:

* **`Task<T>`**: Represents an asynchronous computation that yields a value of type `T`. It does not provide explicit failure handling. If the underlying computation throws an exception, it propagates normally. Use `Task` when failures are represented as exceptions following normal Dart semantics.
* **`TaskEither<L, R>`**: Represents an asynchronous computation that can fail. It wraps a function returning `Future<Either<L, R>>`. Use `TaskEither` for I/O and domain operations where failures are expected (e.g. database issues, server timeouts) and should be explicitly handled.

---

## Common Anti-patterns and Mistakes

When moving from `Future`s to `Task`s, developers often make a few common mistakes.

### 1. Accidentally executing Futures eagerly

If you create a `Future` outside of the `Task` factory function, it will start running immediately, defeating the benefit of lazy evaluation.

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

Using `.map()` with an asynchronous function that returns a `Future` creates a nested `Task<Future<T>>` or `TaskEither<L, Future<R>>`. This is hard to read and handle.

```dart
// ❌ ANTI-PATTERN: Map returns a Future, creating nested types
final task = Task.right('id-123')
    .map((id) => api.fetchDetails(id)); // Result is Task<Future<Details>>

//  PREFER: Use flatMap to chain asynchronous operations
final task = Task.right('id-123')
    .flatMap((id) => Task(() => api.fetchDetails(id))); // Result is Task<Details>
```

---

## Practical Examples

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
