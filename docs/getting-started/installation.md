---
outline: deep
---

# Installation

Getting started with Daxle takes just a few seconds. 

Because Daxle is lightweight and relies only on official Dart packages (like `async` and `meta`), you get a stable library that resists breaking changes and keeps your app bundle small.


## Prerequisites

Daxle leverages modern Dart features like sealed classes, pattern matching, and dot-shorthand constructors. 

To use Daxle, you need:
* **Dart SDK**: `>= 3.11.0 < 4.0.0`
* **Flutter SDK**: Any version bundled with Dart 3.11.0 or higher.


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
  daxle: ^3.0.0
```

Then fetch the package:

```bash
dart pub get
```


## Import the Library

Add this single import to the top of your file to start using Daxle:

```dart
import 'package:daxle/daxle.dart';
```
