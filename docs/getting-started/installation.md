---
outline: deep
---

# Installation

Getting started with Daxle is quick and straightforward. Daxle is intentionally designed to be lightweight and self-contained. It relies on no external dependencies other than standard Dart SDK packages, ensuring your application bundle remains exceptionally small and clean.

---

## Prerequisites

Daxle takes full advantage of modern Dart features, including sealed classes, robust pattern matching, type-directed constructor tear-offs, and convenient dot-shorthand constructor syntax.

* **Supported Dart SDK**: `>= 3.11.0 < 4.0.0`
* **Supported Flutter SDK**: Fully compatible with any Flutter version bundled with Dart SDK `3.11.0` or higher.

---

## Adding the Dependency

To introduce Daxle to your project, simply run the appropriate command for your environment in your terminal:

::: code-group
```bash [Dart CLI]
dart pub add daxle
```

```bash [Flutter CLI]
flutter pub add daxle
```
:::

Alternatively, if you prefer managing dependencies manually, you can add `daxle` directly to your `pubspec.yaml` file:

```yaml
dependencies:
  daxle: ^3.0.0
```

Then, retrieve the newly added package:

```bash
dart pub get
```

---

## Importing the Library

Once installed, you can start using Daxle in your Dart or Flutter files by adding a single import at the top of your file:

```dart
import 'package:daxle/daxle.dart';
```


