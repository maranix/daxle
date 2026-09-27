/// Base contract for custom JSON converters.
abstract interface class DaxleJsonConverter<T, S> {
  const DaxleJsonConverter();

  /// Converts from JSON representation [json] of type [S] to Dart object [T].
  T fromJson(S json);

  /// Converts Dart object [object] of type [T] to JSON representation [S].
  S toJson(T object);
}
