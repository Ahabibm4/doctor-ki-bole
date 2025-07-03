class SavedResult {
  final int? id;
  final String type; // "symptom" or "report"
  final String input;
  final String result;
  final DateTime timestamp;

  SavedResult({
    this.id,
    required this.type,
    required this.input,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'input': input,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SavedResult.fromMap(Map<String, dynamic> map) {
    return SavedResult(
      id: map['id'],
      type: map['type'],
      input: map['input'],
      result: map['result'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
