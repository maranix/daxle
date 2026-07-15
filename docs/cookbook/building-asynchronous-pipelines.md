---
outline: deep
---

# Building Asynchronous Pipelines

## How do you compose multiple asynchronous operations cleanly?


## The Nightmare of Nested Try-Catch Blocks

If you build Dart backends or CLI tools, you chain asynchronous operations all the time. You read a file, send the data over a network, and save a status to your database. 

But when you mix eager `Future` calls from different libraries, you quickly end up with nested `try-catch` blocks. 

This creates three immediate problems:
1. You can't easily see where an exception started.
2. You struggle to stop the pipeline when an early step fails.
3. Your code becomes a wall of unreadable, imperative spaghetti.

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


## The Solution: Build Flat, Sequential Pipelines

Instead of fighting `Future` objects, wrap each asynchronous step in a `TaskEither`. 

Then, compose your operations into a flat pipeline using `flatMap` and `tap`. 

Your pipeline now executes lazily. If any step fails, execution halts immediately and hands you the exact error you need to fix.

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

To run this pipeline, just call `.run()` and await the result:

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


## Why You'll Love This Approach

* **Read Code Like a Book**: Your logic flows from top to bottom. You completely eliminate nested indentation and messy `try-catch` structures.
* **Catch Errors at Compile Time**: Each step declares its exact failure type, all unified under a sealed class. The compiler forces you to handle every possible error before your code even runs.
* **Stop Wasting Execution Time**: If an early step fails, Daxle automatically skips the rest. You don't have to write manual `if (succeeded)` checks.
* **Control Exactly When Code Runs**: Daxle composes the entire sequence but waits for you to call `.run()`. This gives you the power to trigger, delay, or retry your pipeline exactly when you want.
