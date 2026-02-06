/// Input validation utilities
class Validators {
  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validate password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }

    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'This field'} must be at most $max characters';
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove non-digit characters for validation
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length < 10 || digits.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate username
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must be at most 20 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  /// Validate name (first/last)
  static String? name(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }

    if (value.length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters';
    }

    if (value.length > 50) {
      return '${fieldName ?? 'Name'} must be at most 50 characters';
    }

    return null;
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate date is in future
  static String? futureDate(DateTime? value) {
    if (value == null) {
      return 'Please select a date';
    }

    if (value.isBefore(DateTime.now())) {
      return 'Please select a future date';
    }

    return null;
  }

  /// Validate date is in past
  static String? pastDate(DateTime? value) {
    if (value == null) {
      return 'Please select a date';
    }

    if (value.isAfter(DateTime.now())) {
      return 'Please select a past date';
    }

    return null;
  }

  /// Validate age (must be at least 18)
  static String? age(DateTime? birthDate, {int minAge = 18}) {
    if (birthDate == null) {
      return 'Please select your birth date';
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year -
        (now.month < birthDate.month ||
                (now.month == birthDate.month && now.day < birthDate.day)
            ? 1
            : 0);

    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }

    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = num.tryParse(value);
    if (number == null || number <= 0) {
      return 'Please enter a valid positive number';
    }

    return null;
  }

  /// Combine multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

/// Extension for String validation
extension StringValidation on String? {
  bool get isValidEmail => Validators.email(this) == null;
  bool get isValidPassword => Validators.password(this) == null;
  bool get isValidPhone => Validators.phone(this) == null;
  bool get isValidUsername => Validators.username(this) == null;
  bool get isValidUrl => Validators.url(this) == null;
  bool get isNotEmpty => this != null && this!.trim().isNotEmpty;
}
