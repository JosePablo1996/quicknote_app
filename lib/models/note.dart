class Note {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String? updatedAt;
  
  // Campos adicionales para mejorar la UI/UX
  bool isFavorite;      // Para marcar notas como favoritas
  List<String> tags;    // Para categorizar notas
  String? colorHex;     // Para color personalizado (opcional)

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite = false,      // Por defecto no es favorito
    this.tags = const [],         // Por defecto sin tags
    this.colorHex,
  });

  // Crear desde JSON (para respuestas GET)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      // Valores por defecto si no vienen del backend
      isFavorite: json['is_favorite'] ?? false,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      colorHex: json['color_hex'],
    );
  }

  // Convertir a JSON (para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      // Solo enviamos al backend lo que necesita
    };
  }

  // Propiedades computadas útiles para la UI
  
  /// Obtener fecha formateada para mostrar (DD/MM/YYYY)
  String get formattedCreatedDate {
    return _formatDate(createdAt);
  }

  /// Obtener fecha de actualización formateada (si existe)
  String? get formattedUpdatedDate {
    return updatedAt != null ? _formatDate(updatedAt!) : null;
  }

  /// Obtener hora de creación (HH:MM)
  String get createdTime {
    if (createdAt.length >= 16) {
      return createdAt.substring(11, 16); // HH:MM
    }
    return '';
  }

  /// Saber si la nota fue actualizada
  bool get isUpdated => updatedAt != null && updatedAt != createdAt;

  /// Obtener extracto del contenido para vista previa
  String get excerpt {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  /// Obtener color asociado a la nota (para UI)
  int? get colorValue {
    if (colorHex != null && colorHex!.isNotEmpty) {
      try {
        return int.parse(colorHex!.replaceFirst('#', '0xff'));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Métodos de utilidad

  /// Verificar si contiene texto (para búsqueda)
  bool contains(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
           content.toLowerCase().contains(lowerQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  /// Marcar como favorito (retorna nueva instancia)
  Note copyWithFavorite(bool value) {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: value,
      tags: tags,
      colorHex: colorHex,
    );
  }

  /// Agregar un tag (retorna nueva instancia)
  Note addTag(String tag) {
    if (tags.contains(tag)) return this;
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
      tags: [...tags, tag],
      colorHex: colorHex,
    );
  }

  /// Remover un tag (retorna nueva instancia)
  Note removeTag(String tag) {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
      tags: tags.where((t) => t != tag).toList(),
      colorHex: colorHex,
    );
  }

  // Método privado para formatear fechas
  String _formatDate(String date) {
    if (date.length >= 10) {
      final parts = date.substring(0, 10).split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}'; // DD/MM/YYYY
      }
    }
    return date;
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, favorite: $isFavorite, tags: $tags)';
  }
}