---
outline: deep
---

::: info 🤖 AI-Assisted Documentation
Much of this documentation was drafted with the help of AI to provide you with comprehensive guides as quickly as possible. I have proofread and verified the content, but if you spot an inaccuracy I missed, please let me know!
:::

::: tip 🔄 Subject to Change
Daxle is actively evolving. This documentation is subject to change depending on new API updates, general maintenance, and feedback.
:::

# Introduction to Daxle

Welcome to **Daxle**. 

Daxle is a lightweight Dart 3+ toolkit engineered for high-performance data modeling, zero-cost map querying, sliding-window concurrency control, reactive stream transformations, and compile-time code generation.

Think of Daxle as the pragmatic companion to modern Dart. It eliminates defensive casting, simplifies asynchronous throttling, protects sensitive credentials, and automates data class boilerplate.


## The Problem in Modern Dart

Dart's native type system, pattern matching, and sealed classes provide an excellent foundation. However, building production services and apps often introduces recurring friction:

* **Fragile Map & JSON Traversal**: Navigating untyped nested maps leads to runtime `TypeError`s, `RangeError`s, and defensive null assertions.
* **Unconstrained Concurrency**: Uncontrolled `Future.wait` calls can overwhelm network bandwidth, exceed backend rate limits, or consume excess memory.
* **Leaking Secrets in Logs**: Accidentally printing configuration models or data structures often outputs raw API tokens or credentials into application logs.
* **Data Class Boilerplate**: Manually maintaining serialization, deep `copyWith` cloning, and structural equality across multi-collection models is repetitive and error-prone.


## The Daxle Solution: Practical, High-Performance Tools

Daxle focuses on **practical software engineering**. It provides tools that are:

* **Zero-Cost**: Extension types like `QueryMap` provide compile-time safe navigation with zero heap allocation overhead.
* **Controlled & Predictable**: `Concurrency` worker pools allow you to execute tasks sequentially, bounded, or unbounded with built-in early-abort safeguards.
* **Reactive & Composable**: Full re-export of `package:stream_transform` operators for declarative stream manipulation.
* **Secure by Design**: `@redact` annotations mask sensitive credentials in string and debug representations automatically.
* **Compile-Time Synthesized**: `daxle_gen` automates data class generation, record serialization, deep `copyWith` proxies, and preview state machines.


## Where to Go Next

Our documentation guides you from your first steps to advanced workflows:

* **[Getting Started](./installation)**: Install Daxle and follow the Quick Start guide.
* **[Migration Guide (v5.0.0)](./migration-v5)**: Upgrade existing projects from legacy Daxle v4.x.
* **[QueryMap](/core-types/query-map)**: Learn nested map, list, and matrix querying.
* **[Concurrency](/core-types/concurrency)**: Master sliding-window worker pools and throttled task execution.
* **[Utilities](/utilities/future-group)**: Discover helpful asynchronous utilities re-exported by Daxle.
