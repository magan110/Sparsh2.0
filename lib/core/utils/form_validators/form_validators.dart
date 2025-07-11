/// Form validation utilities for advanced 3D forms
class FormValidators {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    
    return null;
  }

  /// Validates phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validates required fields
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters long';
    }
    
    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be no more than $maxLength characters long';
    }
    
    return null;
  }

  /// Validates numeric values
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  /// Validates positive numbers
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final numericValidation = validateNumeric(value, fieldName: fieldName);
    if (numericValidation != null) {
      return numericValidation;
    }
    
    final number = double.parse(value!);
    if (number <= 0) {
      return '${fieldName ?? 'This field'} must be a positive number';
    }
    
    return null;
  }

  /// Validates URL format
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validates date format
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validates PAN card format (Indian)
  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN is required';
    }
    
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid PAN card number';
    }
    
    return null;
  }

  /// Validates GST number format (Indian)
  static String? validateGST(String? value) {
    if (value == null || value.isEmpty) {
      return 'GST number is required';
    }
    
    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid GST number';
    }
    
    return null;
  }

  /// Validates Aadhaar number format (Indian)
  static String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhaar number is required';
    }
    
    final cleanValue = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleanValue.length != 12 || !RegExp(r'^[0-9]{12}$').hasMatch(cleanValue)) {
      return 'Please enter a valid 12-digit Aadhaar number';
    }
    
    return null;
  }

  /// Validates OTP format
  static String? validateOTP(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != length) {
      return 'OTP must be $length digits long';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }

  /// Validates confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates username format
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (value.length > 20) {
      return 'Username must be no more than 20 characters long';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    }
    
    return null;
  }

  /// Validates age
  static String? validateAge(String? value, {int minAge = 18, int maxAge = 120}) {
    final numericValidation = validateNumeric(value, fieldName: 'Age');
    if (numericValidation != null) {
      return numericValidation;
    }
    
    final age = int.parse(value!);
    if (age < minAge || age > maxAge) {
      return 'Age must be between $minAge and $maxAge';
    }
    
    return null;
  }

  /// Validates pincode format (Indian)
  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }
    
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value)) {
      return 'Please enter a valid 6-digit pincode';
    }
    
    return null;
  }

  /// Validates IFSC code format (Indian)
  static String? validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'IFSC code is required';
    }
    
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.toUpperCase())) {
      return 'Please enter a valid IFSC code';
    }
    
    return null;
  }

  /// Validates account number
  static String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    
    if (value.length < 9 || value.length > 18) {
      return 'Account number must be between 9 and 18 digits';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Account number must contain only numbers';
    }
    
    return null;
  }
}