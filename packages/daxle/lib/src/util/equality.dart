/// Collection and deep equality utilities for Daxle.
library;

/// Checks equality of two lists.
bool $listEquals(List? a, List? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!$deepEquals(a[i], b[i])) return false;
  }
  return true;
}

/// Checks equality of two sets.
bool $setEquals(Set? a, Set? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (final element in a) {
    if (!b.contains(element)) {
      var found = false;
      for (final otherElement in b) {
        if ($deepEquals(element, otherElement)) {
          found = true;
          break;
        }
      }
      if (!found) return false;
    }
  }
  return true;
}

/// Checks equality of two maps.
bool $mapEquals(Map? a, Map? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key)) return false;
    if (!$deepEquals(entry.value, b[entry.key])) return false;
  }
  return true;
}

/// Checks equality of two iterables.
bool $iterableEquals(Iterable? a, Iterable? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  final itA = a.iterator;
  final itB = b.iterator;
  while (itA.moveNext()) {
    if (!itB.moveNext() || !$deepEquals(itA.current, itB.current)) return false;
  }
  return !itB.moveNext();
}

/// Deep equality comparison for any object or collection.
bool $deepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a is List && b is List) return $listEquals(a, b);
  if (a is Set && b is Set) return $setEquals(a, b);
  if (a is Map && b is Map) return $mapEquals(a, b);
  if (a is Iterable && b is Iterable) return $iterableEquals(a, b);
  return a == b;
}

/// Hash code calculation for a list.
int $listHashCode(List? list) {
  if (list == null) return 0;
  var hash = 1;
  for (var i = 0; i < list.length; i++) {
    hash = 0x1fffffff & (hash + $deepHashCode(list[i]));
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= hash >> 6;
  }
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= hash >> 11;
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// Hash code calculation for a set.
int $setHashCode(Set? set) {
  if (set == null) return 0;
  var hash = 0;
  for (final element in set) {
    hash = (hash + $deepHashCode(element)) & 0x3fffffff;
  }
  return hash;
}

/// Hash code calculation for a map.
int $mapHashCode(Map? map) {
  if (map == null) return 0;
  var hash = 0;
  for (final entry in map.entries) {
    final entryHash =
        ($deepHashCode(entry.key) ^ $deepHashCode(entry.value)) & 0x3fffffff;
    hash = (hash + entryHash) & 0x3fffffff;
  }
  return hash;
}

/// Hash code calculation for an iterable.
int $iterableHashCode(Iterable? iterable) {
  if (iterable == null) return 0;
  var hash = 1;
  for (final element in iterable) {
    hash = 0x1fffffff & (hash + $deepHashCode(element));
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= hash >> 6;
  }
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= hash >> 11;
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// Deep hash code for any object or collection.
int $deepHashCode(Object? value) {
  if (value == null) return 0;
  if (value is List) return $listHashCode(value);
  if (value is Set) return $setHashCode(value);
  if (value is Map) return $mapHashCode(value);
  if (value is Iterable) return $iterableHashCode(value);
  return value.hashCode;
}
