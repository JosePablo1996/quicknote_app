// lib/models/note.dart

class Note {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;
  
  // Campos adicionales para mejorar la UI/UX
  bool isFavorite;      // Para marcar notas como favoritas
  bool isArchived;      // 👈 NUEVO CAMPO - Para notas archivadas (SOLO UNA VEZ)
  List<String> tags;    // Para categorizar notas
  String? colorHex;     // Para color personalizado (opcional)

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isFavorite = false,
    this.isArchived = false,      // 👈 NUEVO CAMPO - Por defecto no archivada
    this.tags = const [],
    this.colorHex,
  });

  // Crear desde JSON (para respuestas GET)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? json['updated_at'],
      deletedAt: json['deletedAt'] ?? json['deleted_at'],
      isFavorite: json['isFavorite'] ?? json['is_favorite'] ?? false,
      isArchived: json['isArchived'] ?? json['is_archived'] ?? false, // 👈 NUEVO CAMPO
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      colorHex: json['colorHex'] ?? json['color_hex'],
    );
  }

  // Convertir a JSON (para POST/PUT)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'content': content,
    };
    
    // Incluir isFavorite solo si es necesario para el backend
    data['isFavorite'] = isFavorite;
    data['isArchived'] = isArchived; // 👈 NUEVO CAMPO
    
    // Incluir tags si existen
    if (tags.isNotEmpty) {
      data['tags'] = tags;
    }
    
    return data;
  }

  // Método copyWith para crear copias modificadas
  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    bool? isFavorite,
    bool? isArchived,  // 👈 NUEVO CAMPO
    List<String>? tags,
    String? colorHex,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,  // 👈 NUEVO CAMPO
      tags: tags ?? this.tags,
      colorHex: colorHex ?? this.colorHex,
    );
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

  /// Obtener fecha de eliminación formateada (si existe)
  String? get formattedDeletedDate {
    return deletedAt != null ? _formatDate(deletedAt!) : null;
  }

  /// Obtener hora de creación (HH:MM)
  String get createdTime {
    if (createdAt.length >= 16) {
      return createdAt.substring(11, 16);
    }
    return '';
  }

  /// Saber si la nota fue actualizada
  bool get isUpdated => updatedAt != null && updatedAt != createdAt;

  /// Saber si la nota está eliminada (en papelera)
  bool get isDeleted => deletedAt != null;

  // 👈 ELIMINADO: Getter redundante 'isArchived' (ya existe como campo)

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

  /// Marcar como favorito (retorna nueva instancia usando copyWith)
  Note copyWithFavorite(bool value) {
    return copyWith(isFavorite: value);
  }

  /// Marcar como archivado (retorna nueva instancia usando copyWith)
  Note copyWithArchived(bool value) {
    return copyWith(isArchived: value);
  }

  /// Agregar un tag (retorna nueva instancia usando copyWith)
  Note addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// Remover un tag (retorna nueva instancia usando copyWith)
  Note removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// Marcar como eliminada (mover a papelera)
  Note markAsDeleted() {
    return copyWith(
      deletedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Restaurar desde papelera
  Note restore() {
    return copyWith(deletedAt: null);
  }

  /// Actualizar contenido y fecha de modificación
  Note update({String? newTitle, String? newContent}) {
    return copyWith(
      title: newTitle ?? title,
      content: newContent ?? content,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  // Método privado para formatear fechas
  String _formatDate(String date) {
    try {
      if (date.length >= 10) {
        final dateTime = DateTime.parse(date);
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      }
    } catch (e) {
      if (date.length >= 10) {
        final parts = date.substring(0, 10).split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      }
    }
    return date;
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, favorite: $isFavorite, archived: $isArchived, deleted: $isDeleted, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.isFavorite == isFavorite &&
        other.isArchived == isArchived &&  // 👈 NUEVO CAMPO
        other.colorHex == colorHex;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      createdAt,
      updatedAt,
      deletedAt,
      isFavorite,
      isArchived,  // 👈 NUEVO CAMPO
      colorHex,
    );
  }
}