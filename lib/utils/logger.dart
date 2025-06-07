/// A simple logger to print messages with different levels (info, warn, error, debub)
class Logger {
  bool _verbose = false; // Whether to show debug messages

  // Turn verbose mode on or off
  void setVerbose(bool verbose) {
    _verbose = verbose;
  }

  /// Log info message
  void info(String message) {
    print('[INFO] $message');
  }

  /// Log warning message
  void warn(String message) {
    print('[WARN] $message');
  }

  /// Log error message
  void error(String message) {
    print('[ERROR] $message');
  }

  /// Log debug message (only in verbose mode)
  void debug(String message) {
    if (_verbose) print('[DEBUG] $message');
  }
}
