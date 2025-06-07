class OperationLog {
  final String id;
  final DateTime timestamp;
  final String action;
  final String sourcePath;
  final String targetPath;
  final String status;
  final String? error;

  /// Constructor to initialize all required fields
  OperationLog({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.sourcePath,
    required this.targetPath,
    required this.status,
    this.error,
  });

  /// Create an instance from a map (used during decoding)
  factory OperationLog.fromMap(Map<String, dynamic> data) => OperationLog(
    id: data['id'] as String,
    timestamp: DateTime.parse(data['timestamp'] as String),
    action: data['action'] as String,
    sourcePath: data['sourcePath'] as String,
    targetPath: data['targetPath'] as String,
    status: data['status'] as String,
  );

  /// Convert the object back into a map (used for encoding/saving)
  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'action': action,
    'sourcePath': sourcePath,
    'targetPath': targetPath,
    'status': status,
    'error': error,
  };

  /// Check if operation was successful
  bool get isSuccessful => status == 'success';

  /// Return the reverse of the original operation
  Map<String, String> get reverseOperation {
    switch (action) {
      case 'move':
        return {'action': 'move', 'source': targetPath, 'target': sourcePath};
      case 'copy':
        return {'action': 'copy', 'source': targetPath, 'target': ''};
      case 'rename':
        return {'action': 'rename', 'source': targetPath, 'target': sourcePath};
      default:
        throw Exception('Unknown action for reverse: $action');
    }
  }
}

/// Represents the result of an undo operation
class UndoResult {
  final int operationsReversed;
  final List<String> errors;

  UndoResult({required this.operationsReversed, required this.errors});
}
