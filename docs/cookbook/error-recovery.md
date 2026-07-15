---
outline: deep
---

# Error Recovery

## How do you gracefully recover from failures without writing spaghetti code?


## The Trap of Deeply Nested Fallbacks

Network timeouts happen. Servers crash. Disk reads fail. 

To keep your app alive, you write fallback logic: *Try Server A. If that fails, try Server B. If that fails, read the local disk. If that fails, use defaults.*

But in standard Dart, this creates a nightmare of nested `try-catch` blocks. Your actual recovery logic gets buried under layers of error-handling boilerplate.

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


## The Solution: Build Declarative Recovery Chains

You don't need nested `catch` blocks. Use Daxle's `orElse`, `getOrElse`, and `fold` combinators instead. 

Because Daxle tasks evaluate lazily, your fallback tasks only execute when the previous step actually fails. This lets you write a clean, declarative chain of fallbacks.

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

When you execute the task, just fold the result and provide your final default value:

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


## Why You'll Love This Approach

* **Never Waste Resources**: Eager `Futures` can accidentally trigger parallel requests. Daxle's `orElse` keeps your fallbacks strictly lazy. The backup network request and disk read only execute if the primary task actually fails.
* **Read Logic Like Plain English**: Your recovery pipeline becomes a flat, natural chain of `.orElse()` statements. Say goodbye to deep, unreadable `catch` brackets.
* **Adapt to Changes Instantly**: Need to add a new fallback source? Just insert a single `.orElse()` line. You can reorder or expand your recovery steps without touching the rest of your error logic.
