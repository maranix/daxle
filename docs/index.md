---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: Daxle
  text: Practical Functional programming for Dart.
  tagline: Build safer, more expressive applications with composable types for optional values, error handling, and asynchronous computations.
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/introduction

    - theme: alt
      text: GitHub
      link: https://github.com/maranix/daxle

features:
  - title: Familiar & Expressive
    details: Designed specifically for Dart developers to model optional values, failures, and async pipelines explicitly with Option, Either, Task, and TaskEither.

  - title: Type-Safe by Design
    details: Leverage Dart's type system to eliminate null checks, prevent unhandled exceptions, and make invalid states unrepresentable.

  - title: Composable APIs
    details: Chain operations declaratively with map, flatMap, fold, and other functional combinators to build predictable code flow.

  - title: Async Control Flow
    details: Compose complex asynchronous workflows with Task and TaskEither while keeping error handling clean, explicit, and readable.
---