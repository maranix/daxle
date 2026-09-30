/// Functional compile-time code generator and AST inspection pipeline for Daxle.
///
/// Daxle Gen delivers zero-boilerplate, type-safe serialization (`toMap` and `fromMap`),
/// deep immutable copy with proxies (`copyWith`), structural equality (`operator ==` and
/// `hashCode`), and clean string representations (`toString`) directly targeting modern
/// Dart 3 features including primary constructors, pattern-matching switch expressions,
/// extension types, sealed classes, and record types.
///
/// ## Key Capabilities
///
/// * **Functional Serialization**: Generates pure top-level functions and extension
///   methods (`toMap`, `fromMap`, `toList`, `fromList`) avoiding reflective runtimes.
/// * **Deep and Proxied CopyWith**: Fluent mutation chains across nested hierarchies
///   (such as `user.copyWith.address.city(name: 'NYC')`) returning the root model.
/// * **Structural Equality**: Generates typed, collection-aware deep equality and hash
///   code implementations with tiered field comparison orders.
/// * **Dart 3 Records and Extension Types**: First-class support for record typedefs and
///   extension types with bidirectional mapping.
/// * **Discriminator Polymorphism**: Default and custom discriminators for sealed classes
///   with strict, human-readable diagnostics in [FormatException].
/// * **Zero-Drift CLI and Watcher**: Incremental file watching with debouncing, `--clean`,
///   `--force`, `--check`, and SHA-256 caching.
///
/// ## Primary Entrypoints
///
/// * [DaxleGenerator]: Core orchestration engine processing file generation passes.
/// * [DaxleCliRunner]: Command-line interface driver handling CLI flags and arguments.
/// * [DaxleAstParser]: AST parsing engine converting raw Dart files into [ParsedFile] models.
/// * [AnnotationRegistry]: Modular extensible registry for annotation handlers.
/// * [ContentCache]: SHA-256 fingerprinting cache storing generation states.
library;

export 'src/cache/content_cache.dart';
export 'src/cli/cli_runner.dart';
export 'src/cli/glob_filter.dart';
export 'src/generator/class_generator.dart';
export 'src/generator/copy_with_generator.dart';
export 'src/generator/daxle_generator.dart';
export 'src/generator/enum_generator.dart';
export 'src/generator/equality_generator.dart';
export 'src/generator/extension_type_generator.dart';
export 'src/generator/file_generator.dart';
export 'src/generator/record_generator.dart';
export 'src/generator/sealed_generator.dart';
export 'src/generator/stringify_generator.dart';
export 'src/generator/type_helper.dart';
export 'src/models/annotation_info.dart';
export 'src/models/case_style.dart';
export 'src/models/parsed_element.dart';
export 'src/models/parsed_type.dart';
export 'src/parser/annotations/annotation_context.dart';
export 'src/parser/annotations/annotation_handler.dart';
export 'src/parser/annotations/annotation_registry.dart';
export 'src/parser/annotations/member_annotation_handlers.dart';
export 'src/parser/annotations/type_annotation_handlers.dart';
export 'src/parser/daxle_ast_parser.dart';
export 'src/parser/daxle_file_visitor.dart';
export 'src/parser/generation_error.dart';
