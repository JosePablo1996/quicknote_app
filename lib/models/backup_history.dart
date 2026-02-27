// models/backup_history.dart
class BackupHistory {
  final String fileName;
  final DateTime timestamp;
  final int totalNotes;
  final List<String> noteIds; // IDs de las notas en este backup
  final String? basedOn; // Backup anterior (para acumulativo)
  final List<String> newNotesIds; // IDs de notas nuevas desde último backup

  BackupHistory({
    required this.fileName,
    required this.timestamp,
    required this.totalNotes,
    required this.noteIds,
    this.basedOn,
    this.newNotesIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'timestamp': timestamp.toIso8601String(),
    'totalNotes': totalNotes,
    'noteIds': noteIds,
    'basedOn': basedOn,
    'newNotesIds': newNotesIds,
  };

  factory BackupHistory.fromJson(Map<String, dynamic> json) => BackupHistory(
    fileName: json['fileName'],
    timestamp: DateTime.parse(json['timestamp']),
    totalNotes: json['totalNotes'],
    noteIds: List<String>.from(json['noteIds']),
    basedOn: json['basedOn'],
    newNotesIds: List<String>.from(json['newNotesIds'] ?? []),
  );
}