---
outline: deep
---

# Installation

Getting started with Daxle takes just a few seconds. 

Because Daxle is lightweight and relies only on official Dart packages (like `async`, `meta`, and `pool`), you get a stable library that resists breaking changes and keeps your app bundle small.


## Prerequisites

Daxle leverages modern Dart features like sealed classes, pattern matching, records, extension types, and dot-shorthand constructors. 

To use Daxle, you need:
* **Dart SDK**: `>= 3.13.0 < 4.0.0`
* **Flutter SDK**: Any version bundled with Dart 3.13.0 or higher.


## Add the Dependency

Run the command for your environment to add Daxle to your project:

::: code-group
```bash [Dart CLI]
dart pub add daxle
```

```bash [Flutter CLI]
flutter pub add daxle
```
:::

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  daxle: ^5.1.0

# Optional: Add daxle_gen to dev_dependencies for compile-time code generation
dev_dependencies:
  daxle_gen: ^0.3.1
```

Then fetch the packages:

```bash
dart pub get
```


## Import the Library

Daxle organizes its exports into dedicated entrypoints:

```dart
// Core data modeling, QueryMap, structural equality, and preview state machine
import 'package:daxle/daxle.dart';

// Asynchronous concurrency, Pool, stream_transform, and async utilities
import 'package:daxle/async.dart';
```
