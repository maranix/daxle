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

    // FutureOr handler for async flow root
    expect(output, contains('FutureOr<void> onBooting('));
    expect(output, contains('TransitionScope<StartupState> scope'));
    expect(output, contains('StartEngine event'));

    // Default concrete implementation for trivial reset
    expect(output, contains('FutureOr<void> onIdle('));
    expect(output, contains('ResetRequested event'));

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
    expect(output, contains('final result = onBooting(scope, e);'));
    expect(output, contains('if (result is Future) await result;'));

    // Default error throwing
    expect(output, contains('throw InvalidFlowException('));
    expect(output, contains('from: currentState.runtimeType'));
    expect(output, contains('attempted: event.runtimeType'));
  });

  test('resolves Bloc generic types, self-loops, and explicit Async marker', () {
    const blocSource = '''
import 'package:daxle/daxle.dart';

part 'onboarding_bloc.daxle.dart';

sealed class OnboardingState {}
final class OnboardingReady extends OnboardingState {}
final class OnboardingSelectVariants extends OnboardingState {}
final class OnboardingCompleting extends OnboardingState {}
final class OnboardingComplete extends OnboardingState {}
final class OnboardingError extends OnboardingState {}

sealed class OnboardingEvent {}
final class OnboardingVariantSelected extends OnboardingEvent {}
final class OnboardingCompleted extends OnboardingEvent {}

@StateMachine([
  Flow(from: OnboardingReady, to: OnboardingSelectVariants),
  Flow(
    from: OnboardingSelectVariants,
    to: OnboardingSelectVariants,
    using: OnboardingVariantSelected,
  ),
  Flow(
    from: OnboardingSelectVariants,
    to: OnboardingCompleting,
    using: Async<OnboardingCompleted>,
  ),
  Flow(from: OnboardingCompleting, to: OnboardingComplete),
  Flow(from: OnboardingCompleting, to: OnboardingError),
])
final class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> with _\$OnboardingBlocMachine {}
''';

    final parsedFile = parser.parseContent(blocSource, filePath: 'lib/onboarding_bloc.dart');
    final output = generator.generate(parsedFile);

    expect(output, isNotNull);
    expect(output, contains('mixin _\$OnboardingBlocMachine {'));

    // Inherited from Bloc<OnboardingEvent, OnboardingState>
    expect(output, contains('TransitionScope<OnboardingState> scope'));
    expect(output, contains('OnboardingState currentState'));
    expect(output, contains('OnboardingEvent event'));
    expect(output, isNot(contains('TransitionScope<dynamic>')));

    // Self-loop handler generated as FutureOr<void>
    expect(output, contains('FutureOr<void> onSelectVariants('));
    expect(output, contains('OnboardingVariantSelected event'));

    // Explicit Async<T> generates Future<void>
    expect(output, contains('Future<void> onCompleting('));
    expect(output, contains('OnboardingCompleted event'));

    // Self-loop retains currentState
    expect(output, contains('OnboardingState activeState = currentState;'));
  });
}
