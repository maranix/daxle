import 'package:daxle/daxle.dart';

// Fluent querying of server host with Option and QueryMap
Option<String> getSanitizedServerHostSafe(Map<String, dynamic> config) {
  return Option(QueryMap(config))
      .map((q) => q.get<String>('services.server.host'))
      .map((host) => host.trim())
      .filter((host) => host.isNotEmpty && !host.startsWith('localhost'));
}

void main() {
  final Map<String, dynamic> appConfig = {
    'services': {
      'server': {
        'host': 'https://api.production.internal',
        'port': 8080,
      },
    },
  };

  final host = getSanitizedServerHostSafe(appConfig)
      .getOrElse(() => 'https://default-gateway.internal');

  print('Target host: $host'); // Prints: Target host: api.production.internal
}
