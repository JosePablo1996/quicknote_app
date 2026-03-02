// lib/screens/archived_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/theme_provider.dart';
import '../providers/note_provider.dart';
import '../utils/snackbar_utils.dart';
import 'note_detail_screen.dart';

class ArchivedScreen extends StatefulWidget {
  const ArchivedScreen({super.key});

  @override
  State<ArchivedScreen> createState() => _ArchivedScreenState();
}

class _ArchivedScreenState extends State<ArchivedScreen> with TickerProviderStateMixin {
  String _selectedCategory = 'Todas';
  bool _isGridView = true;
  bool _isSelectionMode = false;
  Set<int> _selectedNoteIds = {};
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = ['Todas', 'Personal', 'Trabajo'];

  @override
  void initState() {
    super.initState();
    
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

  List<Note> _getArchivedNotes() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: true);
    return noteProvider.notes
        .where((note) => note.isArchived && !note.isDeleted)
        .toList();
  }

  List<Note> _getFilteredNotes() {
    final archived = _getArchivedNotes();
    
    if (_selectedCategory == 'Todas') {
      return archived;
    }
    
    return archived.where((note) {
      if (_selectedCategory == 'Personal') {
        return note.tags.contains('personal');
      } else if (_selectedCategory == 'Trabajo') {
        return note.tags.contains('trabajo');
      }
      return true;
    }).toList();
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
    final notes = _getFilteredNotes();
    setState(() {
      if (_selectedNoteIds.length == notes.length) {
        _selectedNoteIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedNoteIds = notes.map((note) => note.id).toSet();
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _unarchiveSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar notas'),
        content: Text('¿Restaurar ${_selectedNoteIds.length} nota${_selectedNoteIds.length > 1 ? 's' : ''} a la lista principal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      for (var noteId in _selectedNoteIds) {
        final note = noteProvider.notes.firstWhere((n) => n.id == noteId);
        // Usar copyWithArchived en lugar de copyWith
        final updatedNote = note.copyWithArchived(false);
        await noteProvider.updateNote(updatedNote);
      }
      
      if (mounted) {
        setState(() {
          _selectedNoteIds.clear();
          _isSelectionMode = false;
        });
        
        SnackbarUtils.showSuccessSnackbar(
          context,
          'Notas restauradas a la lista principal',
        );
      }
    }
  }

  String _getInitials(String title) {
    if (title.isEmpty) return '?';
    final words = title.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return title[0].toUpperCase();
  }

  Color _getNoteColor(Note note) {
    if (note.colorHex != null && note.colorHex!.isNotEmpty) {
      try {
        return Color(int.parse(note.colorHex!.replaceFirst('#', '0xff')));
      } catch (e) {
        final List<Color> colors = [
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal,
          Colors.pink,
          Colors.indigo,
        ];
        return colors[note.id % colors.length];
      }
    }
    
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[note.id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final archivedNotes = _getArchivedNotes();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notas archivadas',
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
          if (archivedNotes.isNotEmpty) ...[
            if (_isSelectionMode) ...[
              IconButton(
                icon: const Icon(Icons.unarchive),
                onPressed: _unarchiveSelectedNotes,
                tooltip: 'Restaurar seleccionadas',
              ),
              IconButton(
                icon: Icon(
                  _selectedNoteIds.length == _getFilteredNotes().length
                      ? Icons.deselect
                      : Icons.select_all,
                ),
                onPressed: _selectAllNotes,
                tooltip: _selectedNoteIds.length == _getFilteredNotes().length
                    ? 'Deseleccionar todo'
                    : 'Seleccionar todo',
              ),
            ] else ...[
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                tooltip: _isGridView ? 'Vista lista' : 'Vista grid',
              ),
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: _toggleSelectionMode,
                tooltip: 'Modo selección',
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
      body: archivedNotes.isEmpty
          ? _buildEmptyState(isDarkMode)
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Chips de categorías
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _categories.map((category) {
                        final isSelected = category == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [Colors.teal.shade400, Colors.green.shade400],
                                    )
                                  : null,
                              color: isSelected ? null : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isDarkMode ? Colors.grey[700]! : Colors.grey[400]!),
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  if (_isSelectionMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.teal.shade700,
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
                              _selectedNoteIds.length == _getFilteredNotes().length
                                  ? 'Deseleccionar'
                                  : 'Seleccionar todo',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Expanded(
                    child: _isGridView
                        ? _buildGridView(isDarkMode)
                        : _buildListView(isDarkMode),
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
                    Colors.teal.shade400.withValues(alpha: 0.2),
                    Colors.green.shade700.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.archive_outlined,
                size: 80,
                color: isDarkMode ? Colors.teal.shade300 : Colors.teal.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay notas archivadas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Las notas que archives aparecerán aquí. Puedes restaurarlas en cualquier momento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(bool isDarkMode) {
    final notes = _getFilteredNotes();
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final noteColor = _getNoteColor(note).withValues(alpha: 0.7);
        final initials = _getInitials(note.title);
        final isSelected = _selectedNoteIds.contains(note.id);
        
        return GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              _toggleNoteSelection(note.id);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
            }
          },
          onLongPress: () => _toggleNoteSelection(note.id),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDarkMode ? Colors.grey[850]! : Colors.white,
                  noteColor.withValues(alpha: 0.05),
                  noteColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.teal
                    : noteColor.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: noteColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                // Indicador de archivada
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.archive,
                      color: Colors.teal,
                      size: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  noteColor,
                                  noteColor.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (note.isFavorite)
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade400,
                              size: 14,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: noteColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.content,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(bool isDarkMode) {
    final notes = _getFilteredNotes();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final noteColor = _getNoteColor(note).withValues(alpha: 0.7);
        final initials = _getInitials(note.title);
        final isSelected = _selectedNoteIds.contains(note.id);
        
        return GestureDetector(
          onTap: () {
            if (_isSelectionMode) {
              _toggleNoteSelection(note.id);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
            }
          },
          onLongPress: () => _toggleNoteSelection(note.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDarkMode ? Colors.grey[850]! : Colors.white,
                  noteColor.withValues(alpha: 0.05),
                  noteColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.teal
                    : noteColor.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: noteColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          noteColor,
                          noteColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: const Icon(
                                Icons.archive,
                                color: Colors.teal,
                                size: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                note.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: noteColor,
                                ),
                              ),
                            ),
                            if (note.isFavorite)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.amber.shade400,
                                  size: 18,
                                ),
                              ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.teal,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Archivada: ${note.formattedCreatedDate}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
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
      },
    );
  }
}