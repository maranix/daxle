import 'package:daxle/daxle.dart';

// Standard Dart: Null checks, manual parsing and range validation
int? getPortStandard(Map<String, String> config) {
  final val = config['port'];
  if (val == null) return null;
  final parsed = int.tryParse(val);
  if (parsed == null) return null;
  if (parsed < 1024 || parsed > 65535) return null;
  return parsed;
}

// Daxle: Composable, predicate, and filter logic
Option<int> getPort(Map<String, String> config) {
  return Option(config['port'])
      .flatMap((p) => Option(int.tryParse(p)))
      .filter((p) => p >= 1024 && p <= 65535);
}

void main() {
  final config = {'host': 'localhost', 'port': '8080'};

  // Retrieve port using Option
  final port = getPort(config);
  final activePort = port.getOrElse(() => 80);
  print('Active Port: $activePort');

  // Verify predicate parsing
  final invalidPortConfig = {
    'host': 'localhost',
    'port': '80',
  }; // Port 80 is below 1024
  final invalidPort = getPort(invalidPortConfig);
  print('Is valid port 80? ${invalidPort.isSome}'); // false
}
