# Daxle Benchmarking Suite

This package provides a comprehensive benchmarking suite for Daxle. The goal of this suite is to measure execution time, memory usage, GC pressure, and to identify potential performance bottlenecks. It also compares Daxle against equivalent idiomatic Dart implementations.

## How to Run Benchmarks

To run the standard execution time and deep composition benchmarks, use the following command:

```sh
dart run bin/run_all.dart
```

This will run all benchmarks (Option, Either, TaskEither, Allocation, and Deep Composition) and output the execution time and average time per iteration.

## Profiling with Dart DevTools

Dart DevTools provides detailed insights into CPU performance, memory allocation, and garbage collection. To profile the benchmarks using DevTools:

1. Run the memory benchmarks (or any benchmark you want to profile) with the VM service and timeline enabled:

```sh
dart run --observe --enable-vm-service --pause-isolates-on-start bin/run_memory.dart
```

2. The output will provide a URL (e.g., `http://127.0.0.1:8181/...`). Open this URL in Dart DevTools (or follow the link in your IDE).
3. Resume the isolate from DevTools or your IDE to start the benchmark.

### How to Inspect Allocations

1. Open **Dart DevTools** and navigate to the **Memory** tab.
2. Select **Allocation Profile**.
3. You can click **Track Allocations** before running a specific portion of the code or take a **Snapshot** to see exactly how many instances of `Option`, `Either`, or `TaskEither` were allocated.
4. The memory benchmarks in this suite intentionally generate a lot of objects or hold onto them so you can easily analyze the heap.

### How to Inspect Garbage Collection

1. In **Dart DevTools**, go to the **Performance** tab (or **Timeline**).
2. The benchmark suite wraps each benchmark run with `Timeline.timeSync()`. This means you will see a labelled trace (e.g., "Memory Churn Option (GC Pressure)") in the performance timeline.
3. Look for "GC" (Garbage Collection) events in the timeline to see how often GC is triggered and how long it pauses execution. A high frequency of GC events indicates high GC pressure (e.g., too many temporary objects being created).

## Methodology and Rationale

To ensure benchmarks are accurate, fair, and not artificially inflated or optimized away by the Dart compiler, this suite adheres to the following principles:

### Avoidance of Compile-Time Constants
Compile-time constants (e.g., `Option.some(42)`) are highly susceptible to compiler optimizations. The AOT compiler can propagate constants, fold arithmetic, eliminate null checks, and remove branches, making the implementation unrealistically cheap.

### Usage of Runtime Values
To prevent constant folding, every iteration in the benchmarks is fed dynamic runtime values (like the current loop index `i`). This ensures that the Dart compiler cannot predict the final result ahead of time, accurately reflecting real-world dynamic usage.

### Identity Benchmarks
We include dedicated "Identity" benchmarks (e.g., `Option.map(identity)` where `int identity(int x) => x;`). These benchmarks isolate the raw abstraction cost of Daxle (dispatch overhead, closure invocation, pattern matching) independently from user computation logic.

### Fair Equivalent Workloads
Each benchmark performs the exact same logical work as its native Dart counterpart (e.g. `T?` for `Option`, `try/catch` for `Either`, `Future` for `TaskEither`). We ensure that neither implementation has an unfair advantage by simulating identical allocation and transformation steps.

## What Each Benchmark Measures

### 1. Option Benchmarks
Measures the overhead of constructing `Option.some` and `Option.none`, as well as transformations (`map`, `flatMap`, `fold`) compared to using native nullable types (`T?`).

### 2. Either Benchmarks
Measures the cost of using `Either.right` and `Either.left`, as well as their transformations. This is compared against the overhead of throwing and catching `Exception`s.

### 3. TaskEither Benchmarks
Measures the asynchronous execution overhead. It isolates lazy asynchronous workflows compared to eager `Future` execution. This also covers `sequence` and `traverse` combinators.

### 4. Deep Composition Benchmarks
Measures the performance of chaining operations (e.g., chaining `.map()` 1,000 times). In the real world, users compose many functional operations. These benchmarks help determine whether the Dart compiler successfully inlines operations or if closure and object allocation overhead accumulates significantly over deep chains.

### 5. Allocation Benchmarks
These benchmarks do nothing but allocate objects (no transformations or unwrapping). They are purely designed to measure the raw allocation cost of Daxle types.

### 6. Memory Benchmarks (Run via `bin/run_memory.dart`)
Designed specifically to cause GC pressure and heap growth. These use infinite loops or large arrays to retain objects, making it easier to analyze memory usage and GC pauses in Dart DevTools.

## Conclusions from Benchmarks

**What can be drawn:**
- Identifying regressions between different Daxle versions.
- Measuring the cost of abstraction (closure allocations and method dispatches) via identity benchmarks.
- Determining whether Daxle is a bottleneck in the hot path of an application.

**What cannot be drawn:**
- Absolute performance guarantees. Micro-benchmarks represent isolated, concentrated behavior and may not reflect macro-level application performance.
- Direct conclusions that Daxle is "faster" than native Dart; the objective is to ensure the overhead is negligible for the guarantees provided, not to beat language primitives.
