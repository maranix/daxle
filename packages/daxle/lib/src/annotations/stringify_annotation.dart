import 'package:meta/meta.dart';

/// Marks a class or enum for [toString] generation.
@immutable
class const Stringify({
  /// Field names to ignore when generating [toString].
  final Iterable<String> ignoreFields = const [],
});

/// Constant instance of [Stringify] for concise `@stringify` annotation.
const stringify = Stringify();
