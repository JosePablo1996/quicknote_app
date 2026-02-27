import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../providers/note_provider.dart';
import '../widgets/empty_notes_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/note_menu.dart';
import '../widgets/left_menu.dart';
import '../providers/theme_provider.dart';
import '../utils/snackbar_utils.dart';
import 'note_form_screen.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Note> _notes = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
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
  Set<int> _selectedNoteIds = {};

  // Controlador de animación para el FAB
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escuchar cambios en el provider
    _loadNotesFromProvider();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
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
          _notes = noteProvider.notes.where((note) => !note.isDeleted).toList();
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

  Future<void> _deleteSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;
    
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
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      setState(() => _isLoading = true);
      
      try {
        for (var noteId in _selectedNoteIds) {
          await noteProvider.deleteNote(noteId);
        }
        
        if (mounted) {
          await _loadNotesFromProvider();
          _exitSelectionMode();
          
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

  Future<void> _deleteNote(Note note) async {
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

    if (!mounted) return;

    if (confirm == true) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      setState(() => _isLoading = true);
      
      try {
        final success = await noteProvider.deleteNote(note.id);
        
        if (success && mounted) {
          await _loadNotesFromProvider();
          
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
  }

  void _showNoteOptions(Note note, Color noteColor) {
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
                      _deleteNote(note);
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
      _loadNotesFromProvider();
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

  void _onSelect() {
    setState(() {
      _isSelectionMode = true;
    });
    SnackbarUtils.showInfoSnackbar(
      context,
      'Modo selección activado',
    );
  }

  void _onSort() {
    _showSortDialog();
  }

  void _onSync() {
    SnackbarUtils.showInfoSnackbar(
      context,
      'Sincronizando notas...',
    );
    _loadNotesFromProvider();
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  Widget _buildGridCard(Note note, String initials, Color noteColor, bool isDarkMode) {
    return GestureDetector(
      onTap: _isSelectionMode
          ? () => _toggleNoteSelection(note.id)
          : () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => NoteDetailScreen(note: note),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
      onLongPress: () => _showNoteOptions(note, noteColor),
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
          : () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => NoteDetailScreen(note: note),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
      onLongPress: () => _showNoteOptions(note, noteColor),
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
      ),
    );
  }

  // Widget para el FAB animado en la esquina inferior derecha
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
        onPressed: _isSelectionMode || _isLoading
            ? null
            : () async {
                // Animación al presionar
                await _fabAnimationController.animateTo(0.0,
                    duration: const Duration(milliseconds: 200));
                
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const NoteFormScreen(),
                    transitionsBuilder: (_, animation, __, child) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                  ),
                );
                
                // Reiniciar animación después de volver
                _fabAnimationController.repeat(reverse: true);
                
                if (result == true && mounted) {
                  _loadNotesFromProvider();
                }
              },
        backgroundColor: _isSelectionMode || _isLoading ? Colors.grey : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
        tooltip: 'Agregar nota',
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
        child: Column(
          children: [
            CustomHeader(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                SnackbarUtils.showInfoSnackbar(
                  context,
                  'Filtrando por: $category',
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
                      onSelect: _onSelect,
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
                      onPressed: _deleteSelectedNotes,
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
                onRefresh: _loadNotesFromProvider,
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
                    : _notes.isEmpty
                        ? EmptyNotesWidget(
                            onCreateNote: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NoteFormScreen(),
                                ),
                              );
                              if (result == true && mounted) {
                                _loadNotesFromProvider();
                              }
                            },
                          )
                        : _buildNotesList(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(bool isDarkMode) {
    final filteredNotes = _selectedCategory == 'Todas'
        ? _notes
        : _notes.where((note) => note.tags.contains(_selectedCategory)).toList();
    
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