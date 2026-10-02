import 'package:code_builder/code_builder.dart';

import '../models/parsed_element.dart';
import '../models/state_machine_info.dart';

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
    final baseState = _inferBaseState(clazz, info.allStates, info.allEvents, parsedFile);
    final baseEvent = _inferBaseEvent(clazz, info.allEvents, parsedFile);

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

    // 3. Handler methods for all event-driven transitions
    final generatedHandlerSignatures = <String>{};
    for (final flow in info.eventFlows) {
      final handlerName = _deriveHandlerName(flow.to, clazz.name);
      final eventType = flow.using ?? 'dynamic';
      final signatureKey = '$handlerName($eventType)';

      if (!generatedHandlerSignatures.contains(signatureKey)) {
        generatedHandlerSignatures.add(signatureKey);
        final returnType = flow.isExplicitAsync ? 'Future<void>' : 'FutureOr<void>';
        final isTrivial = _isTrivial(flow, info, parsedFile);

        methods.add(
          Method(
            (m) {
              m
                ..name = handlerName
                ..returns = refer(returnType)
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
                  '/// Handler for transition: ${flow.from} -> ${flow.to} via $eventType.',
                );
              if (isTrivial) {
                m.body = const Code(''); // Default empty body for trivial instant transitions
              }
            },
          ),
        );
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

  bool _isTrivial(ParsedFlow flow, dynamic info, ParsedFile parsedFile) {
    if (flow.from == flow.to) return false;
    if (info.isAsyncFlowRoot(flow.to)) return false;
    final targetClass = parsedFile.classes
        .where((c) => c.name == flow.to)
        .firstOrNull;
    if (targetClass != null && targetClass.constructorParams.isNotEmpty) {
      return false;
    }
    if (flow.isExplicitAsync) return false;
    return true;
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
      final toInstantiation = _buildStateInstantiation(to, parsedFile);
      final handler = _deriveHandlerName(to, hostClassName);

      buffer.writeln('  case ($from(), final $eventType e):');
      buffer.writeln('    final epoch = ++_daxleEpoch;');
      if (from == to) {
        buffer.writeln('    $baseState activeState = currentState;');
      } else {
        buffer.writeln('    $baseState activeState = $toInstantiation;');
        buffer.writeln('    emit(activeState);');
      }
      buffer.writeln('    final scope = TransitionScope<$baseState>(');
      buffer.writeln('      getActiveState: () => activeState,');
      buffer.writeln('      setActiveState: (next) => activeState = next,');
      buffer.writeln('      isStillActive: () => epoch == _daxleEpoch,');
      buffer.writeln('      allowedTransitions: _\$transitions,');
      buffer.writeln('      emit: emit,');
      buffer.writeln('    );');
      buffer.writeln('    final result = $handler(scope, e);');
      buffer.writeln('    if (result is Future) await result;');
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

  String _inferBaseState(
    ParsedClass clazz,
    Set<String> allStates,
    Set<String> allEvents,
    ParsedFile parsedFile,
  ) {
    if (clazz.stateMachine?.explicitStateType != null) {
      return clazz.stateMachine!.explicitStateType!;
    }
    if (clazz.superclass == 'Bloc' && clazz.superclassTypeArguments.length >= 2) {
      return clazz.superclassTypeArguments[1];
    }
    if ((clazz.superclass == 'ValueNotifier' ||
            clazz.superclass == 'Notifier' ||
            clazz.superclass == 'AsyncNotifier') &&
        clazz.superclassTypeArguments.isNotEmpty) {
      return clazz.superclassTypeArguments[0];
    }

    final actualStates = allStates.difference(allEvents);
    if (actualStates.isEmpty) return 'dynamic';
    final superclasses = <String>{};
    for (final s in actualStates) {
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

  String _inferBaseEvent(
    ParsedClass clazz,
    Set<String> allEvents,
    ParsedFile parsedFile,
  ) {
    if (clazz.stateMachine?.explicitEventType != null) {
      return clazz.stateMachine!.explicitEventType!;
    }
    if (clazz.superclass == 'Bloc' && clazz.superclassTypeArguments.isNotEmpty) {
      return clazz.superclassTypeArguments[0];
    }
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
