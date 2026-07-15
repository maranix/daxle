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

Daxle is the missing companion to the Dart standard library. It gives you expressive, type-safe, and composable abstractions that feel like a natural extension of the language you already know. 

Think of Daxle as the reliable connector for your app logic. It ties together data flows, error handling, and asynchronous operations so you can build robust Dart apps faster.


## The Problem with Modern Dart

Dart is powerful. With null safety, pattern matching, and sealed classes, you can build great software. 

But as your application grows, you often fall back on patterns that make your code fragile and hard to read:

* **Endless Null Checks**: You litter your code with `??`, `?.`, and `if (val != null)`. This hides your actual business logic.
* **Hidden Exceptions**: Exceptions can throw anywhere. You write defensive `try-catch` blocks, but you never know if you caught every error before runtime.
* **Runaway Futures**: Dart `Future`s start executing the second you create them. This makes them hard to retry, pass around safely, or compose before they run.


## The Daxle Solution: Practical, Professional Code

Daxle isn't about teaching you academic functional programming. You won't read about Category Theory or Monads here. 

Daxle focuses on **practical software engineering**. It gives you the tools to write code that is:

* **Inherently Safe**: Catch missing values and errors at compile-time. Stop runtime surprises.
* **Highly Expressive**: Write clean, declarative pipelines. Reveal the true intent of your logic at a glance.
* **Easily Composable**: Chain complex operations together without deep nesting or confusing temporary variables.
* **Completely Predictable**: Take absolute control over when your asynchronous operations run and how they recover from failure.


## Where to Go Next

Our documentation guides you from your first steps to advanced mastery:

* **[Getting Started](./installation)**: Install Daxle and build your first type-safe pipeline in the Quick Start guide.
* **[Core Types](/core-types/option)**: Learn the motivation and best practices behind `Unit`, `Option`, `Either`, `Task`, and `TaskEither`.
* **[Utilities](/utilities/future-group)**: Discover helpful asynchronous utilities re-exported by Daxle.
* **[Guides](/guides/error-handling)**: Master advanced error-handling strategies and complex asynchronous composition.
* **[Cookbook](/cookbook/working-with-optional-values)**: See Daxle in action with real-world recipes for input validation, networking, and state management.
