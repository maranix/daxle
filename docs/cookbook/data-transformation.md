---
outline: deep
---

# Data Transformation

## Question
**How do I transform and compose values?**

---

## Problem
When working with collections of items where each item needs to undergo asynchronous, fallible processing (such as reading a list of system log files, parsing debug entries, and transforming the output), standard Dart requires managing loop counters, collecting errors into lists, and catching exceptions manually.

If you attempt to run them concurrently with `Future.wait`, a single exception can cause the entire batch to fail, and you lose track of which specific file caused the failure.

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

---

## Solution
Use `TaskEither.traverse` to map an iterable of inputs to tasks and run them sequentially, and use `bimap` to format both success and failure outcomes at the item level.

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

You can now use `bimap` to map the final results of the batch process:

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

---

## Why this solution works well with Daxle

* **Dual-track mapping (`bimap`)**: With `bimap`, you can transform the success value and the failure error simultaneously. This allows you to easily format domain types into user-facing status messages at the boundaries of your system.
* **Sequential execution control**: `TaskEither.traverse` runs tasks one after another. If any task returns a `Left` failure, execution halts immediately. This prevents waste of I/O resources on subsequent files if a critical dependency is missing.
* **Collection compilation**: Daxle handles the heavy lifting of folding a list of tasks `List<TaskEither<L, B>>` into a single task returning a list of values `TaskEither<L, List<B>>`, keeping your code clean and free of manual list operations.
