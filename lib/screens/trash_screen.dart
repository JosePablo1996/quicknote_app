import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/theme_provider.dart';
import '../providers/note_provider.dart';
import '../widgets/connection_status.dart';
import '../utils/snackbar_utils.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> with TickerProviderStateMixin {
  bool _isSelectionMode = false;
  Set<int> _selectedNoteIds = {};
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadDeletedNotes();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDeletedNotes() async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    await noteProvider.loadDeletedNotes();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedNoteIds.clear();
      }
    });
  }

  void _toggleNoteSelection(int noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNoteIds.add(noteId);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAllNotes(List<Note> deletedNotes) {
    setState(() {
      if (_selectedNoteIds.length == deletedNotes.length) {
        _selectedNoteIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedNoteIds = deletedNotes.map((note) => note.id).toSet();
        _isSelectionMode = true;
      }
    });
  }

  // Widget para indicador de estado offline
  Widget _buildOfflineIndicator(Note note) {
    if (note.isSynced) return const SizedBox.shrink();
    
    return Positioned(
      top: 8,
      left: 8,
      child: Tooltip(
        message: note.hasSyncError
            ? 'Error de sincronización: ${note.lastSyncError}'
            : 'Pendiente de sincronizar',
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: note.hasSyncError
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.orange.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: note.hasSyncError ? Colors.red : Colors.orange,
              width: 1.5,
            ),
          ),
          child: Icon(
            note.hasSyncError ? Icons.error_outline : Icons.sync_problem,
            color: note.hasSyncError ? Colors.red : Colors.orange,
            size: 14,
          ),
        ),
      ),
    );
  }

  // ========== MÉTODO RESTORE NOTE ACTUALIZADO ==========
  // Restaurar nota individual
  Future<void> _restoreNote(Note note, NoteProvider noteProvider) async {
    final confirm = await _showRestoreConfirmationDialog(note.title);
    if (!mounted) return;
    
    if (confirm == true) {
      final success = await noteProvider.restoreNote(note.id);
      
      if (success && mounted) {
        // Mostrar notificación de éxito
        _showRestoreSuccessNotification();
        
        // 👇 FORZAR ACTUALIZACIÓN DE LA UI DEL NOTE LIST SCREEN
        // Esto asegura que las notas restauradas aparezcan inmediatamente
        noteProvider.notifyListeners();
        
        // Actualizar la UI local de la papelera
        setState(() {
          if (_isSelectionMode) {
            _isSelectionMode = false;
            _selectedNoteIds.clear();
          }
          // No necesitamos actualizar _deletedNotes porque el provider ya notificó
        });
        
        // Mostrar mensaje adicional en modo offline
        if (noteProvider.isOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sync_problem,
                      color: Colors.orange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nota restaurada localmente - Se sincronizará cuando haya conexión',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade800,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      }
    }
  }

  // ========== MÉTODO RESTORE SELECTED NOTES ACTUALIZADO ==========
  // Restaurar múltiples notas
  Future<void> _restoreSelectedNotes(NoteProvider noteProvider) async {
    if (_selectedNoteIds.isEmpty) return;
    
    final confirm = await _showBulkRestoreConfirmationDialog(_selectedNoteIds.length);
    if (!mounted) return;
    
    if (confirm == true) {
      int successCount = 0;
      for (var noteId in _selectedNoteIds) {
        final success = await noteProvider.restoreNote(noteId);
        if (success) successCount++;
      }
      
      if (mounted && successCount > 0) {
        // Mostrar notificación de éxito
        _showBulkRestoreSuccessNotification(successCount);
        
        // 👇 FORZAR ACTUALIZACIÓN DE LA UI DEL NOTE LIST SCREEN
        // Esto asegura que las notas restauradas aparezcan inmediatamente
        noteProvider.notifyListeners();
        
        // Actualizar la UI local de la papelera
        setState(() {
          _selectedNoteIds.clear();
          _isSelectionMode = false;
          // No necesitamos actualizar _deletedNotes porque el provider ya notificó
        });
        
        // Mostrar mensaje adicional en modo offline
        if (noteProvider.isOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sync_problem,
                      color: Colors.orange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$successCount nota${successCount > 1 ? 's' : ''} restaurada${successCount > 1 ? 's' : ''} localmente - Se sincronizarán cuando haya conexión',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange.shade800,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(12),
            ),
          );
        }
      }
    }
  }

  // NOTIFICACIÓN PARA RESTAURACIÓN INDIVIDUAL
  void _showRestoreSuccessNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restore_from_trash,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ Nota restaurada',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'La nota ha sido restaurada exitosamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade800,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.white,
          onPressed: () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          },
        ),
      ),
    );
  }

  // NOTIFICACIÓN PARA RESTAURACIÓN MÚLTIPLE
  void _showBulkRestoreSuccessNotification(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restore_from_trash,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ $count nota${count > 1 ? 's' : ''} restaurada${count > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Las notas han sido restauradas exitosamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade800,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(12),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.white,
          onPressed: () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          },
        ),
      ),
    );
  }

  // Eliminar permanentemente nota individual
  Future<void> _deletePermanently(Note note, NoteProvider noteProvider) async {
    final confirm = await _showPermanentDeleteConfirmationDialog(note.title, false);
    if (!mounted) return;
    
    if (confirm == true) {
      final success = await noteProvider.deletePermanently(note.id);
      
      if (success && mounted) {
        // Forzar actualización de la UI
        noteProvider.notifyListeners();
        
        SnackbarUtils.showSuccessSnackbar(
          context,
          'Nota eliminada permanentemente',
        );
        
        setState(() {
          if (_isSelectionMode) {
            _isSelectionMode = false;
            _selectedNoteIds.clear();
          }
        });
      }
    }
  }

  // Eliminar permanentemente múltiples notas
  Future<void> _deleteSelectedPermanently(NoteProvider noteProvider) async {
    if (_selectedNoteIds.isEmpty) return;
    
    final confirm = await _showPermanentDeleteConfirmationDialog(
      _selectedNoteIds.length,
      true,
    );
    
    if (!mounted) return;
    
    if (confirm == true) {
      int successCount = 0;
      for (var noteId in _selectedNoteIds) {
        final success = await noteProvider.deletePermanently(noteId);
        if (success) successCount++;
      }
      
      if (mounted && successCount > 0) {
        // Forzar actualización de la UI
        noteProvider.notifyListeners();
        
        SnackbarUtils.showSuccessSnackbar(
          context,
          '$successCount nota${successCount > 1 ? 's' : ''} eliminada${successCount > 1 ? 's' : ''} permanentemente',
        );
        
        setState(() {
          _selectedNoteIds.clear();
          _isSelectionMode = false;
        });
      }
    }
  }

  // Vaciar toda la papelera
  Future<void> _emptyTrash(NoteProvider noteProvider) async {
    if (noteProvider.deletedNotes.isEmpty) return;
    
    final confirm = await _showEmptyTrashConfirmationDialog(noteProvider.deletedNotes.length);
    if (!mounted) return;
    
    if (confirm == true) {
      await noteProvider.emptyTrash();
      
      if (mounted) {
        // Forzar actualización de la UI
        noteProvider.notifyListeners();
        
        SnackbarUtils.showSuccessSnackbar(
          context,
          'Papelera vaciada correctamente',
        );
        
        setState(() {
          _selectedNoteIds.clear();
          _isSelectionMode = false;
        });
      }
    }
  }

  // Diálogos de confirmación
  Future<bool> _showRestoreConfirmationDialog(String noteTitle) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.restore_from_trash, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            Text(
              '¿Restaurar la nota "$noteTitle"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'La nota volverá a aparecer en tu lista principal.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showBulkRestoreConfirmationDialog(int count) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar notas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.restore_from_trash, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            Text(
              '¿Restaurar $count nota${count > 1 ? 's' : ''}?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Las notas volverán a aparecer en tu lista principal.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Restaurar $count'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showPermanentDeleteConfirmationDialog(dynamic item, bool isBulk) async {
    String title = isBulk ? 'Eliminar $item notas' : 'Eliminar permanentemente';
    String content = isBulk
        ? '¿Eliminar permanentemente $item notas?'
        : '¿Eliminar permanentemente la nota "$item"?';
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              '⚠️ Esta acción NO SE PUEDE DESHACER. Las notas se perderán para siempre.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showEmptyTrashConfirmationDialog(int count) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar papelera'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.delete_sweep, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              '¿Vaciar la papelera?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Se eliminarán permanentemente $count nota${count > 1 ? 's' : ''}.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ Esta acción NO SE PUEDE DESHACER.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDaysAgo(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Hoy';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
      } else {
        final months = difference.inDays ~/ 30;
        return 'Hace $months mes${months > 1 ? 'es' : ''}';
      }
    } catch (e) {
      return 'Fecha desconocida';
    }
  }

  Color _getNoteColor(Note note) {
    if (note.colorHex != null && note.colorHex!.isNotEmpty) {
      try {
        return Color(int.parse(note.colorHex!.replaceFirst('#', '0xff')));
      } catch (e) {
        return Colors.grey;
      }
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final deletedNotes = noteProvider.deletedNotes;
    final isLoading = noteProvider.isLoading;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Papelera',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (deletedNotes.isNotEmpty) ...[
            if (_isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () => _restoreSelectedNotes(noteProvider),
                tooltip: 'Restaurar seleccionadas',
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () => _deleteSelectedPermanently(noteProvider),
                tooltip: 'Eliminar permanentemente',
              ),
              IconButton(
                icon: Icon(
                  _selectedNoteIds.length == deletedNotes.length
                      ? Icons.deselect
                      : Icons.select_all,
                ),
                onPressed: () => _selectAllNotes(deletedNotes),
                tooltip: _selectedNoteIds.length == deletedNotes.length
                    ? 'Deseleccionar todo'
                    : 'Seleccionar todo',
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: _toggleSelectionMode,
                tooltip: 'Modo selección',
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _emptyTrash(noteProvider),
                tooltip: 'Vaciar papelera',
              ),
            ],
          ],
        ],
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const ConnectionStatus(),
                
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadDeletedNotes,
                    color: Colors.red,
                    backgroundColor: Colors.white,
                    displacement: 40,
                    child: deletedNotes.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                if (_isSelectionMode)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    color: Colors.red.shade700,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${_selectedNoteIds.length} seleccionada${_selectedNoteIds.length > 1 ? 's' : ''}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _selectAllNotes(deletedNotes),
                                          icon: const Icon(Icons.select_all, color: Colors.white),
                                          label: Text(
                                            _selectedNoteIds.length == deletedNotes.length
                                                ? 'Deseleccionar'
                                                : 'Seleccionar todo',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: deletedNotes.length,
                                    itemBuilder: (context, index) {
                                      final note = deletedNotes[index];
                                      final noteColor = _getNoteColor(note);
                                      final daysAgo = _formatDaysAgo(note.deletedAt ?? note.createdAt);
                                      
                                      return _buildTrashItem(
                                        note,
                                        noteColor,
                                        daysAgo,
                                        isDarkMode,
                                        noteProvider,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade400.withValues(alpha: 0.2),
                      Colors.red.shade700.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 80,
                  color: isDarkMode ? Colors.red.shade300 : Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'La papelera está vacía',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Las notas que elimines aparecerán aquí. Puedes restaurarlas o eliminarlas permanentemente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.red.shade200.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Desliza hacia abajo para actualizar',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrashItem(
    Note note,
    Color noteColor,
    String daysAgo,
    bool isDarkMode,
    NoteProvider noteProvider,
  ) {
    final isSelected = _selectedNoteIds.contains(note.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.grey[850]!.withValues(alpha: 0.7),
                  Colors.grey[900]!.withValues(alpha: 0.5),
                ]
              : [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.grey[50]!.withValues(alpha: 0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Colors.red
              : isDarkMode
                  ? Colors.grey[700]!.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.9),
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_isSelectionMode) {
                  _toggleNoteSelection(note.id);
                }
              },
              onLongPress: () => _toggleNoteSelection(note.id),
              child: Stack(
                children: [
                  // Indicador de estado offline
                  _buildOfflineIndicator(note),
                  
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSelectionMode) ...[
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleNoteSelection(note.id),
                            activeColor: Colors.red,
                            shape: const CircleBorder(),
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400.withValues(alpha: 0.2),
                                  Colors.red.shade700.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.red.shade400.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.red.shade400.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: Colors.red.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          daysAgo,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red.shade400,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note.content,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (note.tags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: note.tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: noteColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: noteColor.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: noteColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        if (!_isSelectionMode) ...[
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.restore, color: Colors.green),
                                  onPressed: () => _restoreNote(note, noteProvider),
                                  iconSize: 20,
                                  tooltip: 'Restaurar',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                                  onPressed: () => _deletePermanently(note, noteProvider),
                                  iconSize: 20,
                                  tooltip: 'Eliminar permanentemente',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}