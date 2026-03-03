import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../widgets/empty_notes_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/note_menu.dart';
import '../widgets/left_menu.dart';
import '../widgets/connection_status.dart'; // 👈 NUEVO IMPORT
import '../providers/theme_provider.dart';
import '../utils/snackbar_utils.dart';
import 'note_form_screen.dart';
import 'note_detail_screen.dart';
import 'favorites_screen.dart';
import 'archived_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Variables para el cambio de vista y ordenamiento
  bool _isGridView = true;
  String _currentSortOption = 'Fecha de modificación';
  final List<String> _sortOptions = [
    'Fecha de modificación',
    'Fecha de creación',
    'Título (A-Z)',
    'Título (Z-A)',
  ];
  
  // Variables para selección múltiple
  bool _isSelectionMode = false;
  final Set<int> _selectedNoteIds = {};

  // Controlador de animación para el FAB
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;
  
  // Controlador para la animación de parpadeo de favoritos
  late AnimationController _favoriteBlinkController;

  @override
  void initState() {
    super.initState();
    _loadNotesFromProvider();
    
    // Configurar animaciones para el FAB
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Controlador para animación de parpadeo
    _favoriteBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotesFromProvider();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    _favoriteBlinkController.dispose();
    super.dispose();
  }

  Future<void> _loadNotesFromProvider() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.loadNotes();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showErrorSnackbar(
          context,
          'Error al cargar notas: $e',
        );
      }
    }
  }

  // Función de sincronización
  Future<void> _syncNotes() async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    
    try {
      await noteProvider.loadNotes();
      if (mounted) {
        SnackbarUtils.showSuccessSnackbar(
          context,
          'Notas sincronizadas correctamente',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(
          context,
          'Error al sincronizar: $e',
        );
      }
    }
  }

  // Función para ordenar notas según opción seleccionada
  List<Note> _sortNotes(List<Note> notes) {
    final sortedNotes = List<Note>.from(notes);
    
    switch (_currentSortOption) {
      case 'Fecha de modificación':
        sortedNotes.sort((a, b) {
          final aDate = a.updatedAt ?? a.createdAt;
          final bDate = b.updatedAt ?? b.createdAt;
          return bDate.compareTo(aDate);
        });
        break;
      case 'Fecha de creación':
        sortedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Título (A-Z)':
        sortedNotes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Título (Z-A)':
        sortedNotes.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
    
    return sortedNotes;
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
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
        if (!_isSelectionMode) {
          _isSelectionMode = true;
        }
      }
    });
  }

  // Función de eliminación múltiple
  Future<void> _deleteSelectedNotes(NoteProvider noteProvider) async {
    if (_selectedNoteIds.isEmpty) {
      SnackbarUtils.showInfoSnackbar(
        context,
        'No hay notas seleccionadas. Mantén presionada una nota para seleccionar.',
      );
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar ${_selectedNoteIds.length} notas'),
        content: Text('¿Estás seguro de eliminar ${_selectedNoteIds.length} notas?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      setState(() => _isLoading = true);
      
      try {
        for (var noteId in _selectedNoteIds) {
          await noteProvider.deleteNote(noteId);
        }
        
        if (mounted) {
          await noteProvider.loadNotes();
          setState(() {
            _isLoading = false;
            _exitSelectionMode();
          });
          
          SnackbarUtils.showSuccessSnackbar(
            context,
            '${_selectedNoteIds.length} notas movidas a la papelera',
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          SnackbarUtils.showErrorSnackbar(
            context,
            'Error al eliminar notas: $e',
          );
        }
      }
    }
  }

  // Función de eliminación individual
  Future<void> _deleteNote(NoteProvider noteProvider, Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Estás seguro de eliminar "${note.title}"?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final success = await noteProvider.deleteNote(note.id);
      
      if (success && mounted) {
        await noteProvider.loadNotes();
        setState(() => _isLoading = false);
        
        SnackbarUtils.showSuccessSnackbar(
          context, 
          '"${note.title}" movida a la papelera'
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showErrorSnackbar(
          context, 
          'Error al eliminar: $e'
        );
      }
    }
  }

  // Función para añadir/quitar favoritos
  Future<void> _toggleFavorite(NoteProvider noteProvider, Note note) async {
    final newFavoriteState = !note.isFavorite;
    final updatedNote = note.copyWithFavorite(newFavoriteState);
    
    try {
      await noteProvider.updateNote(updatedNote);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                AnimatedBuilder(
                  animation: _favoriteBlinkController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: newFavoriteState 
                            ? Colors.amber.withValues(alpha: 0.2 + (_favoriteBlinkController.value * 0.5))
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        newFavoriteState ? Icons.star : Icons.star_border,
                        color: newFavoriteState 
                            ? Colors.amber.shade400
                            : Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        newFavoriteState 
                            ? '✨ ¡Nota favorita!' 
                            : 'Nota quitada de favoritos',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        newFavoriteState
                            ? 'La nota ha sido añadida a favoritos'
                            : 'La nota ya no está en favoritos',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: newFavoriteState ? Colors.amber.shade700 : Colors.grey.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
            action: SnackBarAction(
              label: 'VER',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(
          context,
          'Error al actualizar favorito: $e',
        );
      }
    }
  }

  // Función para archivar/desarchivar notas
  Future<void> _toggleArchive(NoteProvider noteProvider, Note note) async {
    final newArchiveState = !note.isArchived;
    final updatedNote = note.copyWithArchived(newArchiveState);
    
    try {
      await noteProvider.updateNote(updatedNote);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newArchiveState ? Icons.archive : Icons.unarchive,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        newArchiveState 
                            ? '📦 Nota archivada' 
                            : 'Nota restaurada',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        newArchiveState
                            ? 'La nota se movió a archivadas'
                            : 'La nota volvió a la lista principal',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: newArchiveState ? Colors.teal.shade700 : Colors.green.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
            action: SnackBarAction(
              label: 'VER',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArchivedScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(
          context,
          'Error al archivar: $e',
        );
      }
    }
  }

  void _showNoteOptions(NoteProvider noteProvider, Note note, Color noteColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.95),
              noteColor.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: noteColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white.withValues(alpha: 0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
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
                          boxShadow: [
                            BoxShadow(
                              color: noteColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(note.title),
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
                            Text(
                              note.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: noteColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.content,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Opción de favoritos
                  _buildModalOption(
                    icon: note.isFavorite ? Icons.star : Icons.star_border,
                    label: note.isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                    color: Colors.amber,
                    onTap: () {
                      Navigator.pop(context);
                      _toggleFavorite(noteProvider, note);
                    },
                  ),
                  
                  // Opción de archivar/desarchivar
                  _buildModalOption(
                    icon: note.isArchived ? Icons.unarchive : Icons.archive,
                    label: note.isArchived ? 'Desarchivar nota' : 'Archivar nota',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(context);
                      _toggleArchive(noteProvider, note);
                    },
                  ),
                  
                  _buildModalOption(
                    icon: Icons.edit,
                    label: 'Editar nota',
                    color: noteColor,
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToEditNote(note);
                    },
                  ),
                  _buildModalOption(
                    icon: Icons.delete_outline,
                    label: 'Eliminar nota',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _deleteNote(noteProvider, note);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.7),
            Colors.white.withValues(alpha: 0.9),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEditNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteFormScreen(note: note),
      ),
    );
    if (result == true && mounted) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.loadNotes();
    }
  }

  void _onViewList() {
    setState(() {
      _isGridView = !_isGridView;
    });
    SnackbarUtils.showInfoSnackbar(
      context,
      _isGridView ? 'Vista grid activada' : 'Vista lista activada',
    );
  }

  void _onSort() {
    _showSortDialog();
  }

  void _onSync() {
    _syncNotes();
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Ordenar notas'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: _sortOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _currentSortOption,
                  onChanged: (value) {
                    setState(() {
                      _currentSortOption = value!;
                    });
                    Navigator.pop(context);
                    SnackbarUtils.showInfoSnackbar(
                      context,
                      'Ordenado por: $value',
                    );
                  },
                );
              }).toList(),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  void _openLeftMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeLeftMenu() {
    Navigator.pop(context);
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

  // Widget para el punto de notificación parpadeante (favoritos)
  Widget _buildBlinkingNotification() {
    return AnimatedBuilder(
      animation: _favoriteBlinkController,
      builder: (context, child) {
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.3 + (_favoriteBlinkController.value * 0.7)),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.5),
                blurRadius: 4 + (_favoriteBlinkController.value * 4),
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  // 👇 NUEVO: Widget para indicador de estado offline
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

  Widget _buildGridCard(Note note, String initials, Color noteColor, bool isDarkMode) {
    return GestureDetector(
      onTap: _isSelectionMode
          ? () => _toggleNoteSelection(note.id)
          : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
              if (result == true && mounted) {
                final noteProvider = Provider.of<NoteProvider>(context, listen: false);
                await noteProvider.loadNotes();
              }
            },
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedNoteIds.add(note.id);
          });
        } else {
          _toggleNoteSelection(note.id);
        }
      },
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
            color: _isSelectionMode && _selectedNoteIds.contains(note.id)
                ? Colors.blue
                : noteColor.withValues(alpha: 0.3),
            width: _isSelectionMode && _selectedNoteIds.contains(note.id) ? 2 : 1,
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
            // Indicador de selección
            if (_isSelectionMode && _selectedNoteIds.contains(note.id))
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            
            // 👇 NUEVO: Indicador de estado offline
            _buildOfflineIndicator(note),
            
            // Indicador de favorito (LED parpadeante)
            if (note.isFavorite)
              Positioned(
                bottom: 8,
                right: 8,
                child: _buildBlinkingNotification(),
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
  }

  Widget _buildListCard(Note note, String initials, Color noteColor, bool isDarkMode) {
    return GestureDetector(
      onTap: _isSelectionMode
          ? () => _toggleNoteSelection(note.id)
          : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
              if (result == true && mounted) {
                final noteProvider = Provider.of<NoteProvider>(context, listen: false);
                await noteProvider.loadNotes();
              }
            },
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedNoteIds.add(note.id);
          });
        } else {
          _toggleNoteSelection(note.id);
        }
      },
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
            color: _isSelectionMode && _selectedNoteIds.contains(note.id)
                ? Colors.blue
                : noteColor.withValues(alpha: 0.3),
            width: _isSelectionMode && _selectedNoteIds.contains(note.id) ? 2 : 1,
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
            Padding(
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
                      boxShadow: [
                        BoxShadow(
                          color: noteColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
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
                            if (_isSelectionMode && _selectedNoteIds.contains(note.id))
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
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
                          'Creada: ${note.formattedCreatedDate}',
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
            
            // 👇 NUEVO: Indicador de estado offline
            _buildOfflineIndicator(note),
            
            // Indicador de favorito (LED parpadeante)
            if (note.isFavorite)
              Positioned(
                bottom: 8,
                right: 8,
                child: _buildBlinkingNotification(),
              ),
          ],
        ),
      ),
    );
  }

  // Widget para el FAB con menú
  Widget _buildAnimatedFAB() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: Transform.rotate(
            angle: _fabRotationAnimation.value,
            child: child,
          ),
        );
      },
      child: FloatingActionButton(
        onPressed: _isLoading ? null : _showFabMenu,
        backgroundColor: _isSelectionMode || _isLoading ? Colors.grey : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
        tooltip: 'Opciones',
      ),
    );
  }

  // Menú del FAB
  void _showFabMenu() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.blue.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white.withValues(alpha: 0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Opción: Crear nueva nota
                  _buildFabOption(
                    icon: Icons.note_add,
                    label: 'Crear nueva nota',
                    color: Colors.blue,
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NoteFormScreen(),
                        ),
                      );
                      if (result == true && mounted) {
                        await noteProvider.loadNotes();
                      }
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Opción: Eliminar múltiples notas
                  _buildFabOption(
                    icon: Icons.delete_sweep,
                    label: 'Eliminar notas seleccionadas',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _deleteSelectedNotes(noteProvider);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para las opciones del FAB
  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.grey[800]!.withValues(alpha: 0.5),
                  Colors.grey[700]!.withValues(alpha: 0.3),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.grey[50]!.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: color.withValues(alpha: 0.2),
              highlightColor: color.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.2),
                            color.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: color,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      drawer: LeftMenu(onClose: _closeLeftMenu),
      floatingActionButton: _buildAnimatedFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Consumer<NoteProvider>(
          builder: (context, noteProvider, child) {
            final notes = noteProvider.notes
                .where((note) => !note.isDeleted && !note.isArchived)
                .toList();
            
            // Si la categoría seleccionada ya no existe, volver a "Todas"
            if (_selectedCategory != 'Todas') {
              final categoryExists = notes.any((note) => note.tags.contains(_selectedCategory));
              if (!categoryExists) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _selectedCategory = 'Todas';
                    });
                  }
                });
              }
            }
            
            return Column(
              children: [
                // 👇 NUEVO: Barra de estado de conexión
                const ConnectionStatus(),
                
                CustomHeader(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    SnackbarUtils.showInfoSnackbar(
                      context,
                      category == 'Todas' 
                          ? 'Mostrando todas las notas'
                          : 'Filtrando por etiqueta: $category',
                    );
                  },
                  onLeftMenuTap: _openLeftMenu,
                  onRightMenuTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierColor: Colors.black.withValues(alpha: 0.3),
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                        child: NoteMenu(
                          onViewList: _onViewList,
                          onSort: _onSort,
                          onSync: _onSync,
                          onImport: () {},
                        ),
                      ),
                    );
                  },
                ),
                
                if (_isSelectionMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.blue,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedNoteIds.length} notas seleccionadas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deleteSelectedNotes(noteProvider),
                          tooltip: 'Eliminar seleccionadas',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _exitSelectionMode,
                          tooltip: 'Cancelar selección',
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _syncNotes,
                    color: Colors.blue,
                    backgroundColor: Colors.white,
                    displacement: 40,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                              strokeWidth: 3,
                            ),
                          )
                        : notes.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.6,
                                  child: EmptyNotesWidget(
                                    onCreateNote: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NoteFormScreen(),
                                        ),
                                      );
                                      if (result == true && mounted) {
                                        await noteProvider.loadNotes();
                                      }
                                    },
                                  ),
                                ),
                              )
                            : _buildNotesList(notes, isDarkMode),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes, bool isDarkMode) {
    final filteredNotes = _selectedCategory == 'Todas'
        ? notes
        : notes.where((note) => note.tags.contains(_selectedCategory)).toList();
    
    final sortedNotes = _sortNotes(filteredNotes);

    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: sortedNotes.length,
        itemBuilder: (context, index) {
          final note = sortedNotes[index];
          final initials = _getInitials(note.title);
          final noteColor = _getNoteColor(note);
          
          return _buildGridCard(
            note, 
            initials, 
            noteColor, 
            isDarkMode
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedNotes.length,
        itemBuilder: (context, index) {
          final note = sortedNotes[index];
          final initials = _getInitials(note.title);
          final noteColor = _getNoteColor(note);
          
          return _buildListCard(
            note, 
            initials, 
            noteColor, 
            isDarkMode
          );
        },
      );
    }
  }
}