class Note {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  // Crear desde JSON (para respuestas GET)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Convertir a JSON (para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}