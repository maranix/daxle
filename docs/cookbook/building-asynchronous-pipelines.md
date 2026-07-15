---
outline: deep
---

# Building Asynchronous Pipelines

## Question
**How do I compose multiple asynchronous operations cleanly?**

---

## Problem
In a typical Dart backend or CLI utility, you often need to chain several asynchronous operations together—such as reading a file, sending its contents over the network, and saving a confirmation status to a database. 

Mixing eager `Future` calls from different libraries usually results in nested `try-catch` blocks, making it difficult to figure out where an exception originated, and hard to stop the pipeline when an early step fails.

```dart
// Imperative async composition: verbose, hard to track failures, leaks exceptions
Future<void> runTelemetryPipeline(String path) async {
  try {
    final file = File(path);
    final data = await file.readAsString(); // might throw FileSystemException
    
    try {
      final response = await httpClient.post(Uri.parse('https://api.internal/metrics'), body: data); // might throw SocketException
      if (response.statusCode == 200) {
        try {
          await database.saveTelemetryStatus(path, 'SUCCESS'); // might throw DatabaseException
          print('Pipeline complete.');
        } catch (dbError) {
          print('Database failed: $dbError');
        }
      } else {
        print('Upload failed with status: ${response.statusCode}');
      }
    } catch (netError) {
      print('Network failed: $netError');
    }
  } catch (fileError) {
    print('File read failed: $fileError');
  }
}
```

---

## Solution
Wrap each asynchronous step in a `TaskEither` and compose them into a flat, sequential pipeline using `flatMap` and `tap`. The pipeline will execute lazily, and if any step fails, it will immediately halt and return the specific error.

```dart
import 'dart:io';
import 'package:daxle/daxle.dart';

// 1. Define distinct domain errors for each step
sealed class PipelineError {
  final String message;
  PipelineError(this.message);
}

class TelemetryReadError extends PipelineError {
  TelemetryReadError(super.message);
}

class TelemetryUploadError extends PipelineError {
  TelemetryUploadError(super.message);
}

class TelemetryDbError extends PipelineError {
  TelemetryDbError(super.message);
}

// 2. Define individual lazy tasks
TaskEither<PipelineError, String> readTelemetryFile(String path) {
  return TaskEither.fromFuture(
    () => File(path).readAsString(),
    (err, _) => TelemetryReadError('Failed to read file: $err'),
  );
}

TaskEither<PipelineError, int> uploadTelemetry(String data) {
  return TaskEither.fromFuture(
    () => httpClient.post(Uri.parse('https://api.internal/metrics'), body: data),
    (err, _) => TelemetryUploadError('Upload connection failed: $err'),
  ).flatMap((response) {
    return response.statusCode == 200
        ? TaskEither.right(response.statusCode)
        : TaskEither.left(TelemetryUploadError('Server rejected telemetry: ${response.statusCode}'));
  });
}

TaskEither<PipelineError, Unit> recordTelemetrySuccess(String path) {
  return TaskEither.fromFuture(
    () => database.saveTelemetryStatus(path, 'SUCCESS'),
    (err, _) => TelemetryDbError('Failed to record db status: $err'),
  ).map((_) => unit);
}

// 3. Compose the pipeline
TaskEither<PipelineError, Unit> buildPipeline(String path) {
  return readTelemetryFile(path)
      .flatMap((data) => uploadTelemetry(data))
      .flatMap((_) => recordTelemetrySuccess(path))
      .tap((_) => print('Pipeline completed successfully.'));
}
```

To run this pipeline, you simply call `.run()` and await the result:

```dart
void main() async {
  final pipeline = buildPipeline('telemetry_today.json');

  // Trigger lazy execution
  final result = await pipeline.run();

  result.fold(
    (error) => print('Telemetry pipeline failed: ${error.message}'),
    (success) => print('All systems nominal.'),
  );
}
```

---

## Why this solution works well with Daxle

* **Flat, readable flow**: The code reads from top to bottom. There are no nested indentation blocks or multiple levels of `try-catch` structures.
* **Granular type safety**: Each step declares its own failure type, yet they are all unified under the parent `PipelineError` sealed class. The compiler ensures you handle every possible error outcome.
* **Implicit short-circuiting**: You do not need to check `if (succeeded)` after each step. If `uploadTelemetry` fails, Daxle automatically skips `recordTelemetrySuccess` and returns the upload error.
* **Execution deferral**: The entire sequence is composed but does not run until `.run()` is called. This makes it trivial to trigger, delay, or retry the entire pipeline.
