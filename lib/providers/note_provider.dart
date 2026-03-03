import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import '../models/note.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';
import '../utils/connectivity_util.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _deletedNotes = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String? _error;
  final ApiService _apiService = ApiService();
  final LocalDBService _localDB = LocalDBService();
  
  // Flag para evitar sincronizaciones múltiples simultáneas
  bool _isSyncing = false;

  // Getters
  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get deletedNotes => List.unmodifiable(_deletedNotes);
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get error => _error;

  // ========== INICIALIZACIÓN ==========

  Future<void> initialize() async {
    debugPrint('🚀 Inicializando NoteProvider...');
    
    await _checkConnectivity();
    debugPrint('📡 Estado de conectividad inicial: ${_isOffline ? "OFFLINE" : "ONLINE"}');
    
    _setupConnectivityListener();
    await loadLocalNotes();
    
    if (!_isOffline) {
      debugPrint('🌐 Hay conexión inicial - sincronizando con servidor...');
      await _syncWithServer();
    }
  }

  void _setupConnectivityListener() {
    ConnectivityUtil.instance.addListener(_onConnectivityChanged);
    debugPrint('👂 Listener de conectividad configurado en NoteProvider');
  }

  void _onConnectivityChanged(bool isConnected) {
    final wasOffline = _isOffline;
    _isOffline = !isConnected;
    
    debugPrint('📡 NoteProvider - Cambio de conectividad: ${_isOffline ? "OFFLINE" : "ONLINE"} (wasOffline: $wasOffline)');
    
    if (wasOffline != _isOffline) {
      notifyListeners();
      
      if (wasOffline && !_isOffline) {
        debugPrint('🔄 CONEXIÓN RECUPERADA - Iniciando sincronización inmediata...');
        _syncPendingNotes();
      }
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final isConnected = await ConnectivityUtil.instance.checkConnectivity();
      _isOffline = !isConnected;
      debugPrint('🔍 Verificación de conectividad: ${_isOffline ? "OFFLINE" : "ONLINE"}');
    } catch (e) {
      debugPrint('❌ Error verificando conectividad: $e');
      _isOffline = true;
    }
  }

  // ========== CARGA DE NOTAS ==========

  Future<void> loadLocalNotes() async {
    _setLoading(true);
    _error = null;
    
    try {
      final localNotes = await _localDB.getAllNotes();
      
      _notes = localNotes.where((note) => !note.isDeleted).toList();
      _deletedNotes = localNotes.where((note) => note.isDeleted).toList();
      
      debugPrint('✅ Notas locales cargadas: ${_notes.length} activas, ${_deletedNotes.length} eliminadas');
      notifyListeners();
      
    } catch (e) {
      _error = 'Error cargando notas locales: $e';
      debugPrint('❌ Error cargando notas locales: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNotes() async {
    debugPrint('📚 Cargando notas... (offline: $_isOffline)');
    
    if (_isOffline) {
      debugPrint('⚠️ Modo offline: cargando solo desde BD local');
      await loadLocalNotes();
      return;
    }
    
    _setLoading(true);
    _error = null;
    
    try {
      final apiNotes = await _apiService.getNotes();
      
      for (var note in apiNotes) {
        final existingLocal = await _localDB.getNoteByServerId(note.id);
        if (existingLocal == null) {
          await _localDB.insertNote(note);
        } else {
          await _localDB.updateNote(note);
        }
      }
      
      await loadLocalNotes();
      
    } catch (e) {
      debugPrint('❌ Error loading notes: $e');
      _isOffline = true;
      notifyListeners();
      await loadLocalNotes();
    } finally {
      _setLoading(false);
    }
  }

  // ========== SINCRONIZACIÓN ==========

  Future<void> _syncWithServer() async {
    if (_isOffline || _isSyncing) return;
    
    _isSyncing = true;
    debugPrint('🔄 Iniciando sincronización con servidor...');
    
    try {
      final serverNotes = await _apiService.getNotes();
      
      // Actualizar notas existentes y agregar nuevas
      for (var note in serverNotes) {
        final localNote = await _localDB.getNoteByServerId(note.id);
        if (localNote == null) {
          await _localDB.insertNote(note);
        } else if (localNote.updatedAt != note.updatedAt) {
          await _localDB.updateNote(note);
        }
      }
      
      await _processPendingNotes();
      await loadLocalNotes();
      debugPrint('✅ Sincronización completada');
      
    } catch (e) {
      debugPrint('❌ Error en sincronización: $e');
      await _checkConnectivity();
    } finally {
      _isSyncing = false;
    }
  }

  // ========== MÉTODO _processPendingNotes CORREGIDO ==========
  Future<void> _processPendingNotes() async {
    try {
      final pendingNotes = await _localDB.getPendingNotes();
      if (pendingNotes.isEmpty) return;
      
      debugPrint('📝 Procesando ${pendingNotes.length} notas pendientes...');
      
      for (var note in pendingNotes) {
        debugPrint('   Procesando: ID=${note.id}, título="${note.title}", isDeleted=${note.isDeleted}');
        
        if (note.isDeleted) {
          // 🔴 Nota marcada para ELIMINAR
          debugPrint('   🔴 Nota para ELIMINAR');
          if (note.id > 0) {
            try {
              await _apiService.deleteNote(note.id);
              await _localDB.deleteNote(note.id);
              debugPrint('   ✅ Nota ${note.id} eliminada del servidor');
            } catch (e) {
              debugPrint('   ⚠️ Error eliminando nota pendiente: $e');
            }
          } else {
            // Nota offline sin ID en servidor, solo eliminar localmente
            if (note.localId != null) {
              try {
                await _localDB.deleteNoteByLocalId(note.localId!);
                debugPrint('   ✅ Nota offline eliminada localmente');
              } catch (e) {
                debugPrint('   ⚠️ Error eliminando nota offline: $e');
              }
            }
          }
        } else if (note.id > 0) {
          // 🟡 Nota existente para ACTUALIZAR
          debugPrint('   🟡 Nota para ACTUALIZAR (ID: ${note.id})');
          try {
            final updated = await _apiService.updateNote(
              note.id,
              note.title,
              note.content,
              isFavorite: note.isFavorite,
              tags: note.tags,
            );
            await _localDB.markAsSynced(updated.id);
            debugPrint('   ✅ Nota ${note.id} actualizada en servidor');
          } catch (e) {
            if (e.toString().contains('404')) {
              debugPrint('   ⚠️ Nota ${note.id} no existe en servidor, CREANDO...');
              try {
                final created = await _apiService.createNote(
                  note.title,
                  note.content,
                  tags: note.tags,
                  isFavorite: note.isFavorite,
                );
                
                if (note.localId != null) {
                  await _localDB.updateServerId(note.localId!, created.id);
                } else {
                  await _localDB.markAsSynced(created.id);
                }
                debugPrint('   ✅ Nota creada con ID servidor: ${created.id}');
              } catch (createError) {
                debugPrint('   ⚠️ Error creando nota: $createError');
              }
            } else {
              debugPrint('   ⚠️ Error actualizando nota pendiente: $e');
            }
          }
        } else {
          // 🟢 Nota nueva para CREAR (notas restauradas con ID=0)
          debugPrint('   🟢 Nota para CREAR en servidor');
          try {
            final created = await _apiService.createNote(
              note.title,
              note.content,
              tags: note.tags,
              isFavorite: note.isFavorite,
            );
            
            // Actualizar en BD local con el nuevo ID
            if (note.localId != null) {
              await _localDB.updateServerId(note.localId!, created.id);
              
              // Actualizar en memoria
              final index = _notes.indexWhere((n) => n.localId == note.localId);
              if (index != -1) {
                final updatedNote = _notes[index].copyWith(
                  id: created.id,
                  isSynced: true,
                  isPending: false,
                );
                _notes[index] = updatedNote;
                debugPrint('   ✅ Nota actualizada en memoria con ID: ${created.id}');
              }
            }
            debugPrint('   ✅ Nota creada en servidor con ID: ${created.id}');
          } catch (e) {
            debugPrint('   ⚠️ Error creando nota pendiente: $e');
          }
        }
      }
      
      // Recargar todas las notas para asegurar consistencia
      await loadLocalNotes();
      
    } catch (e) {
      debugPrint('❌ Error procesando notas pendientes: $e');
    }
  }

  Future<void> _syncPendingNotes() async {
    if (_isOffline || _isSyncing) return;
    
    _isSyncing = true;
    debugPrint('🔄 INICIANDO SINCRONIZACIÓN DE NOTAS PENDIENTES...');
    
    try {
      await _processPendingNotes();
      await loadLocalNotes();
      await _checkConnectivity();
      debugPrint('✅ SINCRONIZACIÓN COMPLETADA. Estado offline: $_isOffline');
    } catch (e) {
      debugPrint('❌ Error sincronizando pendientes: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // ========== OPERACIONES CRUD ==========

  Future<bool> createNote(Note note) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _checkConnectivity();
      
      if (_isOffline) {
        debugPrint('📱 Modo offline: guardando nota localmente');
        final offlineNote = Note.createOffline(
          title: note.title,
          content: note.content,
          isFavorite: note.isFavorite,
          isArchived: note.isArchived,
          tags: note.tags,
          colorHex: note.colorHex,
        );
        
        final localId = await _localDB.insertNote(offlineNote);
        await loadLocalNotes();
        
        debugPrint('✅ Nota guardada offline (ID local: $localId)');
        return true;
        
      } else {
        debugPrint('🌐 Modo online: creando nota en servidor');
        final cleanTags = note.tags
            .map((tag) => tag.trim().toLowerCase())
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList();
        
        final newNote = await _apiService.createNote(
          note.title,
          note.content,
          tags: cleanTags.isNotEmpty ? cleanTags : null,
          isFavorite: note.isFavorite,
        );
        
        await _localDB.insertNote(newNote);
        await loadLocalNotes();
        
        debugPrint('✅ Nota creada y sincronizada con ID: ${newNote.id}');
        return true;
      }
      
    } catch (e) {
      _error = 'Error al crear nota: ${e.toString()}';
      debugPrint('❌ Error en createNote: $e');
      
      final isConnectionError = e is SocketException || e is TimeoutException;
      
      if (isConnectionError && !_isOffline) {
        debugPrint('⚠️ Error de conexión detectado - cambiando a modo offline');
        _isOffline = true;
        notifyListeners();
        return createNote(note);
      }
      
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateNote(Note note) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _checkConnectivity();
      
      if (_isOffline || note.isOffline) {
        debugPrint('📱 Modo offline: actualizando nota localmente (ID: ${note.id})');
        final updatedOfflineNote = note.copyWith(
          isPending: true,
          isSynced: false,
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        await _localDB.updateNote(updatedOfflineNote);
        await loadLocalNotes();
        
        debugPrint('✅ Nota actualizada offline');
        return true;
        
      } else {
        debugPrint('🌐 Modo online: actualizando nota en servidor (ID: ${note.id})');
        final cleanTags = note.tags
            .map((tag) => tag.trim().toLowerCase())
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList();
        
        final updatedNote = await _apiService.updateNote(
          note.id,
          note.title,
          note.content,
          isFavorite: note.isFavorite,
          tags: cleanTags.isNotEmpty ? cleanTags : null,
        );
        
        await _localDB.updateNote(updatedNote);
        await loadLocalNotes();
        
        debugPrint('✅ Nota actualizada y sincronizada');
        return true;
      }
      
    } catch (e) {
      _error = 'Error al actualizar nota: $e';
      debugPrint('❌ Error en updateNote: $e');
      
      final isConnectionError = e is SocketException || e is TimeoutException;
      
      if (isConnectionError && !_isOffline) {
        debugPrint('⚠️ Error de conexión detectado - cambiando a modo offline');
        _isOffline = true;
        notifyListeners();
        return updateNote(note);
      }
      
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteNote(int id) async {
    _setLoading(true);
    
    try {
      await _checkConnectivity();
      
      // Buscar la nota
      Note? note;
      try {
        note = _notes.firstWhere((n) => n.id == id);
      } catch (e) {
        try {
          note = _deletedNotes.firstWhere((n) => n.id == id);
        } catch (e) {
          debugPrint('❌ Nota no encontrada para eliminar: $id');
          return false;
        }
      }
      
      debugPrint('🗑️ Eliminando nota: ${note.title} (ID: ${note.id}, offline: ${note.isOffline})');
      
      // Crear la nota marcada como eliminada usando markAsDeleted()
      final deletedNote = note.markAsDeleted().copyWith(
        isPending: true,
        isSynced: false,
      );
      
      // SIEMPRE mover a papelera primero (incluso online)
      debugPrint('📦 Moviendo nota a papelera...');
      await _localDB.updateNote(deletedNote);
      
      // Actualizar listas en memoria
      _notes.removeWhere((n) => n.id == id);
      _deletedNotes.insert(0, deletedNote);
      
      // Si hay conexión, intentar eliminar del servidor
      if (!_isOffline && !note.isOffline) {
        try {
          debugPrint('🌐 Eliminando del servidor...');
          await _apiService.deleteNote(id);
          debugPrint('✅ Nota eliminada del servidor');
          
          // Marcar como sincronizada en la papelera
          final syncedDeletedNote = deletedNote.copyWith(
            isPending: false,
            isSynced: true,
          );
          await _localDB.updateNote(syncedDeletedNote);
          
          // Actualizar la nota en la lista de papelera
          final index = _deletedNotes.indexWhere((n) => n.id == id);
          if (index != -1) {
            _deletedNotes[index] = syncedDeletedNote;
          }
          
        } catch (e) {
          debugPrint('⚠️ Error eliminando del servidor: $e');
          // La nota ya está en papelera con isPending=true
        }
      } else {
        debugPrint('📱 Modo offline: nota guardada en papelera para sincronizar después');
      }
      
      notifyListeners();
      debugPrint('✅ Nota movida a papelera. Ahora hay ${_deletedNotes.length} notas en papelera');
      return true;
      
    } catch (e) {
      _error = 'Error al eliminar nota: $e';
      debugPrint('❌ Error en deleteNote: $e');
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  // ========== MÉTODO RESTORE NOTE ULTRA-CORREGIDO ==========
  Future<bool> restoreNote(int id) async {
    try {
      final noteIndex = _deletedNotes.indexWhere((note) => note.id == id);
      if (noteIndex < 0) {
        debugPrint('❌ Nota no encontrada en papelera: $id');
        return false;
      }
      
      final note = _deletedNotes[noteIndex];
      debugPrint('🔄 Restaurando nota: ${note.title} (ID: ${note.id})');
      debugPrint('   📊 Estado actual - isDeleted: ${note.isDeleted}, deletedAt: ${note.deletedAt}');
      
      // 👇 CREAR NOTA NUEVA CON VALORES EXPLÍCITOS
      final restoredNote = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
        isFavorite: note.isFavorite,
        isArchived: note.isArchived,
        tags: note.tags,
        colorHex: note.colorHex,
        localId: note.localId,
        // 👇 VALORES FORZADOS
        isSynced: false,
        isPending: true,
        deletedAt: null, // 👈 EXPLÍCITAMENTE null
      );
      
      debugPrint('   📝 Nota restaurada creada - deletedAt: ${restoredNote.deletedAt}, isDeleted: ${restoredNote.isDeleted}');
      
      // 👇 GUARDAR EN BD LOCAL - ESTO ES CRÍTICO
      await _localDB.updateNote(restoredNote);
      
      // 👇 VERIFICAR QUE SE GUARDÓ CORRECTAMENTE
      if (restoredNote.localId != null) {
        final verificationNote = await _localDB.getNoteByLocalId(restoredNote.localId!);
        if (verificationNote != null) {
          debugPrint('   ✅ Verificación BD - isDeleted: ${verificationNote.isDeleted}, deletedAt: ${verificationNote.deletedAt}');
          if (verificationNote.isDeleted) {
            debugPrint('   ⚠️ ¡ERROR! La nota aún está marcada como eliminada en BD. Forzando corrección...');
            // Forzar guardado con SQL directo
            final db = await _localDB.database;
            await db.update(
              'notes',
              {
                'deleted_at': null,
                'is_pending': 1,
                'is_synced': 0,
              },
              where: 'local_id = ?',
              whereArgs: [restoredNote.localId],
            );
            debugPrint('   ✅ Corrección aplicada en BD');
          }
        }
      }
      
      // Actualizar listas en memoria
      _deletedNotes.removeAt(noteIndex);
      _notes.insert(0, restoredNote);
      
      notifyListeners();
      debugPrint('✅ Nota restaurada exitosamente');
      return true;
      
    } catch (e) {
      _error = 'Error al restaurar nota: $e';
      debugPrint('❌ Error en restoreNote: $e');
      return false;
    }
  }

  // ========== MÉTODOS DE PAPELERA ==========

  Future<void> loadDeletedNotes() async {
    try {
      final localDeleted = await _localDB.getDeletedNotes();
      _deletedNotes = localDeleted;
      notifyListeners();
      debugPrint('📋 Notas en papelera cargadas: ${_deletedNotes.length}');
    } catch (e) {
      _error = 'Error cargando papelera: $e';
      debugPrint('❌ Error en loadDeletedNotes: $e');
    }
  }

  Future<bool> deletePermanently(int id) async {
    try {
      final noteIndex = _deletedNotes.indexWhere((note) => note.id == id);
      if (noteIndex < 0) {
        debugPrint('❌ Nota no encontrada en papelera: $id');
        return false;
      }
      
      final note = _deletedNotes[noteIndex];
      debugPrint('🗑️ Eliminando permanentemente: ${note.title} (ID: ${note.id})');
      
      await _checkConnectivity();
      
      if (!_isOffline && note.id > 0) {
        try {
          await _apiService.deleteNote(note.id);
          debugPrint('✅ Nota eliminada permanentemente del servidor');
        } catch (e) {
          debugPrint('⚠️ Error eliminando del servidor: $e');
        }
      }
      
      await _localDB.deleteNote(note.id > 0 ? note.id : 0);
      _deletedNotes.removeAt(noteIndex);
      
      notifyListeners();
      debugPrint('✅ Nota eliminada permanentemente');
      return true;
      
    } catch (e) {
      _error = 'Error al eliminar permanentemente: $e';
      debugPrint('❌ Error en deletePermanently: $e');
      return false;
    }
  }

  Future<void> emptyTrash() async {
    debugPrint('🗑️ Vaciando papelera (${_deletedNotes.length} notas)');
    
    try {
      await _checkConnectivity();
      
      for (var note in _deletedNotes) {
        if (!_isOffline && note.id > 0) {
          try {
            await _apiService.deleteNote(note.id);
            debugPrint('   ✅ Nota ${note.id} eliminada del servidor');
          } catch (e) {
            debugPrint('   ⚠️ Error eliminando del servidor: $e');
          }
        }
      }
      
      await _localDB.clearTrash();
      _deletedNotes.clear();
      
      notifyListeners();
      debugPrint('✅ Papelera vaciada');
      
    } catch (e) {
      _error = 'Error al vaciar papelera: $e';
      debugPrint('❌ Error en emptyTrash: $e');
    }
  }

  // ========== FAVORITOS Y ARCHIVADOS ==========
  
  Future<bool> toggleFavorite(int id) async {
    try {
      final index = _notes.indexWhere((note) => note.id == id);
      if (index == -1) return false;
      
      final note = _notes[index];
      final updatedNote = note.copyWithFavorite(!note.isFavorite).copyWith(
        isPending: true,
        isSynced: false,
      );
      
      await _localDB.updateNote(updatedNote);
      _notes[index] = updatedNote;
      
      await _checkConnectivity();
      
      if (!_isOffline) {
        try {
          await _apiService.updateNote(
            id,
            updatedNote.title,
            updatedNote.content,
            isFavorite: updatedNote.isFavorite,
          );
        } catch (e) {
          debugPrint('⚠️ Error actualizando favorito en servidor: $e');
        }
      }
      
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ Error toggling favorite: $e');
      return false;
    }
  }

  Future<bool> toggleArchive(int id) async {
    try {
      final index = _notes.indexWhere((note) => note.id == id);
      if (index == -1) return false;
      
      final note = _notes[index];
      final updatedNote = note.copyWithArchived(!note.isArchived).copyWith(
        isPending: true,
        isSynced: false,
      );
      
      await _localDB.updateNote(updatedNote);
      _notes[index] = updatedNote;
      
      await _checkConnectivity();
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ Error toggling archive: $e');
      return false;
    }
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  List<Note> getNotesForBackup() {
    return List.from(_notes);
  }

  Future<void> replaceAllNotes(List<Note> newNotes) async {
    _setLoading(true);
    
    try {
      await _localDB.clearAllNotes();
      
      for (var note in newNotes) {
        await _localDB.insertNote(note);
      }
      
      await loadLocalNotes();
      
      await _checkConnectivity();
      
      if (!_isOffline) {
        await _syncWithServer();
      }
      
    } catch (e) {
      _error = 'Error al restaurar notas: $e';
      debugPrint('❌ Error en restore: $e');
    } finally {
      _setLoading(false);
    }
  }

  void restoreNotesLocally(List<Note> newNotes) {
    _notes = newNotes;
    notifyListeners();
  }

  Future<void> clearAllNotes() async {
    _setLoading(true);
    
    try {
      await _checkConnectivity();
      
      if (!_isOffline) {
        for (var note in _notes) {
          try {
            await _apiService.deleteNote(note.id);
          } catch (e) {
            debugPrint('⚠️ Error eliminando del servidor: $e');
          }
        }
      }
      
      await _localDB.clearAllNotes();
      _notes = [];
      _deletedNotes = [];
      _error = null;
      notifyListeners();
      
    } catch (e) {
      _error = 'Error al limpiar notas: $e';
      debugPrint('❌ Error al limpiar: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> forceConnectivityCheck() async {
    debugPrint('🔄 Forzando verificación de conectividad...');
    final isConnected = await ConnectivityUtil.instance.checkConnectivity();
    _isOffline = !isConnected;
    debugPrint('✅ Estado actualizado: ${_isOffline ? "OFFLINE" : "ONLINE"}');
    
    if (!_isOffline) {
      await _syncPendingNotes();
    }
    
    notifyListeners();
  }

  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Note? getDeletedNoteById(int id) {
    try {
      return _deletedNotes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    ConnectivityUtil.instance.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}