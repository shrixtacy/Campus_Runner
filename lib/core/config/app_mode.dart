class AppMode {
  static const bool backendEnabled = bool.fromEnvironment(
    'ENABLE_BACKEND',
    defaultValue: false,
  );
}
