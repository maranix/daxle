import 'package:benchmark/benchmark_core.dart';

import 'package:benchmark/src/allocation_benchmark.dart';
import 'package:benchmark/src/deep_composition_benchmark.dart';
import 'package:benchmark/src/either_benchmark.dart';
import 'package:benchmark/src/option_benchmark.dart';
import 'package:benchmark/src/task_either_benchmark.dart';

void main() async {
  print('Starting Daxle Benchmark Suite...\n');

  // 1. Option Benchmarks
  runBenchmarks('Option (Sync)', [
    OptionSomeConstructionBenchmark(),
    FpdartOptionSomeConstructionBenchmark(),
    OptionNoneConstructionBenchmark(),
    FpdartOptionNoneConstructionBenchmark(),
    NullableConstructionBenchmark(),
    NullConstructionBenchmark(),
    
    OptionSomeMapBenchmark(),
    FpdartOptionSomeMapBenchmark(),
    OptionNoneMapBenchmark(),
    FpdartOptionNoneMapBenchmark(),
    NullableMapBenchmark(),
    NullMapBenchmark(),

    OptionSomeFlatMapBenchmark(),
    FpdartOptionSomeFlatMapBenchmark(),
    OptionNoneFlatMapBenchmark(),
    FpdartOptionNoneFlatMapBenchmark(),
    NullableFlatMapBenchmark(),

    OptionSomeFoldBenchmark(),
    FpdartOptionSomeFoldBenchmark(),
    OptionNoneFoldBenchmark(),
    FpdartOptionNoneFoldBenchmark(),
    NullableFoldBenchmark(),

    OptionIsSomeBenchmark(),
    FpdartOptionIsSomeBenchmark(),
    OptionIsNoneBenchmark(),
    FpdartOptionIsNoneBenchmark(),
    NullableIsNotNullBenchmark(),
    NullableIsNullBenchmark(),

    OptionSomePipelineBenchmark(),
    FpdartOptionSomePipelineBenchmark(),
    OptionNonePipelineBenchmark(),
    FpdartOptionNonePipelineBenchmark(),
    NullablePipelineBenchmark(),
    NullPipelineBenchmark(),
  ]);

  // 2. Either Benchmarks
  runBenchmarks('Either (Sync)', [
    EitherRightConstructionBenchmark(),
    FpdartEitherRightConstructionBenchmark(),
    EitherLeftConstructionBenchmark(),
    FpdartEitherLeftConstructionBenchmark(),
    BranchingRightConstructionBenchmark(),
    BranchingLeftConstructionBenchmark(),

    EitherRightMapBenchmark(),
    FpdartEitherRightMapBenchmark(),
    EitherLeftMapBenchmark(),
    FpdartEitherLeftMapBenchmark(),
    EitherRightMapLeftBenchmark(),
    FpdartEitherRightMapLeftBenchmark(),
    EitherLeftMapLeftBenchmark(),
    FpdartEitherLeftMapLeftBenchmark(),
    EitherRightBimapBenchmark(),
    FpdartEitherRightBimapBenchmark(),
    EitherLeftBimapBenchmark(),
    FpdartEitherLeftBimapBenchmark(),

    EitherRightFlatMapBenchmark(),
    FpdartEitherRightFlatMapBenchmark(),
    EitherLeftFlatMapBenchmark(),
    FpdartEitherLeftFlatMapBenchmark(),

    EitherRightFoldBenchmark(),
    FpdartEitherRightFoldBenchmark(),
    EitherLeftFoldBenchmark(),
    FpdartEitherLeftFoldBenchmark(),

    EitherRightPipelineBenchmark(),
    FpdartEitherRightPipelineBenchmark(),
    EitherLeftPipelineBenchmark(),
    FpdartEitherLeftPipelineBenchmark(),
    ExceptionSuccessPipelineBenchmark(),
    ExceptionErrorPipelineBenchmark(),
  ]);

  // 3. TaskEither Benchmarks (Async)
  await runAsyncBenchmarks('TaskEither (Async)', [
    TaskEitherRightConstructionBenchmark(),
    FpdartTaskEitherRightConstructionBenchmark(),
    TaskEitherLeftConstructionBenchmark(),
    FpdartTaskEitherLeftConstructionBenchmark(),
    FutureSuccessConstructionBenchmark(),
    FutureErrorConstructionBenchmark(),

    TaskEitherRightMapBenchmark(),
    FpdartTaskEitherRightMapBenchmark(),
    TaskEitherLeftMapBenchmark(),
    FpdartTaskEitherLeftMapBenchmark(),
    FutureSuccessMapBenchmark(),

    TaskEitherRightMapLeftBenchmark(),
    FpdartTaskEitherRightMapLeftBenchmark(),
    TaskEitherLeftMapLeftBenchmark(),
    FpdartTaskEitherLeftMapLeftBenchmark(),

    TaskEitherRightBimapBenchmark(),
    FpdartTaskEitherRightBimapBenchmark(),

    TaskEitherRightFlatMapBenchmark(),
    FpdartTaskEitherRightFlatMapBenchmark(),
    TaskEitherLeftFlatMapBenchmark(),
    FpdartTaskEitherLeftFlatMapBenchmark(),
    FutureSuccessFlatMapBenchmark(),

    TaskEitherLeftOrElseBenchmark(),
    FpdartTaskEitherLeftOrElseBenchmark(),
    TaskEitherRightEnsureBenchmark(),

    TaskEitherRightTapBenchmark(),
    TaskEitherLeftTapLeftBenchmark(),

    TaskEitherSequenceBenchmark(),
    TaskEitherTraverseBenchmark(),

    TaskEitherPipelineBenchmark(),
    FpdartTaskEitherPipelineBenchmark(),
    FuturePipelineBenchmark(),
  ]);

  // 4. Deep Composition Benchmarks
  runBenchmarks('Deep Composition (Sync)', [
    DeepOptionMapBenchmark(),
    FpdartDeepOptionMapBenchmark(),
    DeepOptionFlatMapBenchmark(),
    FpdartDeepOptionFlatMapBenchmark(),
    DeepNullableMapBenchmark(),
    DeepEitherMapBenchmark(),
    FpdartDeepEitherMapBenchmark(),
    DeepEitherFlatMapBenchmark(),
    FpdartDeepEitherFlatMapBenchmark(),
  ]);

  await runAsyncBenchmarks('Deep Composition (Async)', [
    DeepTaskEitherMapBenchmark(),
    FpdartDeepTaskEitherMapBenchmark(),
    DeepFutureMapBenchmark(),
    DeepTaskEitherFlatMapBenchmark(),
    FpdartDeepTaskEitherFlatMapBenchmark(),
  ]);

  // 5. Allocation Benchmarks
  runBenchmarks('Allocation (Sync)', [
    AllocationOptionSomeBenchmark(),
    AllocationOptionNoneBenchmark(),
    AllocationEitherRightBenchmark(),
    AllocationEitherLeftBenchmark(),
    AllocationTaskEitherRightBenchmark(),
    AllocationTaskEitherLeftBenchmark(),
  ]);

  print('\nAll standard benchmarks completed.');
  print('To run memory benchmarks, use `dart run bin/run_memory.dart` with Observatory.');
}
