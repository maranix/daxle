---
outline: deep
---

# Installation

Daxle is lightweight, self-contained, and has no external dependencies other than standard Dart SDK packages, keeping your application bundle small and clean.

---

## Prerequisites

Daxle relies on modern Dart features, including sealed classes, pattern matching, type-directed constructor tear-offs, and dot-shorthand constructor syntax.

* **Supported Dart SDK**: `>= 3.11.0 < 4.0.0`
* **Supported Flutter SDK**: Compatible with any Flutter version bundled with Dart SDK `3.11.0` or higher.

---

## Adding the Dependency

To add Daxle to your project, run the following command in your terminal:

::: code-group
```bash [Dart CLI]
dart pub add daxle
```

```bash [Flutter CLI]
flutter pub add daxle
```
:::

Alternatively, you can manually add `daxle` to your `pubspec.yaml` file:

```yaml
dependencies:
  daxle: ^3.0.0
```

And retrieve the package:

```bash
dart pub get
```

---

## Importing the Library

To use Daxle in your Dart or Flutter files, import the package at the top of your file:

```dart
import 'package:daxle/daxle.dart';
```

---

## Verifying Your Installation

To verify that Daxle is installed and configured correctly, create a simple script and run it:

```dart
import 'package:daxle/daxle.dart';

void main() {
  // Construct an Option using dot-shorthand
  final Option<int> score = .some(100);

  // Extract the value using fold
  final message = score.fold(
    () => 'No score found',
    (val) => 'Score is $val',
  );

  print(message); // Prints: Score is 100
}
```

If the code runs successfully and prints `Score is 100`, Daxle is ready to be used in your codebase!
