import 'dart:async';
import 'package:daxle/daxle.dart';

// Mock database exceptions
class DbException implements Exception {}

Future<String> fetchUserRole(int id) async {
  if (id == 99) throw DbException();
  return 'admin';
}

Future<List<String>> fetchRolePermissions(String role) async {
  return ['read', 'write'];
}

// Standard Dart: Nested try-catches and manual exception handling
Future<List<String>> getPermissionsStandard(int id) async {
  try {
    final role = await fetchUserRole(id);
    return await fetchRolePermissions(role);
  } on DbException {
    return [];
  } catch (e) {
    return [];
  }
}

// Daxle: Declarative, lazy pipeline mapping errors to a safe Left
TaskEither<String, List<String>> getPermissions(int id) {
  return TaskEither.fromFuture(
    () => fetchUserRole(id),
    (err, _) => 'Failed to fetch user role: $err',
  ).flatMap((role) {
    return TaskEither.fromFuture(
      () => fetchRolePermissions(role),
      (err, _) => 'Failed to fetch role permissions: $err',
    );
  });
}

Future<void> runTaskEitherNetworkDemo() async {
  print('\n--- 2. TaskEither (Async) Demo ---');

  // Case A: Successful retrieval
  final successResult = await getPermissions(1).run();
  print('Permissions for User #1: $successResult');

  // Case B: Fail and recover with default values using orElse
  final failTask = getPermissions(99).orElse((err) {
    print('  [Fallback] Error occurred: $err. Returning guest permissions.');
    return TaskEither.right(['read']);
  });

  final finalResult = await failTask.run();
  print('Resolved permissions: $finalResult');
}
