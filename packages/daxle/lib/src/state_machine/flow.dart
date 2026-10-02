/// Declarative annotations defining state machines and transitions.
library;

/// Declarative annotation marking a class or mixin for state machine generation.
final class StateMachine<TState, TEvent> {
  /// Declared state flow transitions.
  final List<Flow> flows;

  const StateMachine(this.flows);
}

/// Defines a directed edge between states in a [StateMachine].
final class Flow {
  /// Source state type.
  final Type from;

  /// Destination state type.
  final Type to;

  /// External event type triggering this flow.
  ///
  /// If `null`, indicates an autonomous internal transition edge within an active async flow.
  final Type? using;

  const Flow({
    required this.from,
    required this.to,
    this.using,
  });
}
