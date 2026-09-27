/// Thrown when an invalid annotation combination or AST structure is encountered during code generation.
class InvalidGenerationSourceError extends Error {
  final String message;
  final String? todo;

  InvalidGenerationSourceError(this.message, {this.todo});

  @override
  String toString() =>
      'InvalidGenerationSourceError: $message'
      '${todo != null ? '\nTODO: $todo' : ''}';
}
