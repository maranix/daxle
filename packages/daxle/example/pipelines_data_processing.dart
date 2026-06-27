import 'dart:async';
import 'package:daxle/daxle.dart';

// --- Sync Pipeline ---
// Standard Dart: Imperative parsing, manual try-catch, intermediate mutation
double processRawLogStandard(String raw) {
  try {
    final parts = raw.split(',');
    final number = double.parse(parts[1]);
    print('Processing value: $number');
    return number * 1.10;
  } catch (_) {
    return 0.0;
  }
}

// Daxle: Pure, lazy, composable steps with declarative error recovery
Pipeline<double> processRawLog(String raw) {
  return Pipeline(() => raw)
      .pipe((s) => s.split(','))
      .pipe((parts) => double.parse(parts[1]))
      .tap((val) => print('Processing value: $val'))
      .pipe((val) => val * 1.10)
      .recover((err, _) => 0.0);
}

// --- Async Pipeline & Concurrency ---
Future<int> queryActiveUsers() async {
  await Future.delayed(const Duration(milliseconds: 30));
  return 150;
}

Future<int> queryPendingTasks() async {
  await Future.delayed(const Duration(milliseconds: 20));
  return 9;
}

void main() async {
  print('--- Pipelines Demo ---');

  // Sync Pipeline processing
  print('Running sync pipeline:');
  final result = processRawLog('LOG-102, 100.0').run();
  print('Pipeline result: $result');

  // Async Pipeline zipping (evaluates queries concurrently)
  final users = AsyncPipeline(() => queryActiveUsers());
  final tasks = AsyncPipeline(() => queryPendingTasks());

  final report = users.zip(
    tasks,
    (u, t) => 'Active Users: $u, Pending Tasks: $t',
  );

  print('Evaluating async zip...');
  final output = await report.run();
  print('Result: $output');
}
