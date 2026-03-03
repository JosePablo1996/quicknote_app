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
  bool isArchived;      // Para notas archivadas
  List<String> tags;    // Para categorizar notas
  String? colorHex;     // Para color personalizado (opcional)
  
  // CAMPOS PARA MODO OFFLINE
  bool isSynced;        // Indica si está sincronizado con el servidor
  String? localId;      // ID local para notas no sincronizadas
  bool isPending;       // Pendiente de sincronizar
  String? lastSyncError; // Error de la última sincronización

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isFavorite = false,
    this.isArchived = false,
    this.tags = const [],
    this.colorHex,
    this.isSynced = true,
    this.localId,
    this.isPending = false,
    this.lastSyncError,
  });

  // Crear desde JSON (para respuestas GET del servidor)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? json['updated_at'],
      deletedAt: json['deletedAt'] ?? json['deleted_at'],
      isFavorite: json['isFavorite'] ?? json['is_favorite'] ?? false,
      isArchived: json['isArchived'] ?? json['is_archived'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      colorHex: json['colorHex'] ?? json['color_hex'],
      // Por defecto, las notas del servidor están sincronizadas
      isSynced: true,
      isPending: false,
      lastSyncError: null,
    );
  }

  // Crear desde JSON local (para SQLite)
  factory Note.fromLocalJson(Map<String, dynamic> json) {
    return Note(
      id: json['server_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      isFavorite: json['is_favorite'] == 1,
      isArchived: json['is_archived'] == 1,
      tags: json['tags'] != null && json['tags'].isNotEmpty
          ? json['tags'].split(',').where((t) => t.isNotEmpty).toList()
          : [],
      colorHex: json['color_hex'],
      isSynced: json['is_synced'] == 1,
      localId: json['local_id'],
      isPending: json['is_pending'] == 1,
      lastSyncError: json['last_sync_error'],
    );
  }

  // Convertir a JSON (para POST/PUT del servidor)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'content': content,
    };
    
    data['isFavorite'] = isFavorite;
    data['isArchived'] = isArchived;
    
    if (tags.isNotEmpty) {
      data['tags'] = tags;
    }
    
    // No incluimos campos offline en las peticiones al servidor
    return data;
  }

  // ========== MÉTODO toLocalJson CORREGIDO ==========
  // Convertir a JSON para SQLite - VERSIÓN CORREGIDA
  Map<String, dynamic> toLocalJson() {
    final Map<String, dynamic> json = {
      'server_id': id > 0 ? id : null,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'is_favorite': isFavorite ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'tags': tags.join(','),
      'color_hex': colorHex,
      'is_synced': isSynced ? 1 : 0,
      'local_id': localId,
      'is_pending': isPending ? 1 : 0,
      'last_sync_error': lastSyncError,
    };
    
    // Eliminar campos null para evitar problemas con SQLite
    json.removeWhere((key, value) => value == null);
    
    return json;
  }

  // ========== MÉTODO COPYWITH ACTUALIZADO ==========
  // Método copyWith para crear copias modificadas
  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    bool? isFavorite,
    bool? isArchived,
    List<String>? tags,
    String? colorHex,
    bool? isSynced,
    String? localId,
    bool? isPending,
    String? lastSyncError,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      tags: tags ?? this.tags,
      colorHex: colorHex ?? this.colorHex,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
      isPending: isPending ?? this.isPending,
      lastSyncError: lastSyncError ?? this.lastSyncError,
    );
  }

  // ========== GETTERS Y MÉTODOS DE UTILIDAD PARA OFFLINE ==========

  /// Indica si la nota es offline (no sincronizada)
  bool get isOffline => !isSynced;

  /// Indica si tiene error de sincronización
  bool get hasSyncError => lastSyncError != null && lastSyncError!.isNotEmpty;

  /// Indica si la nota está eliminada (en papelera)
  bool get isDeleted => deletedAt != null;

  /// Obtener ID para la base de datos local (prioriza server_id, luego local_id)
  String? get dbId => id > 0 ? id.toString() : localId;

  /// Marcar como pendiente de sincronización
  Note markAsPending() {
    return copyWith(
      isPending: true,
      isSynced: false,
    );
  }

  /// Marcar como sincronizada con el servidor
  Note markAsSynced(int serverId) {
    return copyWith(
      id: serverId,
      isSynced: true,
      isPending: false,
      lastSyncError: null,
    );
  }

  /// Registrar error de sincronización
  Note withSyncError(String error) {
    return copyWith(
      lastSyncError: error,
      isPending: true,
    );
  }

  /// Generar ID local único para notas offline
  static String generateLocalId() {
    return 'local_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Crear una nota offline (nueva, sin sincronizar)
  factory Note.createOffline({
    required String title,
    required String content,
    bool isFavorite = false,
    bool isArchived = false,
    List<String> tags = const [],
    String? colorHex,
  }) {
    return Note(
      id: 0, // ID temporal, será asignado por el servidor después
      title: title,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
      isFavorite: isFavorite,
      isArchived: isArchived,
      tags: tags,
      colorHex: colorHex,
      isSynced: false,
      localId: generateLocalId(),
      isPending: true,
    );
  }

  // ========== PROPIEDADES COMPUTADAS PARA LA UI ==========
  
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

  // ========== MÉTODOS DE UTILIDAD EXISTENTES ==========

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
    return 'Note(id: $id, title: $title, favorite: $isFavorite, archived: $isArchived, '
        'synced: $isSynced, pending: $isPending, error: $lastSyncError, '
        'deleted: $isDeleted, tags: $tags)';
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
        other.isArchived == isArchived &&
        other.colorHex == colorHex &&
        other.isSynced == isSynced &&
        other.localId == localId &&
        other.isPending == isPending &&
        other.lastSyncError == lastSyncError;
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
      isArchived,
      colorHex,
      isSynced,
      localId,
      isPending,
      lastSyncError,
    );
  }
}