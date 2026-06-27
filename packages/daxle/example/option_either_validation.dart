import 'package:daxle/daxle.dart';

// --- Option ---
// Standard Dart: Null checks and manual tryParse
int? getPortStandard(Map<String, String> config) {
  final val = config['port'];
  if (val == null) return null;
  return int.tryParse(val);
}

// Daxle: Composable, fluent chaining
Option<int> getPort(Map<String, String> config) {
  return Option.fromNullable(
    config['port'],
  ).flatMap((p) => .fromNullable(int.tryParse(p)));
}

// --- Either ---
// Standard Dart: throws runtime exceptions requiring try-catch callers
int divideStandard(int a, int b) {
  if (b == 0) throw ArgumentError('Cannot divide by zero');
  return a ~/ b;
}

// Daxle: failures represented explicitly as values
Either<String, int> divide(int a, int b) {
  if (b == 0) return const .left('Cannot divide by zero');
  return .right(a ~/ b);
}

void runOptionEitherValidationDemo() {
  print('--- 1. Option & Either Demo ---');
  final config = {'host': 'localhost', 'port': '8080'};

  // Retrieve port using Option
  final port = getPort(config);
  final activePort = port.getOrElse(80);
  print('Active Port: $activePort');

  // Handle divide using Either
  final result = divide(10, 0);
  final message = switch (result) {
    Left(value: final err) => 'Division failed: $err',
    Right(value: final val) => 'Result: $val',
  };
  print(message);
}
