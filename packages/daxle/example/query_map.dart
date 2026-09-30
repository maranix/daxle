import 'package:daxle/daxle.dart';

// Querying server host with QueryMap
String? getSanitizedServerHostSafe(Map<String, dynamic> config) {
  final host = QueryMap(config).get<String>('services.server.host')?.trim();
  if (host != null && host.isNotEmpty && !host.startsWith('localhost')) {
    return host;
  }
  return null;
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

  final host = getSanitizedServerHostSafe(appConfig) ??
      'https://default-gateway.internal';

  print('Target host: $host'); // Prints: Target host: api.production.internal
}
