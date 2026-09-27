import 'dart:io';

void main(List<String> args) async {
  final forwardArgs = <String>['run', 'daxle_gen', 'generate'];
  if (args.isNotEmpty && args.first == 'generate') {
    forwardArgs.addAll(args.skip(1));
  } else {
    forwardArgs.addAll(args);
  }

  final process = await Process.start(
    Platform.executable,
    forwardArgs,
    mode: ProcessStartMode.inheritStdio,
  );

  final code = await process.exitCode;
  exit(code);
}
