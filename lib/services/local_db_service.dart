// lib/services/local_db_service.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import '../models/note.dart';

class LocalDBService {
  static final LocalDBService _instance = LocalDBService._internal();
  factory LocalDBService() => _instance;
  LocalDBService._internal();

  static Database? _database;
  final _lock = Lock();

  // Nombre de la base de datos
  static const String _dbName = 'quicknote.db';
  static const int _dbVersion = 2; // 👈 INCREMENTADO A VERSIÓN 2

  // Nombres de tablas
  static const String tableNotes = 'notes';

  // Columnas de la tabla notes
  static const String columnId = 'id';
  static const String columnServerId = 'server_id';
  static const String columnTitle = 'title';
  static const String columnContent = 'content';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnDeletedAt = 'deleted_at';
  static const String columnIsFavorite = 'is_favorite';
  static const String columnIsArchived = 'is_archived';
  static const String columnTags = 'tags';
  static const String columnColorHex = 'color_hex';
  static const String columnIsSynced = 'is_synced';
  static const String columnLocalId = 'local_id';
  static const String columnIsPending = 'is_pending';
  static const String columnLastSyncError = 'last_sync_error';

  // Getter para la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    return _lock.synchronized(() async {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    });
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Crear tablas (primera vez)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNotes(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnServerId INTEGER,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT,
        $columnDeletedAt TEXT,
        $columnIsFavorite INTEGER DEFAULT 0,
        $columnIsArchived INTEGER DEFAULT 0,
        $columnTags TEXT,
        $columnColorHex TEXT,
        $columnIsSynced INTEGER DEFAULT 1,
        $columnLocalId TEXT,
        $columnIsPending INTEGER DEFAULT 0,
        $columnLastSyncError TEXT,
        UNIQUE($columnServerId)
      )
    ''');
    
    // Crear índices para búsquedas rápidas
    await db.execute('CREATE INDEX idx_server_id ON $tableNotes($columnServerId)');
    await db.execute('CREATE INDEX idx_is_synced ON $tableNotes($columnIsSynced)');
    await db.execute('CREATE INDEX idx_is_pending ON $tableNotes($columnIsPending)');
    await db.execute('CREATE INDEX idx_deleted_at ON $tableNotes($columnDeletedAt)');
    await db.execute('CREATE INDEX idx_favorite ON $tableNotes($columnIsFavorite)');
    await db.execute('CREATE INDEX idx_archived ON $tableNotes($columnIsArchived)');
    await db.execute('CREATE INDEX idx_local_id ON $tableNotes($columnLocalId)'); // 👈 NUEVO ÍNDICE
    
    debugPrint('✅ Base de datos local creada correctamente');
  }

  // Actualizar base de datos (cuando cambia la versión)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Actualizando base de datos de v$oldVersion a v$newVersion');
    
    if (oldVersion < 2) {
      // Migración a versión 2: asegurar índices y columnas
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_local_id ON $tableNotes($columnLocalId)');
        debugPrint('✅ Índice idx_local_id creado');
      } catch (e) {
        debugPrint('⚠️ Error creando índice: $e');
      }
    }
  }

  // ========== MÉTODOS CRUD ==========

  // Insertar una nota
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(tableNotes, note.toLocalJson());
  }

  // Insertar múltiples notas (batch)
  Future<void> insertNotes(List<Note> notes) async {
    final db = await database;
    final batch = db.batch();
    
    for (var note in notes) {
      batch.insert(tableNotes, note.toLocalJson());
    }
    
    await batch.commit(noResult: true);
  }

  // Obtener todas las notas (incluyendo eliminadas si se especifica)
  Future<List<Note>> getAllNotes({bool includeDeleted = false}) async {
    final db = await database;
    
    String? whereClause;
    if (!includeDeleted) {
      whereClause = '$columnDeletedAt IS NULL';
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: whereClause,
      orderBy: '$columnCreatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromLocalJson(maps[i]);
    });
  }

  // Obtener notas activas (no eliminadas)
  Future<List<Note>> getActiveNotes() async {
    return getAllNotes(includeDeleted: false);
  }

  // Obtener notas por ID de servidor
  Future<Note?> getNoteByServerId(int serverId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnServerId = ?',
      whereArgs: [serverId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return Note.fromLocalJson(maps.first);
  }

  // Obtener notas por ID local
  Future<Note?> getNoteByLocalId(String localId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnLocalId = ?',
      whereArgs: [localId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return Note.fromLocalJson(maps.first);
  }

  // Obtener notas eliminadas (en papelera)
  Future<List<Note>> getDeletedNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnDeletedAt IS NOT NULL',
      orderBy: '$columnDeletedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromLocalJson(maps[i]);
    });
  }

  // Obtener notas por su estado de eliminación
  Future<List<Note>> getNotesByDeletionStatus({required bool isDeleted}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: isDeleted 
          ? '$columnDeletedAt IS NOT NULL'
          : '$columnDeletedAt IS NULL',
      orderBy: '$columnCreatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromLocalJson(maps[i]);
    });
  }

  // Actualizar una nota
  Future<int> updateNote(Note note) async {
    final db = await database;
    
    // Determinar el criterio de actualización
    if (note.id > 0) {
      return await db.update(
        tableNotes,
        note.toLocalJson(),
        where: '$columnServerId = ?',
        whereArgs: [note.id],
      );
    } else if (note.localId != null) {
      return await db.update(
        tableNotes,
        note.toLocalJson(),
        where: '$columnLocalId = ?',
        whereArgs: [note.localId],
      );
    } else {
      return await db.update(
        tableNotes,
        note.toLocalJson(),
        where: '$columnId = ?',
        whereArgs: [note.id],
      );
    }
  }

  // Eliminar una nota por serverId (físicamente)
  Future<int> deleteNote(int serverId) async {
    final db = await database;
    return await db.delete(
      tableNotes,
      where: '$columnServerId = ?',
      whereArgs: [serverId],
    );
  }

  // Eliminar una nota por localId (para notas offline)
  Future<int> deleteNoteByLocalId(String localId) async {
    final db = await database;
    return await db.delete(
      tableNotes,
      where: '$columnLocalId = ?',
      whereArgs: [localId],
    );
  }

  // Eliminar notas por IDs (múltiples serverIds)
  Future<void> deleteNotes(List<int> serverIds) async {
    final db = await database;
    final batch = db.batch();
    
    for (var id in serverIds) {
      batch.delete(
        tableNotes,
        where: '$columnServerId = ?',
        whereArgs: [id],
      );
    }
    
    await batch.commit(noResult: true);
  }

  // ========== MÉTODOS PARA SINCRONIZACIÓN ==========

  // Obtener notas pendientes de sincronización
  Future<List<Note>> getPendingNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnIsPending = ?',
      whereArgs: [1],
      orderBy: '$columnCreatedAt ASC', // Las más antiguas primero
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromLocalJson(maps[i]);
    });
  }

  // Obtener notas no sincronizadas (offline)
  Future<List<Note>> getUnsyncedNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnIsSynced = ?',
      whereArgs: [0],
      orderBy: '$columnCreatedAt ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromLocalJson(maps[i]);
    });
  }

  // Obtener notas pendientes de eliminación
  Future<List<Note>> getPendingDeletionNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnIsPending = ? AND $columnDeletedAt IS NOT NULL',
      whereArgs: [1],
      orderBy: '$columnDeletedAt ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromLocalJson(maps[i]);
    });
  }

  // Marcar nota como sincronizada
  Future<void> markAsSynced(int serverId) async {
    final db = await database;
    await db.update(
      tableNotes,
      {
        columnIsSynced: 1,
        columnIsPending: 0,
        columnLastSyncError: null,
      },
      where: '$columnServerId = ?',
      whereArgs: [serverId],
    );
  }

  // Marcar múltiples notas como sincronizadas
  Future<void> markMultipleAsSynced(List<int> serverIds) async {
    final db = await database;
    final batch = db.batch();
    
    for (var id in serverIds) {
      batch.update(
        tableNotes,
        {
          columnIsSynced: 1,
          columnIsPending: 0,
          columnLastSyncError: null,
        },
        where: '$columnServerId = ?',
        whereArgs: [id],
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Marcar nota como pendiente (para sincronizar después)
  Future<void> markAsPending(int serverId, {String? error}) async {
    final db = await database;
    await db.update(
      tableNotes,
      {
        columnIsPending: 1,
        columnLastSyncError: error,
      },
      where: '$columnServerId = ?',
      whereArgs: [serverId],
    );
  }

  // Actualizar serverId después de sincronizar una nota offline
  Future<void> updateServerId(String localId, int newServerId) async {
    final db = await database;
    await db.update(
      tableNotes,
      {
        columnServerId: newServerId,
        columnIsSynced: 1,
        columnIsPending: 0,
        columnLastSyncError: null,
      },
      where: '$columnLocalId = ?',
      whereArgs: [localId],
    );
  }

  // ========== MÉTODOS DE LIMPIEZA Y MANTENIMIENTO ==========

  // Contar notas
  Future<int> countNotes({bool includeDeleted = false}) async {
    final db = await database;
    
    String? whereClause;
    if (!includeDeleted) {
      whereClause = '$columnDeletedAt IS NULL';
    }
    
    final result = await db.query(
      tableNotes,
      where: whereClause,
    );
    
    return result.length;
  }

  // Contar notas eliminadas
  Future<int> countDeletedNotes() async {
    final db = await database;
    final result = await db.query(
      tableNotes,
      where: '$columnDeletedAt IS NOT NULL',
    );
    
    return result.length;
  }

  // Contar notas pendientes
  Future<int> countPendingNotes() async {
    final db = await database;
    final result = await db.query(
      tableNotes,
      where: '$columnIsPending = ?',
      whereArgs: [1],
    );
    
    return result.length;
  }

  // Eliminar todas las notas (para reset)
  Future<void> clearAllNotes() async {
    final db = await database;
    await db.delete(tableNotes);
    debugPrint('🗑️ Todas las notas eliminadas de la BD local');
  }

  // Vaciar papelera (eliminar permanentemente notas eliminadas)
  Future<int> clearTrash() async {
    final db = await database;
    final count = await db.delete(
      tableNotes,
      where: '$columnDeletedAt IS NOT NULL',
    );
    
    debugPrint('🗑️ Papelera vaciada: $count notas eliminadas permanentemente');
    return count;
  }

  // Eliminar notas antiguas de la papelera (mayores a X días)
  Future<int> deleteOldTrash({int daysOld = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld)).toIso8601String();
    
    final count = await db.delete(
      tableNotes,
      where: '$columnDeletedAt IS NOT NULL AND $columnDeletedAt < ?',
      whereArgs: [cutoffDate],
    );
    
    debugPrint('🗑️ Notas antiguas eliminadas: $count');
    return count;
  }

  // Obtener estadísticas de la base de datos
  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    
    final total = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) as count FROM $tableNotes')
    ) ?? 0;
    
    final active = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) as count FROM $tableNotes WHERE $columnDeletedAt IS NULL')
    ) ?? 0;
    
    final deleted = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) as count FROM $tableNotes WHERE $columnDeletedAt IS NOT NULL')
    ) ?? 0;
    
    final pending = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) as count FROM $tableNotes WHERE $columnIsPending = ?', [1])
    ) ?? 0;
    
    final unsynced = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) as count FROM $tableNotes WHERE $columnIsSynced = ?', [0])
    ) ?? 0;
    
    final offline = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) as count FROM $tableNotes WHERE $columnServerId IS NULL OR $columnServerId = 0')
    ) ?? 0;
    
    return {
      'total': total,
      'active': active,
      'deleted': deleted,
      'pending': pending,
      'unsynced': unsynced,
      'offline': offline,
    };
  }

  // Buscar notas por texto
  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnDeletedAt IS NULL AND ($columnTitle LIKE ? OR $columnContent LIKE ? OR $columnTags LIKE ?)',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: '$columnCreatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromLocalJson(maps[i]);
    });
  }

  // Obtener notas por etiqueta
  Future<List<Note>> getNotesByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableNotes,
      where: '$columnDeletedAt IS NULL AND $columnTags LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: '$columnCreatedAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Note.fromLocalJson(maps[i]);
    });
  }

  // Cerrar la base de datos (útil para testing)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('🔒 Base de datos cerrada');
  }
}