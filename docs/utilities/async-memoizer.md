# AsyncMemoizer

`AsyncMemoizer` ensures that an asynchronous operation runs exactly once, caching the result permanently for all future callers.

## Why use AsyncMemoizer?

Sometimes you have an initialization routine (like setting up a database or fetching a user session) that multiple parts of your app might trigger, but it should strictly only execute once. `AsyncMemoizer` runs the task the first time it is called and immediately returns the cached future to all subsequent callers.

## Example

```dart
import 'package:daxle/daxle.dart';

class DatabaseHelper {
  final AsyncMemoizer<void> _memoizer = AsyncMemoizer<void>();

  Future<void> initDatabase() {
    return _memoizer.runOnce(() async {
      print('Initializing database...');
      await Future.delayed(const Duration(seconds: 2));
      print('Database ready.');
    });
  }
}

void main() async {
  final db = DatabaseHelper();

  // First call initializes the database
  await db.initDatabase();

  // Subsequent calls return immediately
  await db.initDatabase();
}
```

## When to use it
- **App Initialization:** Setting up logging, databases, or analytics services.
- **Lazy Loading:** Loading heavy resources only when they are first requested, but keeping them available for the rest of the app lifecycle.
- **Singletons:** Ensuring a singleton's async initialization logic only runs once.
