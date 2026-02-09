class AppValidators {
  // Email validation (.in or .edu domains)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    final lower = value.toLowerCase();
    if (!(lower.endsWith('.in') || lower.endsWith('.edu'))) {
      return 'Please use your .in or .edu email ID';
    }
    return null;
  }

  // Ensures Price is reasonable (e.g., not ₹0 or ₹10,000)
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter amount';
    }
    final amount = int.tryParse(value);
    if (amount == null) return 'Invalid number';
    if (amount < 10) return 'Min ₹10';
    if (amount > 500) return 'Max ₹500';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
