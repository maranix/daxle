import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';

/// Generates the `_$ClassNameMachine` mixin for `@StateMachine` annotated classes.
class StateMachineGenerator {
  const StateMachineGenerator();

  /// Builds the state machine mixin specification.
  Mixin build(ParsedClass clazz, ParsedFile parsedFile) {
    final info = clazz.stateMachine;
    if (info == null) {
      throw StateError('Cannot generate state machine for class without @StateMachine: ${clazz.name}');
    }

    final mixinName = '_\$${clazz.name}Machine';
    final baseState = _inferBaseState(info.allStates, parsedFile);
    final baseEvent = _inferBaseEvent(info.allEvents, parsedFile);

    final methods = <Method>[];
    final fields = <Field>[];

    // 1. Static _$transitions table
    fields.add(
      Field(
        (b) => b
          ..name = '_\$transitions'
          ..static = true
          ..modifier = FieldModifier.constant
          ..type = refer('Map<Type, Set<Type>>')
          ..assignment = Code(_buildTransitionsMapCode(info))
          ..docs.add(
            '/// Complete adjacency matrix including both event-driven and non-using internal edges.',
          ),
      ),
    );

    // 2. Epoch tracker
    fields.add(
      Field(
        (b) => b
          ..name = '_daxleEpoch'
          ..type = refer('int')
          ..assignment = const Code('0'),
      ),
    );

    // 3. Abstract handler methods for async flow roots
    final generatedHandlerSignatures = <String>{};
    for (final flow in info.eventFlows) {
      if (info.isAsyncFlowRoot(flow.to)) {
        final handlerName = _deriveHandlerName(flow.to, clazz.name);
        final eventType = flow.using ?? 'dynamic';
        final signatureKey = '$handlerName($eventType)';

        if (!generatedHandlerSignatures.contains(signatureKey)) {
          generatedHandlerSignatures.add(signatureKey);
          methods.add(
            Method(
              (m) => m
                ..name = handlerName
                ..returns = refer('Future<void>')
                ..requiredParameters.addAll([
                  Parameter(
                    (p) => p
                      ..name = 'scope'
                      ..type = refer('TransitionScope<$baseState>'),
                  ),
                  Parameter(
                    (p) => p
                      ..name = 'event'
                      ..type = refer(eventType),
                  ),
                ])
                ..docs.add(
                  '/// Entry point for async flow: ${flow.from} -> ${flow.to} via $eventType.\n'
                  '/// Generated because ${flow.to} has autonomous (non-using) outgoing flows.',
                ),
            ),
          );
        }
      }
    }

    // 4. dispatch method
    methods.add(
      Method(
        (m) => m
          ..name = 'dispatch'
          ..returns = refer('Future<void>')
          ..modifier = MethodModifier.async
          ..requiredParameters.addAll([
            Parameter(
              (p) => p
                ..name = 'currentState'
                ..type = refer(baseState),
            ),
            Parameter(
              (p) => p
                ..name = 'event'
                ..type = refer(baseEvent),
            ),
          ])
          ..optionalParameters.add(
            Parameter(
              (p) => p
                ..name = 'emit'
                ..named = true
                ..required = true
                ..type = refer('void Function($baseState)'),
            ),
          )
          ..docs.add(
            '/// Evaluates and transitions states based on incoming events and the transition table.',
          )
          ..body = Code(_buildDispatchBody(info, clazz.name, baseState, parsedFile)),
      ),
    );

    return Mixin(
      (b) => b
        ..name = mixinName
        ..fields.addAll(fields)
        ..methods.addAll(methods),
    );
  }

  String _buildTransitionsMapCode(dynamic info) {
    final buffer = StringBuffer('{\n');
    for (final state in info.allStates) {
      final targets = (info.transitionsMap[state] as Set<String>?) ?? <String>{};
      buffer.write('    $state: {');
      buffer.write(targets.join(', '));
      buffer.writeln('},');
    }
    buffer.write('  }');
    return buffer.toString();
  }

