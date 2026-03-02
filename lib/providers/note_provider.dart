import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io'; // 👈 IMPORTACIÓN NECESARIA PARA SocketException
import 'dart:async'; // 👈 IMPORTACIÓN NECESARIA PARA TimeoutException
import '../models/note.dart';
import '../services/api_service.dart';

class NoteProvider extends ChangeNotifier {
  final List<Note> _notes = [];
  final List<Note> _deletedNotes = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  // Getters
  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get deletedNotes => List.unmodifiable(_deletedNotes);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Método para limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar conectividad antes de operaciones
  Future<bool> _checkConnectivity() async {
    try {
      final result = await _apiService.testConnection();
      return result;
    } catch (e) {
      debugPrint('❌ Error verificando conectividad: $e');
      return false;
    }
  }

  // Cargar notas desde la API
  Future<void> loadNotes() async {
    _setLoading(true);
    _error = null;
    
    final hasConnection = await _checkConnectivity();
    if (!hasConnection) {
      _error = 'No hay conexión a internet. Verifica tu red.';
      _setLoading(false);
      debugPrint('⚠️ No hay conexión. Usando notas locales: ${_notes.length}');
      return;
    }
    
    try {
      final apiNotes = await _apiService.getNotes();
      
      if (_notes.isNotEmpty) {
        debugPrint('🔄 Combinando notas del servidor con estado local...');
        debugPrint('   Notas locales: ${_notes.length}, Notas del servidor: ${apiNotes.length}');
        
        final localNotesMap = {for (var note in _notes) note.id: note};
        
        final combinedNotes = apiNotes.map((apiNote) {
          final localNote = localNotesMap[apiNote.id];
          if (localNote != null) {
            debugPrint('   - Nota ${apiNote.id}: servidor(fav=${apiNote.isFavorite}, arc=${apiNote.isArchived}) → local(fav=${localNote.isFavorite}, arc=${localNote.isArchived})');
            return Note(
              id: apiNote.id,
              title: apiNote.title,
              content: apiNote.content,
              createdAt: apiNote.createdAt,
              updatedAt: apiNote.updatedAt,
              deletedAt: apiNote.deletedAt,
              isFavorite: localNote.isFavorite,
              isArchived: localNote.isArchived,
              tags: apiNote.tags.isNotEmpty ? apiNote.tags : localNote.tags,
              colorHex: apiNote.colorHex ?? localNote.colorHex,
            );
          } else {
            return apiNote;
          }
        }).toList();
        
        for (var localNote in _notes) {
          final existsInApi = apiNotes.any((apiNote) => apiNote.id == localNote.id);
          if (!existsInApi) {
            debugPrint('   ➕ Nota local no encontrada en servidor: ${localNote.id} - ${localNote.title}');
            combinedNotes.add(localNote);
          }
        }
        
        _notes.clear();
        _notes.addAll(combinedNotes);
      } else {
        _notes.clear();
        _notes.addAll(apiNotes);
      }
      
      _error = null;
      debugPrint('✅ Notas cargadas: ${_notes.length}');
      for (var note in _notes) {
        debugPrint('   - ID: ${note.id}, Título: ${note.title}, Etiquetas: ${note.tags}, Favorita: ${note.isFavorite}, Archivada: ${note.isArchived}');
      }
    } on SocketException catch (e) {
      _error = 'Error de red: No se pudo conectar al servidor';
      debugPrint('❌ SocketException en loadNotes: $e');
    } on TimeoutException catch (e) {
      _error = 'Tiempo de espera agotado. El servidor no responde.';
      debugPrint('❌ TimeoutException en loadNotes: $e');
    } catch (e) {
      _error = 'Error al cargar notas: $e';
      debugPrint('❌ Error loading notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Crear nota - CORREGIDO PARA ENVIAR TAGS
  Future<bool> createNote(Note note) async {
    _setLoading(true);
    _error = null;
    
    final hasConnection = await _checkConnectivity();
    if (!hasConnection) {
      _error = 'No hay conexión a internet. Verifica tu red.';
      _setLoading(false);
      return false;
    }
    
    try {
      debugPrint('📝 Creando nota con título: ${note.title}');
      debugPrint('   Etiquetas originales: ${note.tags}');
      
      // Limpiar tags vacíos y espacios
      final cleanTags = note.tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      
      debugPrint('   Etiquetas limpias: $cleanTags');
      
      final newNote = await _apiService.createNote(
        note.title, 
        note.content,
        tags: cleanTags.isNotEmpty ? cleanTags : null,
        isFavorite: note.isFavorite,
      );
      
      _notes.insert(0, newNote);
      _error = null;
      debugPrint('✅ Nota creada: ${newNote.id} - ${newNote.title}');
      debugPrint('   Etiquetas recibidas: ${newNote.tags}');
      debugPrint('   Total notas ahora: ${_notes.length}');
      notifyListeners();
      return true;
      
    } on SocketException catch (e) {
      _error = 'Error de red: No se pudo conectar al servidor';
      debugPrint('❌ SocketException en createNote: $e');
      return false;
      
    } on TimeoutException catch (e) {
      _error = 'Tiempo de espera agotado. El servidor no responde.';
      debugPrint('❌ TimeoutException en createNote: $e');
      return false;
      
    } catch (e) {
      _error = 'Error al crear nota: ${e.toString()}';
      debugPrint('❌ Error al crear nota: $e');
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar nota
  Future<bool> updateNote(Note note) async {
    _setLoading(true);
    _error = null;
    
    final hasConnection = await _checkConnectivity();
    if (!hasConnection) {
      _error = 'No hay conexión a internet. Verifica tu red.';
      _setLoading(false);
      return false;
    }
    
    try {
      debugPrint('📝 Actualizando nota ${note.id} - isFavorite: ${note.isFavorite}, isArchived: ${note.isArchived}');
      debugPrint('   Etiquetas originales: ${note.tags}');
      
      // Limpiar tags vacíos y espacios
      final cleanTags = note.tags
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      
      debugPrint('   Etiquetas limpias: $cleanTags');
      
      final desiredFavoriteState = note.isFavorite;
      final desiredArchivedState = note.isArchived;
      
      final updatedNote = await _apiService.updateNote(
        note.id,
        note.title, 
        note.content,
        isFavorite: desiredFavoriteState,
        tags: cleanTags.isNotEmpty ? cleanTags : null,
      );
      
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        if (updatedNote.isFavorite != desiredFavoriteState || 
            updatedNote.isArchived != desiredArchivedState) {
          
          debugPrint('⚠️ El servidor ignoró algunos estados. Aplicando workaround...');
          debugPrint('   Servidor: fav=${updatedNote.isFavorite}, arc=${updatedNote.isArchived}');
          debugPrint('   Esperado: fav=$desiredFavoriteState, arc=$desiredArchivedState');
          
          final correctedNote = Note(
            id: updatedNote.id,
            title: updatedNote.title,
            content: updatedNote.content,
            createdAt: updatedNote.createdAt,
            updatedAt: updatedNote.updatedAt,
            deletedAt: updatedNote.deletedAt,
            isFavorite: desiredFavoriteState,
            isArchived: desiredArchivedState,
            tags: cleanTags,
            colorHex: updatedNote.colorHex ?? note.colorHex,
          );
          
          _notes[index] = correctedNote;
          debugPrint('✅ Nota actualizada con workaround - Tags: ${correctedNote.tags}');
        } else {
          _notes[index] = updatedNote;
          debugPrint('✅ Nota actualizada correctamente - Tags: ${updatedNote.tags}');
        }
        
        notifyListeners();
      } else {
        debugPrint('⚠️ Nota no encontrada en la lista local: ${note.id}');
      }
      
      _error = null;
      return true;
      
    } on SocketException catch (e) {
      _error = 'Error de red: No se pudo conectar al servidor';
      debugPrint('❌ SocketException en updateNote: $e');
      return false;
      
    } on TimeoutException catch (e) {
      _error = 'Tiempo de espera agotado. El servidor no responde.';
      debugPrint('❌ TimeoutException en updateNote: $e');
      return false;
      
    } catch (e) {
      _error = 'Error al actualizar nota: $e';
      debugPrint('❌ Error al actualizar nota: $e');
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  // ========== MÉTODOS PARA FAVORITOS ==========
  
  Future<bool> toggleFavorite(int id) async {
    try {
      final index = _notes.indexWhere((note) => note.id == id);
      if (index == -1) return false;
      
      final note = _notes[index];
      final updatedNote = note.copyWithFavorite(!note.isFavorite);
      
      return await updateNote(updatedNote);
    } catch (e) {
      debugPrint('❌ Error toggling favorite: $e');
      return false;
    }
  }

  // ========== MÉTODOS PARA ARCHIVADOS ==========
  
  Future<bool> toggleArchive(int id) async {
    try {
      final index = _notes.indexWhere((note) => note.id == id);
      if (index == -1) return false;
      
      final note = _notes[index];
      final updatedNote = note.copyWithArchived(!note.isArchived);
      
      return await updateNote(updatedNote);
    } catch (e) {
      debugPrint('❌ Error toggling archive: $e');
      return false;
    }
  }

  // ========== MÉTODOS PARA PAPELERA ==========

  Future<bool> deleteNote(int id) async {
    _setLoading(true);
    
    final hasConnection = await _checkConnectivity();
    if (!hasConnection) {
      _error = 'No hay conexión a internet. Verifica tu red.';
      _setLoading(false);
      return false;
    }
    
    try {
      final noteIndex = _notes.indexWhere((note) => note.id == id);
      if (noteIndex >= 0) {
        final note = _notes.removeAt(noteIndex);
        
        final deletedNote = note.copyWith(
          deletedAt: DateTime.now().toIso8601String(),
        );
        
        _deletedNotes.add(deletedNote);
        notifyListeners();
        
        await _apiService.deleteNote(id);
        
        debugPrint('✅ Nota movida a papelera: $id - ${note.title}');
        debugPrint('   Notas activas: ${_notes.length}');
        debugPrint('   Notas en papelera: ${_deletedNotes.length}');
        return true;
      }
      return false;
      
    } on SocketException catch (e) {
      _error = 'Error de red: No se pudo conectar al servidor';
      debugPrint('❌ SocketException en deleteNote: $e');
      return false;
      
    } on TimeoutException catch (e) {
      _error = 'Tiempo de espera agotado. El servidor no responde.';
      debugPrint('❌ TimeoutException en deleteNote: $e');
      return false;
      
    } catch (e) {
      _error = 'Error al eliminar nota: $e';
      debugPrint('❌ Error al eliminar nota: $e');
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> restoreNote(int id) async {
    try {
      final noteIndex = _deletedNotes.indexWhere((note) => note.id == id);
      if (noteIndex >= 0) {
        final note = _deletedNotes.removeAt(noteIndex);
        
        final restoredNote = note.copyWith(
          deletedAt: null,
        );
        
        _notes.add(restoredNote);
        notifyListeners();
        
        debugPrint('✅ Nota restaurada: $id - ${note.title}');
        debugPrint('   Notas activas: ${_notes.length}');
        debugPrint('   Notas en papelera: ${_deletedNotes.length}');
        
        await _apiService.createNote(restoredNote.title, restoredNote.content);
        
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al restaurar nota: $e';
      debugPrint('❌ Error al restaurar nota: $e');
      return false;
    }
  }

  Future<bool> deletePermanently(int id) async {
    try {
      final noteIndex = _deletedNotes.indexWhere((note) => note.id == id);
      if (noteIndex >= 0) {
        _deletedNotes.removeAt(noteIndex);
        notifyListeners();
        
        debugPrint('✅ Nota eliminada permanentemente: $id');
        debugPrint('   Notas en papelera: ${_deletedNotes.length}');
        
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al eliminar permanentemente: $e';
      debugPrint('❌ Error al eliminar permanentemente: $e');
      return false;
    }
  }

  Future<void> emptyTrash() async {
    try {
      _deletedNotes.clear();
      notifyListeners();
      
      debugPrint('✅ Papelera vaciada');
      debugPrint('   Notas activas: ${_notes.length}');
      debugPrint('   Notas en papelera: ${_deletedNotes.length}');
    } catch (e) {
      _error = 'Error al vaciar papelera: $e';
      debugPrint('❌ Error al vaciar papelera: $e');
    }
  }

  Future<void> loadDeletedNotes() async {
    debugPrint('📋 Notas en papelera: ${_deletedNotes.length}');
    for (var note in _deletedNotes) {
      debugPrint('   - ID: ${note.id}, Título: ${note.title}, Eliminada: ${note.deletedAt}');
    }
  }

  // ========== MÉTODOS PARA BACKUP/RESTORE ==========

  List<Note> getNotesForBackup() {
    debugPrint('📦 getNotesForBackup() llamado: ${_notes.length} notas');
    
    if (_notes.isEmpty) {
      debugPrint('   ⚠️ No hay notas en el provider');
    } else {
      for (var note in _notes) {
        debugPrint('   - ID: ${note.id}, Título: ${note.title}, Etiquetas: ${note.tags}, Favorita: ${note.isFavorite}, Archivada: ${note.isArchived}');
      }
    }
    
    return List.from(_notes);
  }

  Future<void> replaceAllNotes(List<Note> newNotes) async {
    _setLoading(true);
    debugPrint('🔄 replaceAllNotes() llamado');
    debugPrint('   Nuevas notas a restaurar: ${newNotes.length}');
    
    try {
      for (var note in _notes) {
        await _apiService.deleteNote(note.id);
      }

      _notes.clear();
      
      for (var note in newNotes) {
        final cleanTags = note.tags
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
            
        final newNote = await _apiService.createNote(
          note.title, 
          note.content,
          tags: cleanTags.isNotEmpty ? cleanTags : null,
        );
        _notes.add(newNote);
        debugPrint('   - Creada: ${newNote.title} (Tags: ${newNote.tags})');
      }
      
      _error = null;
      debugPrint('✅ Restore completado: ${_notes.length} notas');
      notifyListeners();
    } catch (e) {
      _error = 'Error al restaurar notas: $e';
      debugPrint('❌ Error en restore: $e');
    } finally {
      _setLoading(false);
    }
  }

  void restoreNotesLocally(List<Note> newNotes) {
    debugPrint('🔄 restoreNotesLocally() llamado');
    debugPrint('   Reemplazando ${_notes.length} notas por ${newNotes.length} notas');
    
    _notes.clear();
    _notes.addAll(newNotes);
    notifyListeners();
    
    debugPrint('✅ Restore local completado');
    for (var note in _notes) {
      debugPrint('   - ${note.title} (Tags: ${note.tags})');
    }
  }

  Future<void> clearAllNotes() async {
    _setLoading(true);
    debugPrint('🗑️ clearAllNotes() llamado');
    debugPrint('   Eliminando ${_notes.length} notas...');
    
    try {
      for (var note in _notes) {
        await _apiService.deleteNote(note.id);
      }
      _notes.clear();
      _error = null;
      debugPrint('✅ Todas las notas eliminadas');
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
}