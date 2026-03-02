// lib/screens/tags_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/tag.dart';
import '../providers/note_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/tag_cloud.dart';
import '../utils/snackbar_utils.dart';
import 'tag_notes_screen.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedView = 'lista'; // 'lista' o 'nube'
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Obtener todas las etiquetas con sus contadores
  Map<String, int> _getTagCounts(List<Note> notes) {
    final tagCounts = <String, int>{};
    for (var note in notes) {
      for (var tag in note.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    return tagCounts;
  }

  // Renombrar etiqueta en todas las notas
  Future<void> _renameTag(String oldName, String newName) async {
    if (oldName == newName || newName.trim().isEmpty) return;
    
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    int updatedCount = 0;

    for (var note in noteProvider.notes) {
      if (note.tags.contains(oldName)) {
        final newTags = note.tags.map((t) => t == oldName ? newName : t).toList();
        final updatedNote = note.copyWith(tags: newTags);
        await noteProvider.updateNote(updatedNote);
        updatedCount++;
      }
    }

    if (mounted) {
      SnackbarUtils.showSuccessSnackbar(
        context,
        '✅ Etiqueta renombrada: $oldName → $newName ($updatedCount notas)',
      );
      
      // Forzar recarga para actualizar la vista
      await noteProvider.loadNotes();
    }
  }

  // Eliminar etiqueta de todas las notas
  Future<void> _deleteTag(String tagName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar etiqueta'),
        content: Text('¿Eliminar la etiqueta "$tagName" de todas las notas?'),
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

    if (confirm != true) return;

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    int updatedCount = 0;

    for (var note in noteProvider.notes) {
      if (note.tags.contains(tagName)) {
        final newTags = note.tags.where((t) => t != tagName).toList();
        final updatedNote = note.copyWith(tags: newTags);
        await noteProvider.updateNote(updatedNote);
        updatedCount++;
      }
    }

    if (mounted) {
      SnackbarUtils.showSuccessSnackbar(
        context,
        '🗑️ Etiqueta "$tagName" eliminada de $updatedCount notas',
      );
      
      // Forzar recarga para actualizar la vista
      await noteProvider.loadNotes();
    }
  }

  // Navegar a la pantalla de notas con la etiqueta seleccionada
  void _navigateToTagNotes(String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagNotesScreen(tag: tag),
      ),
    );
  }

  // Diálogo para editar etiqueta (solo editar, no crear)
  Future<void> _showEditTagDialog(String existingTag) async {
    final TextEditingController _editController = TextEditingController(text: existingTag);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar etiqueta'),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(
            hintText: 'Nuevo nombre',
            border: const OutlineInputBorder(),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Tag.getColorForName(existingTag),
                radius: 12,
                child: Icon(
                  Tag.getIconForName(existingTag),
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final newName = _editController.text.trim();
      await _renameTag(existingTag, newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gestión de Etiquetas',
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
          IconButton(
            icon: Icon(
              _selectedView == 'lista' ? Icons.cloud : Icons.view_list,
            ),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 'lista' ? 'nube' : 'lista';
              });
            },
            tooltip: _selectedView == 'lista' ? 'Vista nube' : 'Vista lista',
          ),
        ],
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          final notes = noteProvider.notes.where((n) => !n.isDeleted).toList();
          final tagCounts = _getTagCounts(notes);
          final allTags = tagCounts.keys.toList()..sort();
          
          // Filtrar por búsqueda
          final filteredTags = allTags
              .where((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar etiquetas...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              const SizedBox(height: 8),

              // Estadísticas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '📊 ${filteredTags.length} etiqueta${filteredTags.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Mensaje informativo (opcional, para que el usuario sepa cómo crear etiquetas)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Las etiquetas se crean automáticamente al agregarlas a una nota desde el formulario.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Vista de etiquetas
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: filteredTags.isEmpty
                      ? _buildEmptyState(isDarkMode)
                      : _selectedView == 'lista'
                          ? _buildListView(filteredTags, tagCounts, isDarkMode)
                          : _buildCloudView(filteredTags, tagCounts, isDarkMode),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade400.withValues(alpha: 0.2),
                  Colors.blue.shade700.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.label_off,
              size: 80,
              color: isDarkMode ? Colors.purple.shade300 : Colors.purple.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay etiquetas',
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
              'Las etiquetas aparecerán aquí cuando las agregues a una nota desde el formulario de creación.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<String> tags, Map<String, int> tagCounts, bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final tagColor = Tag.getColorForName(tag);
        final iconData = Tag.getIconForName(tag);
        final noteCount = tagCounts[tag] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDarkMode ? Colors.grey[850]! : Colors.white,
                tagColor.withValues(alpha: 0.05),
                tagColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tagColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: tagColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    tagColor,
                    tagColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  iconData ?? Icons.label,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            title: Text(
              tag,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: tagColor,
              ),
            ),
            subtitle: Text(
              '$noteCount nota${noteCount != 1 ? 's' : ''}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: tagColor,
                    size: 20,
                  ),
                  onPressed: () => _showEditTagDialog(tag),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  onPressed: () => _deleteTag(tag),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: tagColor,
                  ),
                ),
              ],
            ),
            onTap: () => _navigateToTagNotes(tag),
          ),
        );
      },
    );
  }

  Widget _buildCloudView(List<String> tags, Map<String, int> tagCounts, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TagCloud(
        tags: tags,
        tagCounts: tagCounts,
        onTagTap: (tag) => _navigateToTagNotes(tag),
        onTagDelete: (tag) => _deleteTag(tag),
      ),
    );
  }
}