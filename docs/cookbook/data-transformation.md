---
outline: deep
---

# Data Transformation

## How do you safely transform and compose collections of data?


## The Problem With Batch Processing in Standard Dart

Imagine you need to process a collection of items—like reading system logs, parsing debug entries, and transforming the results. In standard Dart, you have to manually track loop counters, build error lists by hand, and write tedious `catch` blocks for every step.

If you try to speed things up with `Future.wait`, one single exception blows up the entire batch. Worse, you lose track of exactly which item caused the failure.

```dart
// Imperative collection processing: error prone, hard to collect separate failures
Future<Map<String, int>> processLogs(List<String> paths) async {
  final results = <String, int>{};
  for (final path in paths) {
    try {
      final content = await File(path).readAsString();
      final lines = content.split('\n').where((l) => l.contains('ERROR')).length;
      results[path] = lines;
    } catch (e) {
      // Manual recovery/handling of individual logs is verbose
      print('Failed to process $path: $e');
    }
  }
  return results;
}
```


## The Solution: Transform Collections with Complete Safety

Instead of wrestling with loops and `Future.wait`, use `TaskEither.traverse`. 

This maps your iterable inputs directly to secure tasks and runs them sequentially. Then, use `bimap` to effortlessly format both your success and failure outcomes at the item level.

```dart
import 'dart:io';
import 'package:daxle/daxle.dart';

// 1. Define transformation models
sealed class LogError {
  final String path;
  LogError(this.path);
}

class LogMissing extends LogError {
  LogMissing(super.path);
}

class LogMalformed extends LogError {
  LogMalformed(super.path);
}

class LogReport {
  final String path;
  final int errorCount;
  LogReport(this.path, this.errorCount);
}

// 2. Define the transformation for a single file path
TaskEither<LogError, LogReport> processSingleLog(String path) {
  return TaskEither.fromFuture(
    () => File(path).readAsString(),
    (_, __) => LogMissing(path),
  ).flatMap((content) {
    try {
      final lines = content.split('\n').where((l) => l.contains('[ERROR]')).length;
      return TaskEither.right(LogReport(path, lines));
    } catch (_) {
      return TaskEither.left(LogMalformed(path));
    }
  });
}

// 3. Transform and process the entire collection
TaskEither<LogError, List<LogReport>> processAllLogs(List<String> paths) {
  // traverse executes each processSingleLog sequentially
  return TaskEither.traverse(paths, processSingleLog);
}
```

Now, format your final batch results instantly using `bimap`:

```dart
void main() async {
  final filePaths = ['sys_log.txt', 'network_log.txt', 'db_log.txt'];

  final TaskEither<String, String> summaryTask = processAllLogs(filePaths).bimap(
    (logError) => switch (logError) {
      LogMissing(:final path) => 'Processing stopped: missing log file at $path',
      LogMalformed(:final path) => 'Processing stopped: malformed data in $path',
    },
    (reports) {
      final summary = reports.map((r) => '${r.path}: found ${r.errorCount} errors').join(', ');
      return 'Log processing complete! Results: [$summary]';
    },
  );

  final message = await summaryTask.fold((err) => err, (success) => success);
  print(message);
}
```


## Why You'll Love This Approach

* **Format Everything in One Step (`bimap`)**: Transform your success values and your errors at the exact same time. You can easily turn domain errors into user-friendly status messages before they leave your system.
* **Save Resources with Sequential Control**: `TaskEither.traverse` runs tasks one by one. If a critical task fails, execution stops immediately. You never waste I/O resources processing files when a dependency is already broken.
* **Ditch Manual List Operations**: Daxle does the heavy lifting. It automatically folds your list of tasks (`List<TaskEither>`) into a single task returning a list of values. Your code stays perfectly clean.
