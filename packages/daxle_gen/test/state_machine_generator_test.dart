import 'package:daxle_gen/src/generator/file_generator.dart';
import 'package:daxle_gen/src/parser/daxle_ast_parser.dart';
import 'package:test/test.dart';

void main() {
  const parser = DaxleAstParser();
  final generator = FileGenerator();

  const sourceCode = '''
import 'package:daxle/daxle.dart';

part 'startup_service.daxle.dart';

sealed class StartupState {
  const StartupState();
}
final class StartupIdle extends StartupState {
  const StartupIdle();
}
final class StartupBooting extends StartupState {
  const StartupBooting();
}
final class StartupProgress extends StartupState {
  final String step;
  const StartupProgress(this.step);
}
final class StartupReady extends StartupState {
  const StartupReady();
}
final class StartupFailure extends StartupState {
  final String error;
  const StartupFailure(this.error);
}

sealed class StartupEvent {
  const StartupEvent();
}
final class StartEngine extends StartupEvent {
  final String environment;
  const StartEngine(this.environment);
}
final class ResetRequested extends StartupEvent {
  const ResetRequested();
}

@StateMachine([
  Flow(from: StartupIdle, to: StartupBooting, using: StartEngine),
  Flow(from: StartupBooting, to: StartupProgress),
  Flow(from: StartupBooting, to: StartupReady),
  Flow(from: StartupBooting, to: StartupFailure),
  Flow(from: StartupProgress, to: StartupProgress),
  Flow(from: StartupProgress, to: StartupReady),
  Flow(from: StartupProgress, to: StartupFailure),
  Flow(from: StartupFailure, to: StartupIdle, using: ResetRequested),
])
final class StartupService with _\$StartupServiceMachine {}
''';

  test('parses StateMachine and Flow annotations into StateMachineInfo', () {
    final parsedFile = parser.parseContent(sourceCode, filePath: 'lib/startup_service.dart');
    final service = parsedFile.classes.firstWhere((c) => c.name == 'StartupService');

    expect(service.shouldGenerateStateMachine, isTrue);
    final sm = service.stateMachine!;
    expect(sm.flows.length, 8);

    expect(sm.allStates, containsAll(['StartupIdle', 'StartupBooting', 'StartupProgress', 'StartupReady', 'StartupFailure']));
    expect(sm.allEvents, containsAll(['StartEngine', 'ResetRequested']));

    expect(sm.isAsyncFlowRoot('StartupBooting'), isTrue);
    expect(sm.isAsyncFlowRoot('StartupProgress'), isTrue);
    expect(sm.isAsyncFlowRoot('StartupIdle'), isFalse);
    expect(sm.isAsyncFlowRoot('StartupFailure'), isFalse);
    expect(sm.isAsyncFlowRoot('StartupReady'), isFalse);

    expect(sm.transitionsMap['StartupIdle'], {'StartupBooting'});
    expect(sm.transitionsMap['StartupBooting'], {'StartupProgress', 'StartupReady', 'StartupFailure'});
    expect(sm.transitionsMap['StartupFailure'], {'StartupIdle'});
  });

  test('generates _\$StartupServiceMachine mixin matching specification', () {
    final parsedFile = parser.parseContent(sourceCode, filePath: 'lib/startup_service.dart');
    final output = generator.generate(parsedFile);

    expect(output, isNotNull);
    expect(output, contains('mixin _\$StartupServiceMachine {'));
    expect(output, contains('static const Map<Type, Set<Type>> _\$transitions = {'));
    expect(output, contains('StartupIdle: {StartupBooting}'));
    expect(output, contains('StartupBooting: {StartupProgress, StartupReady, StartupFailure}'));
    expect(output, contains('StartupFailure: {StartupIdle}'));

    expect(output, contains('int _daxleEpoch = 0;'));

    // Abstract async handler
    expect(output, contains('Future<void> onBooting('));
    expect(output, contains('TransitionScope<StartupState> scope'));
    expect(output, contains('StartEngine event'));

    // dispatch method
    expect(output, contains('Future<void> dispatch('));
    expect(output, contains('StartupState currentState'));
    expect(output, contains('StartupEvent event'));
    expect(output, contains('required void Function(StartupState) emit'));

    // Async flow switch case
    expect(output, contains('case (StartupIdle(), final StartEngine e):'));
    expect(output, contains('final epoch = ++_daxleEpoch;'));
    expect(output, contains('StartupState activeState = const StartupBooting();'));
    expect(output, contains('emit(activeState);'));
    expect(output, contains('await onBooting(scope, e);'));

    // Instant transition switch case
    expect(output, contains('case (StartupFailure(), final ResetRequested _):'));
    expect(output, contains('_daxleEpoch++;'));
    expect(output, contains('emit(const StartupIdle());'));

    // Default error throwing
    expect(output, contains('throw InvalidFlowException('));
    expect(output, contains('from: currentState.runtimeType'));
    expect(output, contains('attempted: event.runtimeType'));
  });
}
