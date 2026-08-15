/// An extension type providing zero-cost, type-safe nested field querying over [Map]s.
///
/// `QueryMap` allows extracting deeply nested properties using dot-notation paths
/// (e.g. `'services.server.host'`) or key lists without polluting the standard [Map] namespace.
///
/// In development, it differentiates a standard map from a queryable map.
/// At compile-time, it is completely erased down to the underlying [Map].
///
/// Example:
/// ```dart
/// final config = {
///   'services': {
///     'server': {'host': 'https://api.internal', 'port': 8080}
///   }
/// };
///
/// final query = QueryMap(config);
/// final host = query.get<String>('services.server.host'); // 'https://api.internal'
/// final port = query.get<int>('services.server.port'); // 8080
/// ```
extension type const QueryMap(Map<Object?, Object?> map) implements Object {
  // Regex for strictly matching indexed array fields (e.g. 'servers[1]', 'matrix[0][2]')
  // Ensures the entire segment consists of an array name followed by valid [digits] brackets
  // without any malformed or trailing junk (e.g. 'numbers[0]junk', 'numbers[[0]]', 'numbers[1.5]').
  static final RegExp _arrayFieldPattern = .new(r'^([^\[\]]+)((?:\[\d+\])+)$');

  // Regex for extracting numeric indices from brackets
  //
  // Ex: 'servers[1]' ==> 1
  static final RegExp _arrayIndexMatcher = .new(r'(?<=\[)\d+(?=\])');

  /// Safely extracts a nested value of type [T] at [path].
  ///
  /// Returns the value cast to [T] if the path exists and matches type [T].
  /// Returns `null` if any key along the path is missing, if an intermediate
  /// node is not a container, or if the value does not match type [T] (without
  /// throwing a [TypeError]).
  ///
  /// Example:
  /// ```dart
  /// final query = QueryMap({
  ///   'services': {
  ///     'server': {'host': 'https://api.internal', 'port': 8080},
  ///     'database': null,
  ///   },
  ///   'users': [
  ///     {'name': 'Alice', 'roles': ['admin', 'dev']},
  ///   ],
  ///   'cluster': {
  ///     101: {'status': 'UP'},
  ///   },
  /// });
  ///
  /// // Dot notation on maps:
  /// query.get<String>('services.server.host'); // 'https://api.internal'
  /// query.get<int>('services.server.port'); // 8080
  /// query.get<String>('services.server.missing'); // null
  ///
  /// // Type safety (returns null on mismatch without throwing):
  /// query.get<int>('services.server.host'); // null (value is a String)
  ///
  /// // Bracket notation on lists:
  /// query.get<String>('users[0].name'); // 'Alice'
  /// query.get<String>('users[0].roles[1]'); // 'dev'
  /// query.get<String>('users[0].roles[5]'); // null (out of bounds)
  ///
  /// // Non-string map keys (via key list):
  /// query.get<String>(['cluster', 101, 'status']); // 'UP'
  ///
  /// // Seamless integration with Option:
  /// final host = Option(query.get<String>('services.server.host'))
  ///     .getOrElse(() => 'https://fallback.internal');
  /// ```
  T? get<T>(Object path) {
    final (exists, value) = _traverse(path);
    return (exists && value is T) ? value : null;
  }

  /// Checks whether the nested [path] exists within the structure, regardless of its value.
  ///
  /// Returns `true` if the target field exists, even if its value is `null`, `false`,
  /// `0`, or empty. Returns `false` if any key along the path is missing or if
  /// attempting to traverse further into a primitive or `null` leaf.
  ///
  /// Example:
  /// ```dart
  /// final query = QueryMap({
  ///   'services': {
  ///     'server': {'host': 'https://api.internal', 'port': 8080},
  ///     'database': null,
  ///   },
  ///   'users': [
  ///     {'name': 'Alice', 'roles': ['admin', 'dev']},
  ///   ],
  ///   'cluster': {
  ///     101: {'status': 'UP'},
  ///   },
  /// });
  ///
  /// // Dot notation on maps:
  /// query.has('services.server.host'); // true
  /// query.has('services.server.missing'); // false
  ///
  /// // Bracket notation on lists:
  /// query.has('users[0].name'); // true
  /// query.has('users[0].roles[1]'); // true
  /// query.has('users[0].roles[5]'); // false (out of bounds)
  ///
  /// // Explicit null presence:
  /// query.has('services.database'); // true (key exists with null value)
  /// query.has('services.database.url'); // false (cannot traverse past null)
  ///
  /// // Non-string map keys (via key list):
  /// query.has(['cluster', 101, 'status']); // true
  /// query.has('cluster.101.status'); // false (dot notation only matches String keys)
  /// ```
  bool has(Object path) => _traverse(path).$1;

  (bool, dynamic) _traverse(Object path) {
    final traversalPath = _getTraversalOrder(path);
    final iter = traversalPath.iterator;

    dynamic curr = map;
    while (iter.moveNext()) {
      final key = iter.current;

      if (curr is! Map) return (false, null);

      // Simply continue with the nested structure if [curr] contains [key]
      //
      // Better than branching by each type such as `int`, `double` or `num` and etc
      if (curr.containsKey(key)) {
        curr = curr[key];
        continue;
      }

      // At this point, the key was not found directly in the map.
      // The only remaining possibility is that it's a list index like 'users[0]'.
      //
      // Since only Strings can have bracket syntax ('[0]'), any non-string key
      // (like a missing number 103 or a boolean) is definitely missing.
      if (key is! String) return (false, null);

      // Validate that this key strictly conforms to bracket-indexed array notation
      // (e.g. 'servers[1]' or 'matrix[0][2]') and does not contain malformed or
      // trailing characters (e.g. 'numbers[0]junk', 'numbers[[0]]', 'numbers[1.5]').
      final match = _arrayFieldPattern.firstMatch(key);
      if (match == null) return (false, null);

      final arrayName = match.group(1);
      final brackets = match.group(2);
      if (arrayName == null || brackets == null) return (false, null);

      // Check if this array exists
      if (!curr.containsKey(arrayName)) return (false, null);

      curr = curr[arrayName];

      final indexMatches = _arrayIndexMatcher.allMatches(brackets);
      final indexIter = indexMatches.iterator;

      // Process everything from [indexMatches]
      //
      // Supporting both single and multi-dimensional arrays
      //
      // - user[0]
      // - matrix[0][2]
      while (indexIter.moveNext()) {
        if (curr is! Iterable) return (false, null);

        final idx = int.tryParse(indexIter.current[0] ?? '');

        // Empty indexed keys or out-of-bounds indices are not valid
        //
        // services.servers[].host
        if (idx == null || idx < 0 || idx >= curr.length) return (false, null);

        curr = curr.elementAt(idx);
      }
    }

    return (true, curr);
  }

  Iterable<dynamic> _getTraversalOrder(Object path) => switch (path) {
    Iterable<dynamic> _ => path,
    String _ => path.split('.').where((p) => p.isNotEmpty),
    _ => throw ArgumentError(
      'Invalid type, expected either String or an Iterable',
      'path',
    ),
  };
}
