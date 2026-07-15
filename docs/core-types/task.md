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

### Chain and Transform (`map` / `flatMap`)

Shape your data as it flows through the pipeline. None of these transformations run until you call `run()`.

```dart
final readTask = Task(() async => '{"id": 100, "status": "active"}');

// map: Shape the output synchronously
final statusTask = readTask.map((json) => json.contains('active') ? 'ONLINE' : 'OFFLINE');

// flatMap: Chain to another async Task seamlessly
final notifyTask = statusTask.flatMap((status) {
  return Task(() async {
    await sendStatusUpdate(status);
    return 'Notification sent';
  });
});
```

### Add Safe Side Effects (`tap`)

Log data or update variables without disrupting your pipeline:

```dart
final task = Task(() async => 'Log message data');

final tappedTask = task.tap((data) async {
  print('Writing to system log: $data');
});
```

### Execute in Batch (`sequence` / `traverse`)

Run arrays of tasks efficiently:

* `sequence`: Runs a list of tasks one by one, gathering the results.
* `traverse`: Maps your data into tasks and runs them sequentially.

```dart
final tasks = [
  Task(() async => 'Task A'),
  Task(() async => 'Task B'),
];

// Runs Task A, waits, then runs Task B
final Task<List<String>> batch = Task.sequence(tasks);
final results = await batch.run(); 

// Maps paths to tasks and runs them safely
final paths = ['log1.txt', 'log2.txt'];
final Task<List<int>> byteCounts = Task.traverse(
  paths,
  (path) => Task(() => File(path).length()),
);
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
  ```
* **Forgetting the trigger**: Because `Task` is lazy, writing `task.map(...)` does nothing on its own. You must call `await task.run()` to start the engine.
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
* [Either](either) - The synchronous counterpart for success/failure modeling.
