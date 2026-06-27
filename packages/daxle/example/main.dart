import 'option_either_validation.dart';
import 'task_either_network.dart';
import 'pipelines_data_processing.dart';

void main() async {
  print('==================================================');
  print('         DAXLE v2.0.0 REAL-WORLD DEMOS            ');
  print('==================================================\n');

  // Scenario 1: User Validation
  runOptionEitherValidationDemo();

  // Scenario 2: Network requests & error resilience
  await runTaskEitherNetworkDemo();

  // Scenario 3: Data processing pipelines
  await runPipelinesDemo();

  print('==================================================');
  print('             ALL DEMOS RUN COMPLETED              ');
  print('==================================================');
}
