---
outline: deep
---

# Task

Representing a lazy asynchronous computation.

---

## What is it?

`Task<T>` represents an asynchronous computation that yields a value of type `T`. Unlike Dart's standard `Future`, which executes immediately upon creation, a `Task` is **lazy**: it encapsulates the async operation and defers its execution until you explicitly call `run()`.

Under the hood, a `Task<T>` is simply a wrapper around a function that returns a `Future`:
```dart
final class Task<T> {
  final Future<T> Function() _run;
  // ...
}
```

---

## Why use it?

Standard Dart `Future`s are eager. As soon as you instantiate a future, the runtime schedules it for execution. This makes it difficult to compose async operations or reuse them safely.

With `Task`, you gain three main advantages:

1. **Explicit Execution Control**: You define *what* will happen, and separate it from *when* it happens.
2. **Easy Retries & Delays**: Since a `Task` is just a description of a computation, you can run it multiple times or delay its start without needing to recreate the pipeline from scratch.
3. **Safe Composition**: You can chain multiple tasks together (`map`, `flatMap`) to build complex workflows. The entire pipeline remains lazy and does not start running until the final task's `run()` is called.

Compare eager futures with lazy tasks:

```dart
// Eager: The network request starts immediately.
final future = fetchUserData('user-123'); 

// Lazy: The network request is defined but does NOT start.
final task = Task(() => fetchUserData('user-123')); 

// ... later ...
final data = await task.run(); // Execution starts here.
```

---

## Basic Example

Here is a simple example showing how to read a file lazily. We define the task, chain a mapping operation to parse its contents, and then run it.

```dart
import 'dart:io';
import 'package:daxle/daxle.dart';

// 1. Define a lazy task to read a file
final readLogTask = Task(() async {
  print('Executing file read...');
  return await File('app.log').readAsString();
});

void main() async {
  // 2. Chain a transformation (still lazy, nothing has run yet)
  final wordCountTask = readLogTask.map((content) {
    return content.split(RegExp(r'\s+')).length;
  });

  print('Pipeline configured.');

  // 3. Trigger the execution
  final count = await wordCountTask.run();
  
  print('Log word count: $count');
}
```

---

## Common Operations

### Creating Tasks

Create a task by wrapping an asynchronous function that returns a `Future`:

```dart
final task = Task(() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'Finished';
});
```

### Running Tasks

Execute the deferred asynchronous computation using `run()`. This returns a standard Dart `Future`:

```dart
final Future<String> future = task.run();
final result = await future;
```

### Transforming Tasks (`map` / `flatMap`)

You can map and chain tasks. None of the transformations run immediately; they are all queued up to run sequentially when `run()` is called.

```dart
final readTask = Task(() async => '{"id": 100, "status": "active"}');

// map: Transforms the output synchronously
final statusTask = readTask.map((json) => json.contains('active') ? 'ONLINE' : 'OFFLINE');

// flatMap: Chains another asynchronous Task based on the output of the first
final notifyTask = statusTask.flatMap((status) {
  return Task(() async {
    // Send status to another service
    await sendStatusUpdate(status);
    return 'Notification sent';
  });
});
```

### Side Effects (`tap`)

Execute synchronous or asynchronous side-effects (like logging or updating local variables) without altering the value flowing through the pipeline:

```dart
final task = Task(() async => 'Log message data');

final tappedTask = task.tap((data) async {
  print('Writing to system log: $data');
});
```

### Batch Operations (`sequence` / `traverse`)

Run multiple tasks sequentially (one after another):

* `sequence`: Converts a list of `Task`s into a single `Task` returning a list of values.
* `traverse`: Maps an iterable of items to `Task`s and runs them sequentially.

```dart
final tasks = [
  Task(() async => 'Task A'),
  Task(() async => 'Task B'),
];

// sequence: Runs Task A, awaits it, then runs Task B, awaits it.
final Task<List<String>> batch = Task.sequence(tasks);
final results = await batch.run(); // ['Task A', 'Task B']


final paths = ['log1.txt', 'log2.txt', 'log3.txt'];
// traverse: Safely maps and processes paths one by one
final Task<List<int>> byteCounts = Task.traverse(
  paths,
  (path) => Task(() => File(path).length()),
);
```

---

## Composition

`Task` is often composed with collections or other transformations. Below, we read files from a directory list and collect their sizes:

```dart
Task<List<int>> getFileSizes(List<String> paths) {
  return Task.traverse(paths, (path) {
    return Task(() => File(path).length());
  });
}
```

---

## Best Practices

* **Always Wrap Closures**: Ensure you pass an anonymous function returning a future (`() => ...`) to the `Task` constructor. Never pass an already-running future.
* **Keep Side-Effects Inside the Pipeline**: Avoid running side-effects outside of the `Task` lifecycle. If you need to perform logs or state updates, chain them with `.tap()`.
* **Defer Execution to the Edge**: Keep your business logic returning `Task` instances. Only run them at the last possible moment, such as inside controller actions, main functions, or UI event handlers.

---

## Common Mistakes

* **Capturing Eager Futures**:
  ```dart
  // AVOID: This starts running immediately!
  final future = myAsyncCall();
  final task = Task(() => future); 
  
  // PREFER: Defer execution by passing a lambda
  final task = Task(() => myAsyncCall());
  ```
* **Forgetting to Call `run()`**: Because a `Task` is lazy, if you write `task.map(...)` without calling `await task.run()`, the underlying future will never execute.
* **Ignoring Exceptions**: Standard `Task` does not have built-in exception catching. If the wrapped function throws, the exception will propagate when `run()` is called. If you need type-safe async error handling, use `TaskEither`.

---

## When to Use

* When you want to construct complex asynchronous pipelines without eagerly triggering execution.
* When executing tasks sequentially matters (e.g., writing sequential logs to a file).
* When exceptions are handled at a higher level or are not a core part of the domain logic.

### When NOT to Use

* For simple async calls where you want to fetch something immediately and render it (e.g., standard Flutter `FutureBuilder` works best with standard eager `Future`s).
* When failures are common and need to be explicitly checked by type. In those cases, use `TaskEither`.

---

## API Overview

### Classes

| Class | Description |
|---|---|
| `Task<T>` | Final class representing a lazy asynchronous computation producing a value of type `T`. |

### Constructors

| Constructor | Description |
|---|---|
| `Task(Future<T> Function() run)` | Wraps an asynchronous computation in a lazy `Task`. |

### Methods

| Method | Return Type | Description |
|---|---|---|
| `run()` | `Future<T>` | Executes the deferred asynchronous computation. |
| `map<R>(R Function(T) f)` | `Task<R>` | Transforms the task's output value synchronously. |
| `flatMap<R>(Task<R> Function(T) f)` | `Task<R>` | Chains another lazy asynchronous computation. |
| `tap(FutureOr<void> Function(T) callback)` | `Task<T>` | Runs a callback on the output without modifying the value. |

### Static Methods

| Method | Return Type | Description |
|---|---|---|
| `sequence<R>(Iterable<Task<R>> tasks)` | `Task<List<R>>` | Runs a list of tasks sequentially and collects the results. |
| `traverse<A, B>(Iterable<A> items, Task<B> Function(A) mapper)` | `Task<List<B>>` | Maps an iterable to tasks and executes them sequentially. |

---

## Related Types

* [TaskEither](task-either) - The fail-safe variant of `Task`, returning an `Either` containing errors or results.
* [Either](either) - The synchronous counterpart for representing success/failure outcomes.
