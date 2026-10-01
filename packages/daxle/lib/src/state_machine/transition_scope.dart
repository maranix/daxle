/// Scope passed to asynchronous flow handlers in a StateMachine.
library;

import 'exceptions.dart';

/// Provides safe, validated state transitions and liveness tracking for active asynchronous flows.
final class TransitionScope<TState> {
  final TState Function() _getActiveState;
  final void Function(TState) _setActiveState;
  final bool Function() _isStillActive;
  final Map<Type, Set<Type>> _allowedTransitions;
  final void Function(TState) _emit;

  TransitionScope({
    required TState Function() getActiveState,
    required void Function(TState) setActiveState,
    required bool Function() isStillActive,
    required Map<Type, Set<Type>> allowedTransitions,
    required void Function(TState) emit,
  })  : _getActiveState = getActiveState,
        _setActiveState = setActiveState,
        _isStillActive = isStillActive,
        _allowedTransitions = allowedTransitions,
        _emit = emit;

  /// Whether the flow execution that received this scope is still current.
  ///
  /// Returns `false` if the state machine has transitioned due to a newer event or flow.
  bool get isCurrent => _isStillActive();

  /// Transitions the state machine into [nextState].
  ///
  /// Validates that [nextState] is an allowed destination from current active state
  /// according to the state machine's flow table.
  /// Throws [InvalidFlowException] if transition is not permitted.
  /// Silently ignores transition if flow is no longer active ([isCurrent] is false).
  void transit(TState nextState) {
    if (!isCurrent) return;

    final current = _getActiveState();
    final allowed = _allowedTransitions[current.runtimeType] ?? const {};

    if (!allowed.contains(nextState.runtimeType)) {
      throw InvalidFlowException(
        from: current.runtimeType,
        attempted: nextState.runtimeType,
        allowed: allowed,
      );
    }

    _setActiveState(nextState);
    _emit(nextState);
  }
}
