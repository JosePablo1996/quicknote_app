import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../widgets/note_card.dart';
import '../widgets/empty_notes_widget.dart';
import '../utils/snackbar_utils.dart'; // ✅ IMPORTAR SNACKBAR UTILS
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
  
  // Controlador para búsqueda (futura implementación)
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
          // ✅ SECCIÓN 1: Snackbar de éxito al eliminar
          SnackbarUtils.showSuccessSnackbar(
            context, 
            '"${note.title}" eliminada'
          );
        }
      } catch (e) {
        if (mounted) {
          // ✅ SECCIÓN 2: Snackbar de error al eliminar
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar notas...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: _hideSearch,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (query) {
                  // Aquí implementaremos búsqueda en tiempo real después
                },
              )
            : const Text(
                'QuickNote',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearch,
              tooltip: 'Buscar',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: RefreshIndicator(
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cargando tus notas...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
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
            
            // ESTADO VACÍO - usando nuestro nuevo widget
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

            // LISTA DE NOTAS
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
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
                  onEdit: () async {
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
                  onDelete: () => _deleteNote(note),
                );
              },
            );
          },
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
        child: const Icon(Icons.add),
        tooltip: 'Agregar nota',
      ),
    );
  }
}