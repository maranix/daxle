import 'package:daxle/daxle.dart';

// Represents potential validation errors
sealed class ValidationError {
  final String message;
  const ValidationError(this.message);
}

class InvalidEmail extends ValidationError {
  const InvalidEmail() : super('Email format is invalid.');
}

class PasswordTooShort extends ValidationError {
  const PasswordTooShort() : super('Password must be at least 8 characters.');
}

class UsernameEmpty extends ValidationError {
  const UsernameEmpty() : super('Username cannot be empty.');
}

// User domain model
class User {
  final String username;
  final String email;
  final Option<String> phoneNumber; // Optional phone number

  const User({
    required this.username,
    required this.email,
    required this.phoneNumber,
  });

  @override
  String toString() =>
      'User(username: $username, email: $email, phone: ${phoneNumber.getOrElse("N/A")})';
}

// Input validation service
class RegistrationValidator {
  Either<ValidationError, String> validateUsername(String username) {
    if (username.trim().isEmpty) {
      return const .left(UsernameEmpty());
    }
    return .right(username.trim());
  }

  Either<ValidationError, String> validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return const .left(InvalidEmail());
    }
    return .right(email.trim());
  }

  Either<ValidationError, String> validatePassword(String password) {
    if (password.length < 8) {
      return const .left(PasswordTooShort());
    }
    return .right(password);
  }

  // Composes validations to create a User
  Either<ValidationError, User> registerUser({
    required String username,
    required String email,
    required String password,
    String? phoneNumber, // Nullable raw input
  }) {
    // Validate email
    return validateEmail(email).flatMap((validEmail) {
      // Validate password
      return validatePassword(password).flatMap((_) {
        // Validate username
        return validateUsername(username).map((validUsername) {
          // Construct User with safe Option.fromNullable phone number
          return User(
            username: validUsername,
            email: validEmail,
            phoneNumber: .fromNullable(phoneNumber),
          );
        });
      });
    });
  }
}

void runOptionEitherValidationDemo() {
  print('=== Scenario 1: Option & Either User Input Validation ===');
  final validator = RegistrationValidator();

  // Test Case A: A successful registration
  print('\nAttempting to register user Alice...');
  final successRegistration = validator.registerUser(
    username: 'Alice',
    email: 'alice@example.com',
    password: 'securePassword123',
    phoneNumber: '+1234567890',
  );

  successRegistration.fold(
    (error) => print('  Registration Failed: ${error.message}'),
    (user) => print('  Registration Successful! Created: $user'),
  );

  // Test Case B: Fails due to password length
  print('\nAttempting to register user Bob...');
  final failedRegistration = validator.registerUser(
    username: 'Bob',
    email: 'bob@example.com',
    password: 'short', // Too short!
    phoneNumber: null,
  );

  // Pattern matching on the validation outcome
  final message = switch (failedRegistration) {
    Left(value: final error) =>
      '  Validation failed with error: ${error.message}',
    Right(value: final user) => '  Successfully registered: ${user.username}',
  };
  print(message);

  print('\n--------------------------------------------------');
}