  String _buildDispatchBody(
    dynamic info,
    String hostClassName,
    String baseState,
    ParsedFile parsedFile,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('switch ((currentState, event)) {');

    for (final flow in info.eventFlows) {
      final from = flow.from;
      final to = flow.to;
      final eventType = flow.using!;
      final isAsync = info.isAsyncFlowRoot(to);
      final toInstantiation = _buildStateInstantiation(to, parsedFile);

      if (isAsync) {
        final handler = _deriveHandlerName(to, hostClassName);
        buffer.writeln('  case ($from(), final $eventType e):');
        buffer.writeln('    final epoch = ++_daxleEpoch;');
        buffer.writeln('    $baseState activeState = $toInstantiation;');
        buffer.writeln('    emit(activeState);');
        buffer.writeln('    final scope = TransitionScope<$baseState>(');
        buffer.writeln('      getActiveState: () => activeState,');
        buffer.writeln('      setActiveState: (next) => activeState = next,');
        buffer.writeln('      isStillActive: () => epoch == _daxleEpoch,');
        buffer.writeln('      allowedTransitions: _\$transitions,');
        buffer.writeln('      emit: emit,');
        buffer.writeln('    );');
        buffer.writeln('    await $handler(scope, e);');
      } else {
        buffer.writeln('  case ($from(), final $eventType _):');
        buffer.writeln('    _daxleEpoch++;');
        buffer.writeln('    emit($toInstantiation);');
      }
    }

    buffer.writeln('  default:');
    buffer.writeln('    final allowed = _\$transitions[currentState.runtimeType] ?? const {};');
    buffer.writeln('    throw InvalidFlowException(');
    buffer.writeln('      from: currentState.runtimeType,');
    buffer.writeln('      attempted: event.runtimeType,');
    buffer.writeln('      allowed: allowed,');
    buffer.writeln('    );');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _buildStateInstantiation(String stateName, ParsedFile parsedFile) {
    final targetClass = parsedFile.classes
        .where((c) => c.name == stateName)
        .firstOrNull;
    if (targetClass != null && targetClass.constructorParams.isEmpty) {
      return 'const $stateName()';
    }
    return 'const $stateName()';
  }

  String _deriveHandlerName(String toState, String hostClassName) {
    var name = toState;
    if (name.startsWith('State') && name.length > 5) {
      name = name.substring(5);
    }
    final prefix = _findCommonPrefix(hostClassName, toState);
    if (prefix.isNotEmpty && name.startsWith(prefix) && name.length > prefix.length) {
      name = name.substring(prefix.length);
    }
    if (name.startsWith('State') && name.length > 5) {
      name = name.substring(5);
    }
    return 'on${name[0].toUpperCase()}${name.substring(1)}';
  }

  String _findCommonPrefix(String a, String b) {
    var i = 0;
    while (i < a.length && i < b.length && a[i] == b[i]) {
      i++;
    }
    return a.substring(0, i);
  }

  String _inferBaseState(Set<String> allStates, ParsedFile parsedFile) {
    if (allStates.isEmpty) return 'dynamic';
    final superclasses = <String>{};
    for (final s in allStates) {
      final c = parsedFile.classes.where((cl) => cl.name == s).firstOrNull;
      if (c?.superclass != null && c!.superclass != 'Object') {
        superclasses.add(c.superclass!);
      }
    }
    if (superclasses.length == 1) {
      return superclasses.first;
    }
    return 'dynamic';
  }

  String _inferBaseEvent(Set<String> allEvents, ParsedFile parsedFile) {
    if (allEvents.isEmpty) return 'dynamic';
    final superclasses = <String>{};
    for (final e in allEvents) {
      final c = parsedFile.classes.where((cl) => cl.name == e).firstOrNull;
      if (c?.superclass != null && c!.superclass != 'Object') {
        superclasses.add(c.superclass!);
      }
    }
    if (superclasses.length == 1) {
      return superclasses.first;
    }
    return 'dynamic';
  }
}
