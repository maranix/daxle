import 'package:meta/meta.dart';

/// Marks a class for equality (`operator ==`) and [hashCode] generation.
@immutable
class const EqualsAndHashCode({
  /// Field names to ignore when computing equality and hash code.
  final Iterable<String> ignoreFields = const [],
});

/// Constant instance of [EqualsAndHashCode] for concise `@equalsAndHashCode` annotation.
const equalsAndHashCode = EqualsAndHashCode();
