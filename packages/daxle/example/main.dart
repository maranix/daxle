import 'option_example.dart';
import 'either_example.dart';
import 'task_either_network.dart';
import 'pipelines_data_processing.dart';

void main() async {
  print('==================================================');
  print('         DAXLE v2.0.0 REAL-WORLD DEMOS            ');
  print('==================================================\n');

  // Scenario 1: Option
  runOptionDemo();

  // Scenario 2: Either
  runEitherDemo();

  // Scenario 3: Network requests & error resilience (TaskEither)
  await runTaskEitherNetworkDemo();

  // Scenario 4: Data processing pipelines
  await runPipelinesDemo();

  print('==================================================');
  print('             ALL DEMOS RUN COMPLETED              ');
  print('==================================================');
}
