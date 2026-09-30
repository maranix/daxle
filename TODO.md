# Daxle TODO / Roadmap

## Open Items

### 1. Part-file support for annotated source files

**Status:** Todo  
**Priority:** High

Currently, generated files are strictly bound to the source file that carries the annotation. This requires the annotated file to be a **standalone** file — it cannot use `part of` directives.

This breaks common Flutter/Dart patterns such as a Bloc library where state and event files are parts of the bloc file:

```
bloc.dart        → part 'state.dart'; part 'event.dart'; part 'bloc.daxle.dart';
state.dart       → part of 'bloc.dart';
event.dart       → part of 'bloc.dart';
```

The annotation lives on `bloc.dart`, but code-gen tools like `freezed` and `json_serializable` handle this case transparently. Daxle should support the same pattern.

**Expected behaviour:** When a source file is a `part of` another file, the generator should walk up to the library root (the file that owns the `part` directives) and treat that as the annotated source, enabling generation that spans the whole library.

---

### 2. Deep / proxied `copyWith` for nested objects

**Status:** Todo  
**Priority:** Medium

Currently, updating a nested field requires explicit chaining of `copyWith` calls at every level:

```dart
// Current — verbose and repetitive
var updated = user.copyWith(
  address: user.address.copyWith(home: "123 Main St"),
);
```

The goal is proxied access so callers can mutate a nested field as if they were targeting the root object:

```dart
// Expected — concise, reads like a direct assignment
var updated = user.address.copyWith(home: "123 Main St");
```

This means the generated `copyWith` proxy on `user.address` should return a new **`User`** (the root type), not just a new `Address`.

Deep nesting (e.g. `user.address.billing.street.copyWith(...)`) should be supported as well.

---

### 3. *(Optional)* `CompositeAnnotation` — bundle multiple annotations into one

**Status:** Todo  
**Priority:** Low / Nice-to-have

Allow users to declare a named constant that combines several Daxle annotations and use it as a single annotation:

```dart
// Declaration (e.g. in a shared library or the same file)
const DataClass = CompositeAnnotation([
  Serializable(),
  CopyWith(),
  Stringify(),
  EqualsAndHashCode(),
]);

// Usage
@DataClass
class User { … }
```

This is purely syntactic sugar — the generator expands `@DataClass` into the constituent annotations before processing, so no new code-gen logic is required beyond the expansion step.

---

### 4. Dart Records (`(T1, T2)`) Support

**Status:** Done  
**Priority:** Medium

Daxle supports Dart record types in model fields and top-level record typedefs:
- **Serialization / Deserialization:**
  - Positional elements serialize as lists `[a, b]`.
  - Named elements serialize as maps `{"name": a, "age": b}`.
  - Supports field annotations (such as `@SerializedValue("custom_key")`).
  - Top-level record typedefs generate standalone `toMap`/`fromMap` / `toList`/`fromList` helpers and extensions.
- **Type Parsing:** AST parser (`ParsedType`) parses and validates record type signatures with nested delimiter support.

