/// State machine exceptions.
library;

import 'package:meta/meta.dart';

/// Thrown when an invalid state transition or event dispatch is attempted in a StateMachine.
///
/// > **Preview & Experimental**: This API is experimental and subject to change.
@experimental
final class InvalidFlowException implements Exception {
  /// Source state type where transition was attempted.
  final Type from;

  /// Target state or event type that was attempted.
  final Type attempted;

  /// Allowed target state types from [from].
  final Set<Type> allowed;

  const InvalidFlowException({
    required this.from,
    required this.attempted,
    required this.allowed,
  });

  @override
  String toString() =>
      'InvalidFlowException: Transition from $from to $attempted is not permitted. '
      'Allowed targets from $from: ${allowed.isEmpty ? "None (Terminal State)" : allowed.map((e) => e.toString()).join(', ')}';
}
