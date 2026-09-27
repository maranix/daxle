import 'dart:io';
import 'package:daxle_gen/src/cli/cli_runner.dart';

void main(List<String> args) async {
  final runner = DaxleCliRunner();
  final code = await runner.run(args);
  exit(code);
}
