import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _deletedNotes = []; // Nueva lista para notas eliminadas
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  // Getters
  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get deletedNotes => List.unmodifiable(_deletedNotes); // Getter para notas eliminadas
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar notas desde la API
  Future<void> loadNotes() async {
    _setLoading(true);
    try {
      _notes = await _apiService.getNotes();
      _error = null;
      debugPrint('✅ Notas cargadas: ${_notes.length}');
      // Mostrar detalles de las notas para debug
      for (var note in _notes) {
        debugPrint('   - ID: ${note.id}, Título: ${note.title}');
      }
    } catch (e) {
      _error = 'Error al cargar notas: $e';
      debugPrint('❌ Error loading notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Crear nota
  Future<bool> createNote(Note note) async {
    _setLoading(true);
    try {
      final newNote = await _apiService.createNote(note.title, note.content);
      _notes.add(newNote);
      _error = null;
      debugPrint('✅ Nota creada: ${newNote.id} - ${newNote.title}');
      debugPrint('   Total notas ahora: ${_notes.length}');
      return true;
    } catch (e) {
      _error = 'Error al crear nota: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar nota
  Future<bool> updateNote(Note note) async {
    _setLoading(true);
    try {
      final updatedNote = await _apiService.updateNote(
        note.id,
        note.title, 
        note.content
      );
      
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updatedNote;
        debugPrint('✅ Nota actualizada: ${note.id}');
      }
      _error = null;
      return true;
    } catch (e) {
      _error = 'Error al actualizar nota: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========== MÉTODOS PARA PAPELERA ==========

  // Eliminar nota (mover a papelera)
  Future<bool> deleteNote(int id) async {
    _setLoading(true);
    try {
      // Buscar la nota en la lista principal
      final noteIndex = _notes.indexWhere((note) => note.id == id);
      if (noteIndex >= 0) {
        final note = _notes.removeAt(noteIndex);
        
        // Marcar como eliminada y agregar fecha de eliminación
        final deletedNote = note.copyWith(
          deletedAt: DateTime.now().toIso8601String(),
        );
        
        _deletedNotes.add(deletedNote);
        notifyListeners();
        
        // También eliminar de la API
        await _apiService.deleteNote(id);
        
        debugPrint('✅ Nota movida a papelera: $id - ${note.title}');
        debugPrint('   Notas activas: ${_notes.length}');
        debugPrint('   Notas en papelera: ${_deletedNotes.length}');
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al eliminar nota: $e';
      debugPrint('❌ Error al eliminar nota: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Restaurar nota desde la papelera
  Future<bool> restoreNote(int id) async {
    try {
      final noteIndex = _deletedNotes.indexWhere((note) => note.id == id);
      if (noteIndex >= 0) {
        final note = _deletedNotes.removeAt(noteIndex);
        
        // Limpiar la fecha de eliminación
        final restoredNote = note.copyWith(
          deletedAt: null,
        );
        
        _notes.add(restoredNote);
        notifyListeners();
        
        debugPrint('✅ Nota restaurada: $id - ${note.title}');
        debugPrint('   Notas activas: ${_notes.length}');
        debugPrint('   Notas en papelera: ${_deletedNotes.length}');
        
        // Aquí podrías llamar a la API para restaurar si tienes ese endpoint
        // Por ahora, como la nota ya fue eliminada de la API, necesitarías crearla de nuevo
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

  // Eliminar permanentemente de la papelera
  Future<bool> deletePermanently(int id) async {
    try {
      final noteIndex = _deletedNotes.indexWhere((note) => note.id == id);
      if (noteIndex >= 0) {
        _deletedNotes.removeAt(noteIndex);
        notifyListeners();
        
        debugPrint('✅ Nota eliminada permanentemente: $id');
        debugPrint('   Notas en papelera: ${_deletedNotes.length}');
        
        // Aquí no necesitas llamar a la API porque la nota ya fue eliminada
        // cuando se movió a la papelera
        
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al eliminar permanentemente: $e';
      debugPrint('❌ Error al eliminar permanentemente: $e');
      return false;
    }
  }

  // Vaciar toda la papelera
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

  // Cargar notas eliminadas (puedes implementar esto si tienes un endpoint)
  Future<void> loadDeletedNotes() async {
    // Por ahora, mantenemos las que ya tenemos en memoria
    // Si tuvieras un endpoint para obtener notas eliminadas, lo llamarías aquí
    debugPrint('📋 Notas en papelera: ${_deletedNotes.length}');
    for (var note in _deletedNotes) {
      debugPrint('   - ID: ${note.id}, Título: ${note.title}, Eliminada: ${note.deletedAt}');
    }
  }

  // ========== MÉTODOS PARA BACKUP/RESTORE ==========

  // Obtener todas las notas para backup - VERSIÓN CON DEBUG
  List<Note> getNotesForBackup() {
    debugPrint('📦 getNotesForBackup() llamado');
    debugPrint('   Total notas en provider: ${_notes.length}');
    
    if (_notes.isEmpty) {
      debugPrint('   ⚠️ ADVERTENCIA: No hay notas en el provider');
      debugPrint('   ¿Se llamó a loadNotes() antes?');
    } else {
      debugPrint('   Notas disponibles:');
      for (var note in _notes) {
        debugPrint('   - ID: ${note.id}, Título: ${note.title}');
      }
    }
    
    return List.from(_notes);
  }

  // Reemplazar todas las notas (restore con API)
  Future<void> replaceAllNotes(List<Note> newNotes) async {
    _setLoading(true);
    debugPrint('🔄 replaceAllNotes() llamado');
    debugPrint('   Nuevas notas a restaurar: ${newNotes.length}');
    
    try {
      // Primero, eliminar todas las notas existentes
      debugPrint('   Eliminando ${_notes.length} notas existentes...');
      for (var note in _notes) {
        await _apiService.deleteNote(note.id);
      }

      // Luego, crear las nuevas notas
      _notes.clear();
      debugPrint('   Creando ${newNotes.length} nuevas notas...');
      
      for (var note in newNotes) {
        final newNote = await _apiService.createNote(note.title, note.content);
        _notes.add(newNote);
        debugPrint('   - Creada: ${newNote.title}');
      }
      
      _error = null;
      debugPrint('✅ Restore completado: ${_notes.length} notas');
    } catch (e) {
      _error = 'Error al restaurar notas: $e';
      debugPrint('❌ Error en restore: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Método rápido para restore local (sin API)
  void restoreNotesLocally(List<Note> newNotes) {
    debugPrint('🔄 restoreNotesLocally() llamado');
    debugPrint('   Reemplazando ${_notes.length} notas por ${newNotes.length} notas');
    
    _notes = newNotes;
    notifyListeners();
    
    debugPrint('✅ Restore local completado');
  }

  // Limpiar todas las notas
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

  // Obtener nota por ID
  Note? getNoteById(int id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener nota eliminada por ID
  Note? getDeletedNoteById(int id) {
    try {
      return _deletedNotes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}