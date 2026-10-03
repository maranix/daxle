import 'annotation_context.dart';

/// Base contract for modular, extensible annotation handlers.
abstract interface class AnnotationHandler<T> {
  /// All annotation identifier names recognized by this handler.
  List<String> get supportedNames;

  /// Parses annotation arguments into typed model [T].
  T parse(AnnotationContext context);
}
