import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_notes_widget.dart';
import '../widgets/custom_header.dart';
import '../widgets/note_menu.dart';
import '../widgets/left_menu.dart';
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
  
  // Controlador para búsqueda
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  // Categoría seleccionada
  String _selectedCategory = 'Todas';
  
  // Controlador para el menú izquierdo
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

  void _showSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _hideSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  // Métodos para el menú derecho
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

  // Métodos para el menú izquierdo
  void _openLeftMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeLeftMenu() {
    Navigator.pop(context);
  }

  // Método para obtener color basado en el ID
  Color _getNoteColor(Note note) {
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      drawer: LeftMenu(onClose: _closeLeftMenu),
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado con dos menús
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
                // Mostrar el menú derecho como diálogo con efecto Liquid Glass
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierColor: Colors.black.withValues(alpha: 0.3),
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                    child: NoteMenu(
                      onViewList: () {
                        _onViewList();
                      },
                      onSelect: () {
                        _onSelect();
                      },
                      onSort: () {
                        _onSort();
                      },
                      onSync: () {
                        _onSync();
                      },
                      onImport: () {
                        _onImport();
                      },
                    ),
                  ),
                );
              },
            ),
            
            // Espacio
            const SizedBox(height: 8),
            
            // Lista de notas
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
                    // Estado de carga
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 3,
                        ),
                      );
                    }

                    // Estado de error
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
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
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
                    
                    // Estado vacío
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

                    // Filtrar por categoría (ejemplo - implementa según tu lógica)
                    final filteredNotes = _selectedCategory == 'Todas'
                        ? notes
                        : notes.where((note) {
                            // Aquí implementa el filtrado real según categoría
                            // Por ahora es un placeholder
                            return note.id % 2 == 0;
                          }).toList();

                    // Grid de notas
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
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
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    noteColor.withValues(alpha: 0.1),
                                    noteColor.withValues(alpha: 0.05),
                                    Colors.white,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: noteColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: noteColor.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Indicador de color superior
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            noteColor,
                                            noteColor.withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Contenido de la tarjeta
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Título
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
                                        
                                        const SizedBox(height: 8),
                                        
                                        // Contenido (extracto)
                                        Expanded(
                                          child: Text(
                                            note.content,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                              height: 1.3,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 8),
                                        
                                        // Fecha y acciones
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Fecha
                                            Text(
                                              _formatDate(note.createdAt),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                            
                                            // Botones de acción
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Botón editar
                                                GestureDetector(
                                                  onTap: () async {
                                                    final result = await Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder: (_, __, ___) => NoteFormScreen(note: note),
                                                        transitionsBuilder: (_, animation, __, child) {
                                                          return SlideTransition(
                                                            position: Tween<Offset>(
                                                              begin: const Offset(1, 0),
                                                              end: Offset.zero,
                                                            ).animate(animation),
                                                            child: child,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                    if (result == true) _loadNotes();
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: noteColor.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: noteColor,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                                
                                                const SizedBox(width: 8),
                                                
                                                // Botón eliminar
                                                GestureDetector(
                                                  onTap: () => _deleteNote(note),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Indicador de favorito
                                  if (note.isFavorite)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
        child: const Icon(Icons.add),
        tooltip: 'Agregar nota',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _formatDate(String date) {
    try {
      if (date.length >= 10) {
        final parts = date.substring(0, 10).split('-');
        if (parts.length == 3) {
          final day = parts[2];
          final month = parts[1];
          return '$day/$month';
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}