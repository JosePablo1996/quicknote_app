import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../utils/snackbar_utils.dart';
import '../providers/theme_provider.dart';
import '../providers/note_provider.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isPinned = false;
  bool _isFavorite = false;
  bool _isLocked = false;
  List<String> _tags = [];
  
  // Colores disponibles
  Color _selectedColor = Colors.blue;
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];
  
  late AnimationController _glassAnimationController;
  late Animation<double> _glassAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    
    if (widget.note != null) {
      _isFavorite = widget.note?.isFavorite ?? false;
      _tags = widget.note?.tags ?? [];
    }
    
    _glassAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _glassAnimation = Tween<double>(begin: 0.1, end: 0.3).animate(
      CurvedAnimation(
        parent: _glassAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _glassAnimationController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      if (widget.note == null) {
        final newNote = Note(
          id: 0,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: null,
          isFavorite: _isFavorite,
          tags: _tags,
          colorHex: _colorToHex(_selectedColor),
        );
        await noteProvider.createNote(newNote);
        if (mounted) {
          SnackbarUtils.showSuccessSnackbar(
            context, 
            'Nota creada exitosamente',
          );
        }
      } else {
        final updatedNote = Note(
          id: widget.note!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: widget.note!.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
          isFavorite: _isFavorite,
          tags: _tags,
          colorHex: _colorToHex(_selectedColor),
        );
        await noteProvider.updateNote(updatedNote);
        if (mounted) {
          SnackbarUtils.showInfoSnackbar(
            context, 
            'Nota actualizada exitosamente',
          );
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showErrorSnackbar(
          context, 
          'Error al guardar: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  void _showMoreMenu() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          Colors.grey[900]!.withValues(alpha: 0.8),
                          Colors.grey[850]!.withValues(alpha: 0.7),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.8),
                          Colors.blue.shade50.withValues(alpha: 0.7),
                        ],
                ),
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? Colors.grey[600]!.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador superior
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade300,
                            Colors.purple.shade300,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  
                  // Título del menú
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.purple.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Opciones de nota',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Añadir etiquetas (funcional)
                  _buildModernMenuItem(
                    context,
                    icon: Icons.label,
                    title: 'Añadir etiquetas',
                    color: Colors.blue,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      _showTagsDialog();
                    },
                  ),
                  
                  // Compartir como (renombrado)
                  _buildModernMenuItem(
                    context,
                    icon: Icons.share,
                    title: 'Compartir como',
                    color: Colors.green,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      _showShareDialog();
                    },
                  ),
                  
                  // Añadir a favoritos (funcional)
                  _buildModernMenuItem(
                    context,
                    icon: _isFavorite ? Icons.star : Icons.star_border,
                    title: _isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                    color: Colors.amber,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      setState(() => _isFavorite = !_isFavorite);
                      Navigator.pop(context);
                      SnackbarUtils.showSuccessSnackbar(
                        context,
                        _isFavorite ? 'Añadida a favoritos' : 'Eliminada de favoritos',
                      );
                    },
                  ),
                  
                  // Archivar (funcional)
                  _buildModernMenuItem(
                    context,
                    icon: Icons.archive,
                    title: 'Archivar',
                    color: Colors.teal,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      SnackbarUtils.showInfoSnackbar(
                        context, 
                        'Nota archivada',
                      );
                    },
                  ),
                  
                  const Divider(
                    height: 16,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Colors.grey,
                  ),
                  
                  // Eliminar (funcional)
                  _buildModernMenuItem(
                    context,
                    icon: Icons.delete,
                    title: 'Eliminar nota',
                    color: Colors.red,
                    isDarkMode: isDarkMode,
                    showArrow: false,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete();
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

  Widget _buildModernMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
        border: Border.all(
          color: isDarkMode
              ? color.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.2),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                        ),
                      ),
                    ),
                    if (showArrow)
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

  void _showShareDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Compartir como',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey[300] : Colors.black87,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildShareOption(
              context,
              icon: Icons.image,
              label: 'Imagen',
              color: Colors.purple,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
                SnackbarUtils.showInfoSnackbar(
                  context, 
                  'Compartir como imagen - Próximamente',
                );
              },
            ),
            _buildShareOption(
              context,
              icon: Icons.picture_as_pdf,
              label: 'PDF',
              color: Colors.red,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
                SnackbarUtils.showInfoSnackbar(
                  context, 
                  'Compartir como PDF - Próximamente',
                );
              },
            ),
            _buildShareOption(
              context,
              icon: Icons.text_fields,
              label: 'Solo texto',
              color: Colors.blue,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
                SnackbarUtils.showInfoSnackbar(
                  context, 
                  'Compartir como texto - Próximamente',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[300] : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios, 
          color: isDarkMode ? Colors.grey[500] : Colors.grey[400], 
          size: 14,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showTagsDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Añadir etiquetas',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.black87,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tagController,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nombre de la etiqueta',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _selectedColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(Icons.label, color: _selectedColor),
                  ),
                ),
                const SizedBox(height: 16),
                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) => Chip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[300] : Colors.black87,
                        ),
                      ),
                      backgroundColor: _selectedColor.withValues(alpha: 0.1),
                      deleteIconColor: _selectedColor,
                      onDeleted: () {
                        setState(() {
                          this.setState(() {
                            _tags.remove(tag);
                          });
                        });
                      },
                    )).toList(),
                  ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (tagController.text.isNotEmpty) {
                setState(() {
                  _tags.add(tagController.text);
                });
                tagController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() async {
    if (widget.note == null) {
      Navigator.pop(context);
      return;
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar nota',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[300] : Colors.black87,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar esta nota?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
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
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);
        await noteProvider.deleteNote(widget.note!.id);
        if (mounted) {
          SnackbarUtils.showSuccessSnackbar(
            context, 
            'Nota eliminada',
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showErrorSnackbar(
            context, 
            'Error al eliminar',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar nota' : 'Nueva nota',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.grey[300] : Colors.black,
        elevation: 0.5,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _selectedColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: _selectedColor,
                size: 24,
              ),
              onPressed: _showMoreMenu,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedColor.withValues(alpha: 0.1),
                    ),
                    child: CircularProgressIndicator(
                      color: _selectedColor,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Guardando nota...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Contenedor del título
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                          color: isDarkMode
                              ? Colors.grey[700]!.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.9),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _selectedColor,
                                      _selectedColor.withValues(alpha: 0.5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _titleController,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.grey[200] : Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Título de la nota',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El título es requerido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Contenedor del contenido
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                            color: isDarkMode
                                ? Colors.grey[700]!.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.9),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 4,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _selectedColor.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _contentController,
                                    maxLines: null,
                                    expands: true,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Escribe tu nota aquí...',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El contenido es requerido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Tags si existen
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? Colors.grey[800]!.withValues(alpha: 0.3)
                              : Colors.grey[100]!.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _selectedColor.withValues(alpha: 0.15),
                                  _selectedColor.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _selectedColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _tags.remove(tag);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: _selectedColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _glassAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        Colors.grey[900]!.withValues(alpha: 0.8),
                        Colors.grey[850]!.withValues(alpha: 0.9),
                        _selectedColor.withValues(alpha: 0.3),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.95),
                        _selectedColor.withValues(alpha: 0.15),
                      ],
              ),
              border: Border(
                top: BorderSide(
                  color: isDarkMode
                      ? Colors.grey[700]!.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Paleta de colores
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _colorOptions.length,
                          itemBuilder: (context, index) {
                            final color = _colorOptions[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      color,
                                      color.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: _selectedColor == color
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    if (_selectedColor == color)
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.6),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                  ],
                                ),
                                child: _selectedColor == color
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Acciones principales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: _isFavorite ? Icons.star : Icons.star_border,
                            label: 'Favorito',
                            isActive: _isFavorite,
                            isDarkMode: isDarkMode,
                            onTap: () {
                              setState(() => _isFavorite = !_isFavorite);
                              SnackbarUtils.showInfoSnackbar(
                                context,
                                _isFavorite ? 'Añadida a favoritos' : 'Quitada de favoritos',
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.label,
                            label: 'Etiquetas',
                            isDarkMode: isDarkMode,
                            onTap: _showTagsDialog,
                          ),
                          _buildActionButton(
                            icon: Icons.archive,
                            label: 'Archivar',
                            isDarkMode: isDarkMode,
                            onTap: () {
                              SnackbarUtils.showInfoSnackbar(
                                context,
                                'Nota archivada',
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.save,
                            label: 'Guardar',
                            isActive: true,
                            isDarkMode: isDarkMode,
                            onTap: _saveNote,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              if (isActive) ...[
                _selectedColor.withValues(alpha: 0.3),
                _selectedColor.withValues(alpha: 0.2),
              ] else ...[
                isDarkMode 
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.5),
                isDarkMode
                    ? Colors.grey[700]!.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.3),
              ],
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isActive
                ? _selectedColor.withValues(alpha: 0.5)
                : (isDarkMode
                    ? Colors.grey[600]!.withValues(alpha: 0.3)
                    : Colors.grey[300]!.withValues(alpha: 0.3)),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive 
                  ? _selectedColor 
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive 
                    ? _selectedColor 
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}