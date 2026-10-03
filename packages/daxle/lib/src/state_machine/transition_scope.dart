/// Scope passed to asynchronous flow handlers in a StateMachine.
library;

import 'package:meta/meta.dart';
import 'exceptions.dart';

/// Provides safe, validated state transitions and liveness tracking for active asynchronous flows.
///
/// > **Preview & Experimental**: This API is experimental and subject to change.
@experimental
final class TransitionScope<TState> {
  final TState Function() getActiveState;
  final void Function(TState) setActiveState;
  final bool Function() isStillActive;
  final Map<Type, Set<Type>> allowedTransitions;
  final void Function(TState) emit;

  TransitionScope({
    required this.getActiveState,
    required this.setActiveState,
    required this.isStillActive,
    required this.allowedTransitions,
    required this.emit,
  });

  /// Whether the flow execution that received this scope is still current.
  ///
  /// Returns `false` if the state machine has transitioned due to a newer event or flow.
  bool get isCurrent => isStillActive();

  /// Transitions the state machine into [nextState].
  ///
  /// Validates that [nextState] is an allowed destination from current active state
  /// according to the state machine's flow table.
  /// Throws [InvalidFlowException] if transition is not permitted.
  /// Silently ignores transition if flow is no longer active ([isCurrent] is false).
  void transit(TState nextState) {
    if (!isCurrent) return;

    final current = getActiveState();
    final allowed = allowedTransitions[current.runtimeType] ?? const {};

    if (!allowed.contains(nextState.runtimeType)) {
      throw InvalidFlowException(
        from: current.runtimeType,
        attempted: nextState.runtimeType,
        allowed: allowed,
      );
    }

    setActiveState(nextState);
    emit(nextState);
  }
}
