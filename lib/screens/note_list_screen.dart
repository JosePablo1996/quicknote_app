import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/api_service.dart';
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

class _NoteListScreenState extends State<NoteListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Note>> _futureNotes;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedCategory = 'Todas';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    setState(() {
      _futureNotes = _apiService.getNotes();
    });
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

    if (confirm == true) {
      try {
        await _apiService.deleteNote(note.id);
        _loadNotes();
        if (mounted) {
          SnackbarUtils.showSuccessSnackbar(
            context, 
            '"${note.title}" eliminada'
          );
        }
      } catch (e) {
        if (mounted) {
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
                    icon: Icons.update,
                    label: 'Actualizar nota',
                    color: noteColor,
                    onTap: () {
                      Navigator.pop(context);
                      SnackbarUtils.showInfoSnackbar(
                        context,
                        'Función de actualizar próximamente',
                      );
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
    if (result == true) _loadNotes();
  }

  void _onViewList() {
    SnackbarUtils.showInfoSnackbar(context, 'Cambiar vista');
  }

  void _onSelect() {
    SnackbarUtils.showInfoSnackbar(context, 'Seleccionar notas');
  }

  void _onSort() {
    SnackbarUtils.showInfoSnackbar(context, 'Ordenar notas');
  }

  void _onSync() {
    SnackbarUtils.showInfoSnackbar(context, 'Sincronizando...');
    _loadNotes();
  }

  void _onImport() {
    SnackbarUtils.showInfoSnackbar(context, 'Importar notas');
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[50],
      drawer: LeftMenu(onClose: _closeLeftMenu),
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
                      onImport: _onImport,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  _loadNotes();
                },
                color: Colors.blue,
                backgroundColor: Colors.white,
                displacement: 40,
                child: FutureBuilder<List<Note>>(
                  future: _futureNotes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 3,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red.shade400,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '¡Ups! Algo salió mal',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                onPressed: _loadNotes,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final notes = snapshot.data ?? [];
                    
                    if (notes.isEmpty) {
                      return EmptyNotesWidget(
                        onCreateNote: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NoteFormScreen(),
                            ),
                          );
                          if (result == true) _loadNotes();
                        },
                      );
                    }

                    final filteredNotes = _selectedCategory == 'Todas'
                        ? notes
                        : notes.where((note) => note.id % 2 == 0).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        final initials = _getInitials(note.title);
                        final noteColor = _getNoteColor(note);
                        
                        return GestureDetector(
                          onTap: () {
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
                                  themeProvider.isDarkMode ? Colors.grey[850]! : Colors.white,
                                  noteColor.withValues(alpha: 0.05),
                                  noteColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: noteColor.withValues(alpha: 0.3),
                                width: 1,
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
                                        Text(
                                          note.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: noteColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          note.content,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
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
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
          if (result == true) _loadNotes();
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add), // ✅ child al final
        tooltip: 'Agregar nota',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}