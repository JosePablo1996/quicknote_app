import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  // Getters
  List<Note> get notes => List.unmodifiable(_notes);
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

  // Eliminar nota
  Future<bool> deleteNote(int id) async {
    _setLoading(true);
    try {
      await _apiService.deleteNote(id);
      _notes.removeWhere((note) => note.id == id);
      _error = null;
      debugPrint('✅ Nota eliminada: $id');
      debugPrint('   Total notas ahora: ${_notes.length}');
      return true;
    } catch (e) {
      _error = 'Error al eliminar nota: $e';
      return false;
    } finally {
      _setLoading(false);
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
}