# AsyncCache

`AsyncCache` automatically caches the result of an asynchronous operation for a specified duration, preventing repetitive and expensive network or database calls.

## Why use AsyncCache?

When fetching data that doesn't change frequently, repeatedly calling the same API wastes resources and slows down your application. `AsyncCache` lets you wrap these expensive operations and serve a cached response until the cache expires.

## Example

```dart
import 'package:daxle/daxle.dart';

// Cache the result for 10 minutes
final cache = AsyncCache<String>(const Duration(minutes: 10));

Future<String> fetchConfiguration() {
  return cache.fetch(() async {
    print('Making expensive network request...');
    await Future.delayed(const Duration(seconds: 2));
    return 'Remote Configuration Data';
  });
}

void main() async {
  // First call runs the closure
  print(await fetchConfiguration()); 
  
  // Second call returns immediately from the cache
  print(await fetchConfiguration()); 
}
```

## When to use it
- **Rate Limiting:** Prevent hammering an external API.
- **Static Data:** Caching configuration, feature flags, or static assets that change infrequently.
- **Performance:** Speed up UI rendering by serving cached data while updating the cache in the background (using `invalidate()`).
