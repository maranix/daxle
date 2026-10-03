---
outline: deep
---

# Quick Start

Welcome to the Daxle Quick Start guide. In this tutorial, you will build a robust microservice configuration parser and asynchronous service health checker using modern Daxle 5.

You will learn how to:
1. Safely parse nested configuration payloads with `QueryMap`.
2. Model configurations and sanitize sensitive credentials with `@redact`.
3. Concurrently inspect service endpoints with `Concurrency.bounded`.
4. Debounce and transform event streams using reactive operators.


## The Scenario

Imagine you are loading service configuration from a nested JSON or map structure (`Map<String, dynamic>`) containing server settings, database credentials, and upstream health endpoints.

Your requirements:
1. **Server Settings**: Safely retrieve host, nested port (defaulting to `8080`), and replica URLs.
2. **Security**: Protect database passwords and API tokens from leaking into logs via `toString()`.
3. **Health Validation**: Concurrently ping upstream services with a bounded concurrency pool (2 workers) and abort early on critical error.


## Step 1: Safely Query Nested Data with `QueryMap`

In standard Dart, extracting values from deeply nested maps requires defensive casting and risk of runtime `TypeError`s:

```dart
// The Standard Dart Approach: fragile and verbose
String? host;
final services = config['services'];
if (services is Map<String, dynamic>) {
  final server = services['server'];
  if (server is Map<String, dynamic> && server['host'] is String) {
    host = server['host'] as String;
  }
}
```

With Daxle's zero-cost `QueryMap`, you express this with dot notation and bracket indexing. Missing paths or type mismatches safely return `null`:

```dart
import 'package:daxle/daxle.dart';

class ServiceConfig {
  final String host;
  final int port;
  final String firstReplica;

  ServiceConfig({
    required this.host,
    required this.port,
    required this.firstReplica,
  });

  factory ServiceConfig.fromMap(Map<String, dynamic> raw) {
    final query = QueryMap(raw);

    return ServiceConfig(
      // 1. Dot notation:
      host: query.get<String>('services.server.host') ?? 'localhost',
      // 2. Safe type casting and fallback:
      port: query.get<int>('services.server.port') ?? 8080,
      // 3. Bracket notation for embedded lists:
      firstReplica: query.get<String>('services.replicas[0]') ?? 'http://replica-0',
    );
  }
}
```


## Step 2: Protect Secrets with `@redact`

When logging models in production, raw tokens or database credentials easily leak into logging pipelines. Daxle provides `@redact` to automatically sanitize secrets in string and debug representations:

```dart
import 'package:daxle/daxle.dart';

part 'auth_credentials.daxle.dart';

@serialize
@deserialize
@stringify
class AuthCredentials {
  final String username;

  @redact
  final String apiKey;

  const AuthCredentials({required this.username, required this.apiKey});
}

void main() {
  const creds = AuthCredentials(username: 'admin', apiKey: 'secret_live_token_99');

  // toString() masks apiKey -> AuthCredentials(username: admin, apiKey: ***)
  print(creds);

  // toDebugMap() masks apiKey -> {'username': 'admin', 'apiKey': '***'}
  print(creds.toDebugMap());

  // toMap() preserves raw apiKey for wire requests:
  print(creds.toMap());
}
```


## Step 3: Run Bounded Concurrent Checks with `Concurrency`

Uncontrolled `Future.wait` calls can overwhelm network interfaces and hit external API rate limits. Daxle's `Concurrency.bounded` limits active workers using a sliding-window pool backed by `package:pool`:

```dart
import 'package:daxle/async.dart';

Future<bool> checkEndpoint(String url) async {
  // Simulate network health check
  await Future<void>.delayed(const Duration(milliseconds: 100));
  return true;
}

void main() async {
  final endpoints = [
    'https://service-a.internal/health',
    'https://service-b.internal/health',
    'https://service-c.internal/health',
    'https://service-d.internal/health',
  ];

  // Process endpoints with at most 2 concurrent workers:
  final results = await const Concurrency.bounded(2).dispatch(
    endpoints,
    (url) => checkEndpoint(url),
    // Early-abort if an endpoint check returns false:
    shouldStop: (isHealthy) => !isHealthy,
  );

  print('All endpoints checked: $results');
}
```


## Step 4: Reactive Stream Pipeline with `stream_transform`

Daxle re-exports complete reactive stream operators directly from `package:stream_transform`. You can debounce rapid status inputs, filter events, and switch between streams:

```dart
import 'dart:async';
import 'package:daxle/async.dart';

void listenToHealthEvents(Stream<String> rawEvents) {
  rawEvents
      // 1. Debounce rapid notifications:
      .debounce(const Duration(milliseconds: 300))
      // 2. Filter empty messages:
      .where((event) => event.isNotEmpty)
      // 3. Transform:
      .map((event) => '[ALERT] $event')
      .listen(print);
}
```


## What's Next?

You just explored modern Daxle's core capabilities. Here is where to dive deeper:

* **[QueryMap Guide](/core-types/query-map)**: Deep dive into path syntax, matrix traversal, and non-string keys.
* **[Concurrency Guide](/core-types/concurrency)**: Master `.sequential`, `.bounded`, and `.unbounded` pooling.
* **[Migration Guide (v5.0.0)](/getting-started/migration-v5)**: Upgrading from Daxle v4? Follow our migration instructions.
