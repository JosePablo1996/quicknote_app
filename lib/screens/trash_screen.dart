import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/theme_provider.dart';
import '../providers/note_provider.dart';
import '../utils/snackbar_utils.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> with TickerProviderStateMixin {
  List<Note> _deletedNotes = [];
  bool _isLoading = true;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escuchar cambios en el provider
    final noteProvider = Provider.of<NoteProvider>(context);
    if (noteProvider.deletedNotes.length != _deletedNotes.length) {
      _loadDeletedNotes();
    }
  }

  void _loadDeletedNotes() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (mounted) {
      setState(() {
        _deletedNotes = noteProvider.deletedNotes;
        _isLoading = false;
      });
    }
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

  void _selectAllNotes() {
    setState(() {
      if (_selectedNoteIds.length == _deletedNotes.length) {
        _selectedNoteIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedNoteIds = _deletedNotes.map((note) => note.id).toSet();
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _restoreNote(Note note) async {
    final confirm = await _showRestoreConfirmationDialog(note.title);
    if (!mounted) return;
    
    if (confirm == true) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final success = await noteProvider.restoreNote(note.id);
      
      if (success && mounted) {
        _loadDeletedNotes();
        if (mounted) {
          SnackbarUtils.showSuccessSnackbar(
            context,
            'Nota restaurada exitosamente',
          );
        }
      }
    }
  }

  Future<void> _restoreSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;
    
    final confirm = await _showBulkRestoreConfirmationDialog(_selectedNoteIds.length);
    if (!mounted) return;
    
    if (confirm == true) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      for (var noteId in _selectedNoteIds) {
        await noteProvider.restoreNote(noteId);
      }
      
      if (mounted) {
        _loadDeletedNotes();
        setState(() {
          _selectedNoteIds.clear();
          _isSelectionMode = false;
        });
        
        SnackbarUtils.showSuccessSnackbar(
          context,
          '${_selectedNoteIds.length} notas restauradas',
        );
      }
    }
  }

  Future<void> _deletePermanently(Note note) async {
    final confirm = await _showPermanentDeleteConfirmationDialog(note.title, false);
    if (!mounted) return;
    
    if (confirm == true) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final success = await noteProvider.deletePermanently(note.id);
      
      if (success && mounted) {
        _loadDeletedNotes();
        if (mounted) {
          SnackbarUtils.showSuccessSnackbar(
            context,
            'Nota eliminada permanentemente',
          );
        }
      }
    }
  }

  Future<void> _deleteSelectedPermanently() async {
    if (_selectedNoteIds.isEmpty) return;
    
    final confirm = await _showPermanentDeleteConfirmationDialog(
      _selectedNoteIds.length,
      true,
    );
    
    if (!mounted) return;
    
    if (confirm == true) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      for (var noteId in _selectedNoteIds) {
        await noteProvider.deletePermanently(noteId);
      }
      
      if (mounted) {
        _loadDeletedNotes();
        setState(() {
          _selectedNoteIds.clear();
          _isSelectionMode = false;
        });
        
        SnackbarUtils.showSuccessSnackbar(
          context,
          '${_selectedNoteIds.length} notas eliminadas permanentemente',
        );
      }
    }
  }

  Future<void> _emptyTrash() async {
    if (_deletedNotes.isEmpty) return;
    
    final confirm = await _showEmptyTrashConfirmationDialog(_deletedNotes.length);
    if (!mounted) return;
    
    if (confirm == true) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.emptyTrash();
      
      if (mounted) {
        _loadDeletedNotes();
        setState(() {
          _selectedNoteIds.clear();
          _isSelectionMode = false;
        });
        
        SnackbarUtils.showSuccessSnackbar(
          context,
          'Papelera vaciada correctamente',
        );
      }
    }
  }

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
        return 'Hace ${difference.inDays ~/ 30} mes${difference.inDays ~/ 30 > 1 ? 'es' : ''}';
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
    final isDarkMode = themeProvider.isDarkMode;

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
          if (_deletedNotes.isNotEmpty) ...[
            if (_isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: _restoreSelectedNotes,
                tooltip: 'Restaurar seleccionadas',
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: _deleteSelectedPermanently,
                tooltip: 'Eliminar permanentemente',
              ),
              IconButton(
                icon: Icon(
                  _selectedNoteIds.length == _deletedNotes.length
                      ? Icons.deselect
                      : Icons.select_all,
                ),
                onPressed: _selectAllNotes,
                tooltip: _selectedNoteIds.length == _deletedNotes.length
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
                onPressed: _emptyTrash,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deletedNotes.isEmpty
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
                                onPressed: _selectAllNotes,
                                icon: const Icon(Icons.select_all, color: Colors.white),
                                label: Text(
                                  _selectedNoteIds.length == _deletedNotes.length
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
                          itemCount: _deletedNotes.length,
                          itemBuilder: (context, index) {
                            final note = _deletedNotes[index];
                            final noteColor = _getNoteColor(note);
                            final daysAgo = _formatDaysAgo(note.deletedAt ?? note.createdAt);
                            
                            return _buildTrashItem(
                              note,
                              noteColor,
                              daysAgo,
                              isDarkMode,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
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
          ],
        ),
      ),
    );
  }

  Widget _buildTrashItem(
    Note note,
    Color noteColor,
    String daysAgo,
    bool isDarkMode,
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
              child: Padding(
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
                              onPressed: () => _restoreNote(note),
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
                              onPressed: () => _deletePermanently(note),
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
            ),
          ),
        ),
      ),
    );
  }
}