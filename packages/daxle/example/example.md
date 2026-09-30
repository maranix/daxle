```dart
import 'dart:async';
import 'package:daxle/daxle.dart';
import 'package:daxle/async.dart';

void main() async {
  // 1. QueryMap: Zero-cost nested map and embedded list querying
  final payload = {
    'services': {
      'server': {'host': 'https://api.internal', 'port': 8080},
    },
    'users': [
      {'name': 'Alice', 'tags': ['admin', 'dev']},
    ],
  };

  final query = QueryMap(payload);
  final host = query.get<String>('services.server.host'); // 'https://api.internal'
  final firstTag = query.get<String>('users[0].tags[0]'); // 'admin'
  print('Host: $host, First tag: $firstTag');

  // 2. Concurrency: High-performance task pooling
  final tasks = [
    () async => 1,
    () async => 2,
    () async => 3,
  ];

  // Process tasks concurrently in worker batches of 2:
  final batchResult = await const Concurrency.bounded(2).process(tasks);
  print('Batch result: $batchResult'); // [1, 2, 3]

  // 3. Stream Transformation Utilities:
  final controller = StreamController<int>();
  final debounced = controller.stream.debounce(const Duration(milliseconds: 100));

  debounced.listen((event) => print('Debounced event: $event'));
  controller.add(1);
  controller.add(2);
  controller.close();
}
```
