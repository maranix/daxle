import 'package:meta/meta.dart';

/// Marks a class for copyWith extension generation.
@immutable
class const CopyWith({
  /// Field names to ignore when generating copyWith methods.
  final Iterable<String> ignoreFields = const [],
});

/// Constant instance of [CopyWith] for concise `@copyWith` annotation.
const copyWith = CopyWith();
