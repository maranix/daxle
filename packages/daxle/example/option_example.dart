import 'package:daxle/daxle.dart';

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

void runOptionDemo() {
  print('--- 1. Option Demo ---');
  final config = {'host': 'localhost', 'port': '8080'};

  // Retrieve port using Option
  final port = getPort(config);
  final activePort = port.getOrElse(80);
  print('Active Port: $activePort');
}
