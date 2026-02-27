import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // 👈 IMPORTANTE: Para debugPrint
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import '../models/backup_history.dart';

class BackupService {
  static const String _historyFile = 'backup_history.json';
  
  List<BackupHistory> _history = [];
  BackupHistory? _latestBackup;

  // Cargar historial de backups
  Future<void> loadHistory() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;
      
      final backupFolder = Directory('${directory.path}/QuickNote/backups');
      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }
      
      final historyPath = '${backupFolder.path}/$_historyFile';
      final file = File(historyPath);
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _history = jsonList.map((json) => BackupHistory.fromJson(json)).toList();
        
        // Ordenar por fecha (más reciente primero)
        _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        if (_history.isNotEmpty) {
          _latestBackup = _history.first;
        }
      }
    } catch (e) {
      debugPrint('Error cargando historial: $e');
    }
  }

  // Guardar historial
  Future<void> _saveHistory() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return;
      
      final backupFolder = Directory('${directory.path}/QuickNote/backups');
      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }
      
      final historyPath = '${backupFolder.path}/$_historyFile';
      final file = File(historyPath);
      
      final jsonList = _history.map((h) => h.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList), encoding: utf8);
    } catch (e) {
      debugPrint('Error guardando historial: $e');
    }
  }

  // Backup Acumulativo
  Future<String?> performAccumulativeBackup(List<Note> currentNotes) async {
    try {
      await loadHistory();
      
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;
      
      final backupFolder = Directory('${directory.path}/QuickNote/backups');
      if (!await backupFolder.exists()) {
        await backupFolder.create(recursive: true);
      }
      
      // Determinar si es primer backup o acumulativo
      final isFirstBackup = _history.isEmpty;
      List<Note> notesToBackup;
      List<String> newNoteIds = [];
      
      if (isFirstBackup) {
        // Primer backup: guarda TODAS las notas
        notesToBackup = currentNotes;
        debugPrint('📦 Primer backup: guardando ${currentNotes.length} notas');
      } else {
        // Backup acumulativo: combina notas existentes + nuevas
        final previousNoteIds = _latestBackup!.noteIds.toSet();
        final currentNoteIds = currentNotes.map((n) => n.id.toString()).toSet();
        
        // Notas nuevas (las que no estaban en el backup anterior)
        newNoteIds = currentNoteIds.difference(previousNoteIds).toList();
        
        // Recuperar notas del backup anterior
        final previousNotes = await _loadNotesFromBackup(_latestBackup!.fileName);
        
        // Combinar notas anteriores + nuevas
        final notesMap = <String, Note>{};
        for (var note in previousNotes) {
          notesMap[note.id.toString()] = note;
        }
        
        // Agregar notas nuevas
        for (var note in currentNotes) {
          if (newNoteIds.contains(note.id.toString())) {
            notesMap[note.id.toString()] = note;
          }
        }
        
        notesToBackup = notesMap.values.toList();
        debugPrint('📦 Backup acumulativo: ${previousNotes.length} anteriores + ${newNoteIds.length} nuevas = ${notesToBackup.length} total');
      }
      
      // Crear archivo de backup
      final now = DateTime.now();
      final fileName = 'backup_${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}_${notesToBackup.length}notas.json';
      final backupFile = File('${backupFolder.path}/$fileName');
      
      final notesData = notesToBackup.map((note) => note.toJson()).toList();
      final backupData = {
        'version': '2.1.2',
        'timestamp': now.toIso8601String(),
        'total_notes': notesToBackup.length,
        'notes': notesData,
        'based_on': _latestBackup?.fileName,
        'new_notes': newNoteIds,
      };
      
      await backupFile.writeAsString(jsonEncode(backupData), encoding: utf8);
      
      // Actualizar historial
      final historyEntry = BackupHistory(
        fileName: fileName,
        timestamp: now,
        totalNotes: notesToBackup.length,
        noteIds: notesToBackup.map((n) => n.id.toString()).toList(),
        basedOn: _latestBackup?.fileName,
        newNotesIds: newNoteIds,
      );
      
      _history.insert(0, historyEntry);
      _latestBackup = historyEntry;
      await _saveHistory();
      
      return fileName;
    } catch (e) {
      debugPrint('Error en backup acumulativo: $e');
      return null;
    }
  }

  // Cargar notas desde un backup específico
  Future<List<Note>> _loadNotesFromBackup(String fileName) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return [];
      
      final backupFolder = Directory('${directory.path}/QuickNote/backups');
      if (!await backupFolder.exists()) return [];
      
      final file = File('${backupFolder.path}/$fileName');
      if (!await file.exists()) return [];
      
      final content = await file.readAsString();
      final jsonData = jsonDecode(content);
      
      final notesJson = jsonData['notes'] as List;
      return notesJson.map((noteJson) => Note.fromJson(noteJson)).toList();
    } catch (e) {
      debugPrint('Error cargando notas del backup: $e');
      return [];
    }
  }

  // Obtener historial
  List<BackupHistory> getHistory() => List.unmodifiable(_history);
  
  // Obtener último backup
  BackupHistory? getLatestBackup() => _latestBackup;
  
  // Obtener un backup específico por nombre de archivo
  Future<List<Note>?> getBackupByFileName(String fileName) async {
    try {
      return await _loadNotesFromBackup(fileName);
    } catch (e) {
      debugPrint('Error obteniendo backup: $e');
      return null;
    }
  }
}