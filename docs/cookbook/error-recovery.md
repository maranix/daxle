---
outline: deep
---

# Error Recovery

## Question
**How do I recover from failures?**

---

## Problem
In software engineering, operations fail for many reasons: network timeouts, read/write errors, or server issues. Writing fallback logic to handle these gracefully (e.g., try Server A, fallback to Server B, fallback to local disk, and finally default to hardcoded values) usually leads to nested blocks of try-catch handling where recovery logic gets buried.

```dart
// Imperative fallback logic: hard to read, easy to miss exceptions, eager execution of code
Future<Config> loadConfigWithFallback() async {
  try {
    return await api.fetchPrimaryConfig();
  } catch (primaryError) {
    print('Primary failed: $primaryError. Trying backup...');
    try {
      return await api.fetchBackupConfig();
    } catch (backupError) {
      print('Backup failed: $backupError. Trying local cache...');
      try {
        final content = await File('config_cache.json').readAsString();
        return Config.fromJson(content);
      } catch (cacheError) {
        print('Local cache failed: $cacheError. Using default.');
        return Config.defaultSettings();
      }
    }
  }
}
```

---

## Solution
Use Daxle's `orElse`, `getOrElse`, and `fold` combinators. Since Daxle's tasks are lazy, fallback tasks are only executed if and when the preceding step fails, allowing you to define a declarative recovery chain.

```dart
import 'dart:io';
import 'package:daxle/daxle.dart';

sealed class ConfigError {}
class NetworkError extends ConfigError { final String details; NetworkError(this.details); }
class CacheError extends ConfigError { final String details; CacheError(this.details); }

// 1. Define individual fallback tasks
TaskEither<ConfigError, Config> fetchPrimary() {
  return TaskEither.fromFuture(
    () => api.fetchPrimaryConfig(),
    (err, _) => NetworkError('Primary failed: $err'),
  );
}

TaskEither<ConfigError, Config> fetchBackup() {
  return TaskEither.fromFuture(
    () => api.fetchBackupConfig(),
    (err, _) => NetworkError('Backup failed: $err'),
  );
}

TaskEither<ConfigError, Config> readLocalCache() {
  return TaskEither.fromFuture(
    () => File('config_cache.json').readAsString(),
    (err, _) => CacheError('Cache read failed: $err'),
  ).flatMap((content) {
    try {
      return TaskEither.right(Config.fromJson(content));
    } catch (e) {
      return TaskEither.left(CacheError('Invalid json cache'));
    }
  });
}

// 2. Compose the recovery chain using orElse
TaskEither<ConfigError, Config> getConfigTask() {
  return fetchPrimary()
      .orElse((err) => fetchBackup())
      .orElse((err) => readLocalCache());
}
```

Now, when executing the task, you can fold the result or supply a final fallback config:

```dart
void main() async {
  final task = getConfigTask();
  
  // Resolve the task, falling back to a default configuration if everything failed
  final Config config = await task.fold(
    (error) {
      print('Warning: All configuration sources failed. Using defaults.');
      return Config.defaultSettings();
    },
    (successConfig) => successConfig,
  );

  print('Application running on port: ${config.port}');
}
```

---

## Why this solution works well with Daxle

* **Lazy evaluation preserves resources**: With eager `Future` structures, you must be careful not to trigger requests in parallel unless you intend to. Daxle's `orElse` keeps the fallback tasks lazy. The network request to `fetchBackup()` and the disk read to `readLocalCache()` are only initiated if the primary task returns a `Left`.
* **Clean, linear reading flow**: The recovery pipeline is expressed in a flat, natural chain of `.orElse()` statements rather than deeply nested `catch` brackets.
* **Separation of concerns**: You can change the order of recovery or inject additional fallback steps (e.g. trying an environment variable fallback) by adding a single line to the pipeline without refactoring the rest of your error logic.
