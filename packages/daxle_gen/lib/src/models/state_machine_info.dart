/// Represents a parsed `Flow(from: ..., to: ..., using: ...)` in a StateMachine.
class ParsedFlow {
  final String from;
  final String to;
  final String? using;
  final bool isExplicitAsync;

  const ParsedFlow({
    required this.from,
    required this.to,
    this.using,
    this.isExplicitAsync = false,
  });

  bool get isAutonomous => using == null;
}

/// Metadata extracted from `@StateMachine([Flow(...)])`.
class StateMachineInfo {
  final List<ParsedFlow> flows;
  final String? explicitStateType;
  final String? explicitEventType;

  const StateMachineInfo({
    required this.flows,
    this.explicitStateType,
    this.explicitEventType,
  });

  /// All unique state names in this state machine.
  Set<String> get allStates => {
    for (final flow in flows) ...[flow.from, flow.to],
  };

  /// All unique trigger event names in this state machine.
  Set<String> get allEvents => {
    for (final flow in flows)
      if (flow.using != null) flow.using!,
  };

  /// Complete adjacency map: fromState -> Set of allowed toStates.
  Map<String, Set<String>> get transitionsMap {
    final map = <String, Set<String>>{
      for (final state in allStates) state: <String>{},
    };
    for (final flow in flows) {
      map[flow.from]?.add(flow.to);
    }
    return map;
  }

  /// Set of states that have outgoing autonomous (non-using) edges.
  Set<String> get statesWithAutonomousOutgoing => {
    for (final flow in flows)
      if (flow.isAutonomous) flow.from,
  };

  /// Whether [state] is an async flow root (i.e. has outgoing autonomous edges).
  bool isAsyncFlowRoot(String state) =>
      statesWithAutonomousOutgoing.contains(state);

  /// Event flows: flows where using != null.
  List<ParsedFlow> get eventFlows =>
      flows.where((f) => !f.isAutonomous).toList();

  /// Autonomous flows: flows where using == null.
  List<ParsedFlow> get autonomousFlows =>
      flows.where((f) => f.isAutonomous).toList();
}
