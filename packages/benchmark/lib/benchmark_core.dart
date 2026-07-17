import 'dart:async';
import 'dart:developer';

/// A global sink to prevent dead-code elimination.
int sinkInt = 0;
double sinkDouble = 0.0;
Object? sinkObject;
bool sinkBool = false;

/// Use this to prevent the compiler from optimizing away your benchmark code.
void sink(Object? value) {
  if (value is int) {
    sinkInt += value;
  } else if (value is double) {
    sinkDouble += value;
  } else if (value is bool) {
    sinkBool ^= value;
  } else {
    sinkObject = value;
  }
}

/// Use this if you just want to avoid optimizing away a single return.
@pragma('vm:never-inline')
void sinkBlackhole(Object? value) {
  sink(value);
}

abstract class Benchmark {
  final String name;
  final int iterations;

  const Benchmark(this.name, {this.iterations = 10000000});

  /// Set up the benchmark before run
  void setup() {}

  /// Tear down after the benchmark
  void teardown() {}

  /// The code to be measured. Subclasses must implement this.
  void run(int i);

  /// Warm up the VM. Runs the benchmark logic a few times.
  void warmup() {
    final warmupCount = iterations ~/ 10;
    for (int i = 0; i < warmupCount; i++) {
      run(i);
    }
  }

  void measure() {
    setup();
    warmup();

    final stopwatch = Stopwatch()..start();
    Timeline.timeSync(
      name,
      () {
        for (int i = 0; i < iterations; i++) {
          run(i);
        }
      },
    );
    stopwatch.stop();

    print(
        '${name.padRight(40)} | Iterations: $iterations | Time: ${stopwatch.elapsedMilliseconds.toString().padLeft(5)} ms | Avg: ${stopwatch.elapsedMicroseconds / iterations} µs/iter');

    teardown();
  }
}

abstract class AsyncBenchmark {
  final String name;
  final int iterations;

  const AsyncBenchmark(this.name, {this.iterations = 100000});

  Future<void> setup() async {}
  Future<void> teardown() async {}
  
  /// The code to be measured. Subclasses must implement this.
  Future<void> run(int i);

  Future<void> warmup() async {
    final warmupCount = iterations ~/ 10;
    for (int i = 0; i < warmupCount; i++) {
      await run(i);
    }
  }

  Future<void> measure() async {
    await setup();
    await warmup();

    final task = TimelineTask()..start(name);
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      await run(i);
    }

    stopwatch.stop();
    task.finish();

    print(
        '${name.padRight(40)} | Iterations: $iterations | Time: ${stopwatch.elapsedMilliseconds.toString().padLeft(5)} ms | Avg: ${stopwatch.elapsedMicroseconds / iterations} µs/iter');

    await teardown();
  }
}

void runBenchmarks(String suiteName, List<Benchmark> benchmarks) {
  print('========================================================================');
  print('Running Synchronous Benchmark Suite: $suiteName');
  print('========================================================================');
  for (final benchmark in benchmarks) {
    benchmark.measure();
  }
  print('');
}

Future<void> runAsyncBenchmarks(
    String suiteName, List<AsyncBenchmark> benchmarks) async {
  print('========================================================================');
  print('Running Asynchronous Benchmark Suite: $suiteName');
  print('========================================================================');
  for (final benchmark in benchmarks) {
    await benchmark.measure();
  }
  print('');
}
