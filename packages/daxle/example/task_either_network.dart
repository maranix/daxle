import 'dart:async';
import 'package:daxle/daxle.dart';

// Domain API error types
sealed class ApiError {
  final String description;
  const ApiError(this.description);
}

class NetworkError extends ApiError {
  const NetworkError(Object e) : super('Network connection failed: $e');
}

class UserNotFoundError extends ApiError {
  const UserNotFoundError(int userId) : super('User #$userId was not found.');
}

class OrderFetchError extends ApiError {
  const OrderFetchError(Object e) : super('Failed to retrieve orders: $e');
}

// User and Order models
class UserProfile {
  final int id;
  final String name;
  const UserProfile(this.id, this.name);
  @override
  String toString() => 'UserProfile(id: $id, name: $name)';
}

class Order {
  final String id;
  final double amount;
  const Order(this.id, this.amount);
  @override
  String toString() => 'Order(id: $id, amount: \$$amount)';
}

// Mock Api Service
class ApiService {
  Future<UserProfile> fetchUserProfileRaw(int id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (id == 404) {
      throw StateError('User not found');
    }
    if (id < 0) {
      throw TimeoutException('Connection timed out');
    }
    return UserProfile(id, 'User John Doe');
  }

  Future<List<Order>> fetchUserOrdersRaw(int id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return [const Order('ORD-101', 99.99), const Order('ORD-102', 49.50)];
  }
}

// Resilient Client implementing TaskEither
class ResilientRepository {
  final ApiService _api;
  ResilientRepository(this._api);

  // Wraps user fetch async call in TaskEither
  TaskEither<ApiError, UserProfile> getUserProfile(int id) {
    return .fromFuture(() => _api.fetchUserProfileRaw(id), (error, stack) {
      if (error is StateError && error.message.contains('not found')) {
        return UserNotFoundError(id);
      }
      return NetworkError(error);
    });
  }

  // Wraps orders fetch async call in TaskEither
  TaskEither<ApiError, List<Order>> getUserOrders(int id) {
    return .fromFuture(
      () => _api.fetchUserOrdersRaw(id),
      (error, stack) => OrderFetchError(error),
    );
  }

  // Composed: Fetch profile, and if successful, fetch orders, combining both results
  TaskEither<ApiError, (UserProfile, List<Order>)> getUserDashboard(int id) {
    return getUserProfile(id).flatMap((profile) {
      return getUserOrders(id).map((orders) => (profile, orders));
    });
  }
}

Future<void> runTaskEitherNetworkDemo() async {
  print('=== Scenario 2: Resilient Asynchronous Network Requests ===');
  final repository = ResilientRepository(ApiService());

  // Test Case A: Successful Dashboard fetch
  print('\nFetching Dashboard for User #101...');
  final successTask = repository.getUserDashboard(101);
  final successResult = await successTask.run();

  successResult.fold(
    (err) => print('  Dashboard fetch failed: ${err.description}'),
    (data) {
      final (profile, orders) = data;
      print('  Success!');
      print('    Profile: $profile');
      print('    Orders:  $orders');
    },
  );

  // Test Case B: User not found handling
  print('\nFetching Dashboard for User #404...');
  final missingUserResult = await repository.getUserDashboard(404).run();
  print('  Result: $missingUserResult');

  // Test Case C: Recovering using fallback profile using TaskEither.orElse
  print(
    '\nFetching Dashboard for User #-5 (network timeout) with local guest fallback...',
  );
  final failingTask = repository.getUserProfile(-5);

  final fallbackTask = failingTask.orElse((error) {
    print(
      '    [Repository Fallback] Fetch failed: ${error.description}. Activating Guest Profile.',
    );
    return TaskEither.right(const UserProfile(0, 'Guest User'));
  });

  final fallbackResult = await fallbackTask.run();
  print('  Result: $fallbackResult');

  print('\n--------------------------------------------------');
}
