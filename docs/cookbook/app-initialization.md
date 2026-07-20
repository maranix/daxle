# Graceful App Initialization

::: info 💡 Real-World Pattern
This guide demonstrates an initialization architecture adapted from a production Flutter application. Implementation details have been simplified for brevity.
:::

Critical services, databases, and dependencies needed throughout an application's lifecycle must initialize when the app starts. If any of these fail during startup, core features will break. 

Using Daxle's `TaskEither`, you can wrap asynchronous initialization logic into a clean, type-safe blueprint. This guarantees that startup failures are caught early and handled gracefully before rendering the main application.

## 1. Structuring the Initialization Blueprint

Group your critical dependency modules (such as core services, database connections, and repositories) and encapsulate their startup flow inside a `TaskEither`.

```dart
import 'package:daxle/daxle.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

abstract final class AppInitializer {
  static GetIt get _di => GetIt.instance;
  static final _logger = Logger('AppInitializer');

  // Modular registration tiers
  static const List<InjectableModule> _serviceModules = [
    ServicesModule(),
  ];

  static const List<InjectableModule> _dbModules = [
    DatabaseModule(),
  ];

  static const List<InjectableModule> _repositoryModules = [
    RepositoryModule(),
  ];

  static Future<void> _registerDependencies() async {
    // Concurrent initialization per tier
    await Future.wait(_serviceModules.map((m) => m.register(_di)));
    await Future.wait(_dbModules.map((m) => m.register(_di)));
    await Future.wait(_repositoryModules.map((m) => m.register(_di)));
  }

  /// Returns a lazy blueprint that encapsulates dependency registration and error logging.
  static TaskEither<String, void> initTask() => TaskEither.fromFuture(
    _registerDependencies,
    (err, stackTrace) {
      _logger.severe('App initialization failed', err, stackTrace);
      // Optional: Report failure to your crash reporter or error tracking service (e.g. Sentry / Firebase Crashlytics)
      // Crashlytics.instance.recordError(err, stackTrace);

      return 'Something went wrong while setting up the application. Please try restarting the app.';
    },
  );
}
```

## 2. Bootstrapping the Application

In your entry point (`main.dart`), execute the initialization task blueprint. Fold the resulting `Either` to cleanly decide whether to launch the main application or display a fallback error screen.

```dart
import 'package:flutter/material.dart';
import 'package:daxle/daxle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Execute the initialization task blueprint
  final initResult = await AppInitializer.initTask().run();

  // Route to error screen or main app based on initialization success
  final app = initResult.fold(
    (error) => AppErrorScreen(message: error),
    (_) => const MainApp(),
  );

  runApp(app);
}
```

## Key Benefits

1. **Guaranteed App Stability**: Prevents hidden crashes or unpredictable behavior by ensuring all critical modules are verified before the core UI mounts.
2. **Graceful Fallback**: If an essential dependency fails to initialize (e.g. database error or missing permission), the user is presented with a clear error screen rather than a frozen or broken UI.
3. **Lazy & Structured**: Execution remains entirely lazy until `.run()` is invoked in `main()`, making startup sequence predictable and easy to maintain.
