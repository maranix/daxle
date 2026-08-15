---
outline: deep
---

# Task

Take absolute control over when and how your asynchronous operations execute.


## What is Task?

A `Task<T>` gives you a lazy, reproducible asynchronous operation that produces a value of type `T`.

Standard Dart `Future`s are eager—they start running the exact moment you create them. A `Task` waits. It wraps your future inside a function and completely defers execution until you explicitly pull the trigger by calling `.run()`.

```dart
final class Task<T> {
  final Future<T> Function() _run;
  // ...
}
```


## Why you need it

Eager execution strips you of control. When a network request fires immediately, you lose the ability to easily delay it, retry it, or weave it safely into complex workflows.

`Task` hands the control back to you:

1. **Total Execution Control**: Separate *what* your code does from *when* it does it. Build your entire pipeline first, then execute it on your terms.
2. **Effortless Retries & Delays**: A `Task` is just a description of work. You can rerun it multiple times or pause it without rebuilding the logic from scratch.
3. **Bulletproof Composition**: Chain operations securely using `map` and `flatMap`. The entire sequence stays dormant until you are ready.

```dart
// Eager: The network request fires instantly.
final future = fetchUserData('user-123'); 

// Lazy: The work is defined, but nothing happens yet.
final task = Task(() => fetchUserData('user-123')); 

// ... execution happens exactly when you say so.
final data = await task.run(); 
```


## See it in action

Here is how you lazily define a file read operation, chain a transformation to it, and finally run the pipeline.

```dart
import 'dart:io';
import 'package:daxle/daxle.dart';

// 1. Define the work lazily
final readLogTask = Task(() async {
  print('Executing file read...');
  return await File('app.log').readAsString();
});

void main() async {
  // 2. Chain a transformation (still completely lazy)
  final wordCountTask = readLogTask.map((content) {
    return content.split(RegExp(r'\s+')).length;
  });

  print('Pipeline configured.');

  // 3. Pull the trigger
  final count = await wordCountTask.run();
  
  print('Log word count: $count');
}
```


## Common Operations

### Create a Task

Wrap your async work in a function that returns a `Future`:

```dart
final task = Task(() async {
  await Future.delayed(const Duration(seconds: 1));
  return 'Finished';
});
```

### Run a Task

Trigger the deferred computation. This gives you back a standard Dart `Future`:

```dart
final Future<String> future = task.run();
final result = await future;
```

### Chain and Transform (`map` / `flatMap` / `flatMapFuture`)

Shape and chain your asynchronous operations lazily. None of these transformations execute until you trigger the pipeline with `run()`.

```dart
// 1. map: Apply synchronous transformations once the async task produces a value
final fetchDiskUsage = Task(() async => 1024 * 1024 * 850); // 850 MB in bytes

final diskReport = fetchDiskUsage
    .map((bytes) => bytes / (1024 * 1024))
    .map((mb) => 'Disk Usage: ${mb.toStringAsFixed(1)} MB');

// 2. flatMap: Chain dependent Task instances without nesting Task<Task<T>>
Task<String> fetchAuthToken() => Task(() => authService.generateToken());
Task<DashboardData> fetchDashboard(String token) => Task(() => api.getDashboard(token));

final loadDashboard = fetchAuthToken()
    .flatMap(fetchDashboard); // Clean tear-off composition

// 3. flatMapFuture: Directly chain raw Future APIs (e.g. disk/DB writes) without Task boilerplate
final persistPipeline = loadDashboard
    .flatMapFuture((dashboard) => secureStorage.write(
      key: 'cached_dashboard',
      value: dashboard.toJson(),
    ));
```

### Add Safe Side Effects (`tap`)

Perform observational side-effects (such as logging or metrics) without interrupting or modifying data flow:

```dart
final syncTask = Task(() => syncDatabaseChanges())
    .tap((count) => logger.info('Successfully synced $count records'))
    .map((count) => 'Sync complete: $count records');
```

### Execute in Batch with Concurrency (`sequence` / `traverse`)

Run collections of tasks with fine-grained worker pool concurrency controls (`Concurrency` extension type):

* `sequence`: Converts a list of tasks into a single task returning a list of results.
* `traverse`: Maps your items into tasks and executes them using the specified concurrency mode.

Both methods accept an optional `{Concurrency mode = const .bounded(3)}` parameter:
* **`Concurrency.bounded(int limit)`** (`.bounded(5)`): Processes tasks in parallel worker chunks of size `limit` (default is 3).
* **`Concurrency.sequential`** (`.sequential`): Executes tasks 1 by 1 sequentially.
* **`Concurrency.unbounded`** (`.unbounded`): Runs all tasks simultaneously in parallel.

```dart
final tasks = [
  Task(() async => 'Task A'),
  Task(() async => 'Task B'),
  Task(() async => 'Task C'),
];

// Run tasks sequentially (1 by 1)
final Task<List<String>> sequentialBatch = Task.sequence(tasks, mode: .sequential);
final results1 = await sequentialBatch.run(); 

// Run tasks concurrently in worker batches of 5
final paths = ['log1.txt', 'log2.txt', 'log3.txt'];
final Task<List<int>> byteCounts = Task.traverse(
  paths,
  (path) => Task(() => File(path).length()),
  mode: .bounded(5),
);
final results2 = await byteCounts.run();

// Run all tasks in parallel with unlimited concurrency
final Task<List<String>> parallelBatch = Task.sequence(tasks, mode: .unbounded);
```


## Best Practices

* **Always pass a closure**: Always write `Task(() => ... )`. Never pass an already-running future directly into the constructor.
* **Keep side effects contained**: Use `.tap()` to handle logs or analytics. Don't leak side effects outside the pipeline.
* **Push execution to the edges**: Keep your core business logic returning `Task` objects. Only call `.run()` at the very edge of your app—like in your UI handlers or main functions.


## Common Mistakes

* **Accidentally running eager futures**:
  ```dart
  // AVOID: This fires immediately!
  final future = myAsyncCall();
  final task = Task(() => future); 
  
  // PREFER: True lazy execution
  final task = Task(() => myAsyncCall());
  final task = Task(myAsyncCall);
  ```
* **Forgetting the trigger**: Because `Task` is lazy, writing `task.map(...)` does nothing on its own. You must call `await task.run()` to start the execution.
* **Ignoring errors**: `Task` does not catch exceptions automatically. If you expect your async work to fail, upgrade to `TaskEither`.


## When to use Task

* When building complex asynchronous workflows that shouldn't fire immediately.
* When sequential execution is critical.
* When errors are already handled elsewhere in your architecture.

### When to look elsewhere

* If you just need to fetch data immediately for a simple Flutter `FutureBuilder`, standard `Future`s are fine.
* If your operation is prone to failure (like network calls), switch to `TaskEither` for ironclad error handling.


## Related Types

* [TaskEither](task-either) - The fail-safe variant of `Task`.
* [Concurrency](concurrency) - Detailed guide on sliding-window worker pool execution strategies.
* [Either](either) - The synchronous counterpart for success/failure modeling.
