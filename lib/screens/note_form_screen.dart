import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../utils/snackbar_utils.dart';

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
  String? _reminder;
  String? _category;
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
    
    // Si es una nota existente, cargar sus propiedades
    if (widget.note != null) {
      _isFavorite = widget.note?.isFavorite ?? false;
      _tags = widget.note?.tags ?? [];
    }
    
    // Animación para efecto glass
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
      if (widget.note == null) {
        // Crear nueva nota
        await _apiService.createNote(
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
        if (mounted) {
          // Usar Snackbar sin parámetro duration
          SnackbarUtils.showSuccessSnackbar(
            context, 
            'Nota creada exitosamente',
          );
        }
      } else {
        // Actualizar nota existente
        await _apiService.updateNote(
          widget.note!.id,
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
        if (mounted) {
          SnackbarUtils.showInfoSnackbar(
            context, 
            'Nota actualizada exitosamente',
          );
        }
      }
      
      // Pequeña pausa para mostrar el Snackbar antes de cerrar
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

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador superior
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Añadir etiquetas
            _buildModernMenuItem(
              icon: Icons.label_outline,
              title: 'Añadir etiquetas',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _showTagsDialog();
              },
            ),
            
            // Exportar a PDF
            _buildModernMenuItem(
              icon: Icons.picture_as_pdf,
              title: 'Exportar a PDF',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showShareDialog();
              },
            ),
            
            // Buscar
            _buildModernMenuItem(
              icon: Icons.search,
              title: 'Buscar',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                SnackbarUtils.showInfoSnackbar(
                  context, 
                  'Funcionalidad próximamente',
                );
              },
            ),
            
            // Detalles de la nota
            _buildModernMenuItem(
              icon: Icons.info_outline,
              title: 'Detalles de la nota',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                _showNoteDetails();
              },
            ),
            
            // Añadir a favoritos
            _buildModernMenuItem(
              icon: _isFavorite ? Icons.star : Icons.star_border,
              title: _isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
              color: Colors.amber,
              onTap: () {
                setState(() => _isFavorite = !_isFavorite);
                Navigator.pop(context);
                SnackbarUtils.showSuccessSnackbar(
                  context,
                  _isFavorite ? 'Añadida a favoritos' : 'Eliminada de favoritos',
                );
              },
            ),
            
            // Archivar
            _buildModernMenuItem(
              icon: Icons.archive_outlined,
              title: 'Archivar',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(context);
                SnackbarUtils.showInfoSnackbar(
                  context, 
                  'Nota archivada',
                );
              },
            ),
            
            const Divider(height: 1),
            
            // Eliminar
            _buildModernMenuItem(
              icon: Icons.delete_outline,
              title: 'Eliminar',
              color: Colors.red,
              showArrow: false,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete();
              },
            ),
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: showArrow 
            ? Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Compartir como',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildShareOption(
              icon: Icons.image,
              label: 'Imagen',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                SnackbarUtils.showInfoSnackbar(
                  context, 
                  'Compartir como imagen',
                );
              },
            ),
            _buildShareOption(
              icon: Icons.picture_as_pdf,
              label: 'PDF',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                SnackbarUtils.showInfoSnackbar(
                  context, 
                  'Compartir como PDF',
                );
              },
            ),
            _buildShareOption(
              icon: Icons.text_fields,
              label: 'Solo texto',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                SnackbarUtils.showInfoSnackbar(
                  context, 
                  'Compartir como texto',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
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
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showTagsDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir etiquetas'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tagController,
              decoration: InputDecoration(
                hintText: 'Nombre de la etiqueta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: _selectedColor.withValues(alpha: 0.1),
                  deleteIconColor: _selectedColor,
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )).toList(),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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

  void _showNoteDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de la nota'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Creada', widget.note?.createdAt ?? 'Ahora'),
            if (widget.note?.updatedAt != null)
              _buildDetailRow('Actualizada', widget.note!.updatedAt!),
            _buildDetailRow('Tamaño', '${_contentController.text.length} caracteres'),
            _buildDetailRow('Palabras', _contentController.text.split(' ').length.toString()),
            const Divider(),
            _buildDetailRow('Color', _getColorName(_selectedColor)),
            _buildDetailRow('Etiquetas', _tags.isEmpty ? 'Sin etiquetas' : _tags.join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.blue) return 'Azul';
    if (color == Colors.red) return 'Rojo';
    if (color == Colors.green) return 'Verde';
    if (color == Colors.orange) return 'Naranja';
    if (color == Colors.purple) return 'Púrpura';
    if (color == Colors.teal) return 'Verde azulado';
    if (color == Colors.pink) return 'Rosa';
    if (color == Colors.indigo) return 'Índigo';
    return 'Personalizado';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('¿Estás seguro de que quieres eliminar esta nota?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
              SnackbarUtils.showSuccessSnackbar(
                context, 
                'Nota eliminada',
              );
            },
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
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar nota' : 'Nueva nota',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreMenu,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: _selectedColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Guardando nota...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Categoría
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sin categoría',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Título
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Título',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El título es requerido';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Fecha
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hoy, ${_formatTime(DateTime.now())}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Contenido
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Nota aquí',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
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
      bottomNavigationBar: AnimatedBuilder(
        animation: _glassAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  Colors.white.withValues(alpha: 0.9),
                  _selectedColor.withValues(alpha: 0.2),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: _selectedColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Paleta de colores
                  SizedBox(
                    height: 40,
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
                            // Mostrar confirmación rápida
                            SnackbarUtils.showInfoSnackbar(
                              context,
                              'Color aplicado',
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (_selectedColor == color)
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: _selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
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
                      _buildGlassActionButton(
                        icon: _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        label: 'Fijar',
                        isActive: _isPinned,
                        onTap: () {
                          setState(() => _isPinned = !_isPinned);
                          SnackbarUtils.showInfoSnackbar(
                            context,
                            _isPinned ? 'Nota fijada' : 'Nota no fijada',
                          );
                        },
                      ),
                      _buildGlassActionButton(
                        icon: Icons.alarm,
                        label: 'Recordatorio',
                        onTap: () {
                          SnackbarUtils.showInfoSnackbar(
                            context,
                            'Funcionalidad próximamente',
                          );
                        },
                      ),
                      _buildGlassActionButton(
                        icon: _isLocked ? Icons.lock : Icons.lock_outline,
                        label: 'Bloquear',
                        isActive: _isLocked,
                        onTap: () {
                          setState(() => _isLocked = !_isLocked);
                          SnackbarUtils.showInfoSnackbar(
                            context,
                            _isLocked ? 'Nota bloqueada' : 'Nota desbloqueada',
                          );
                        },
                      ),
                      _buildGlassActionButton(
                        icon: Icons.share,
                        label: 'Compartir',
                        onTap: _showShareDialog,
                      ),
                      _buildGlassActionButton(
                        icon: Icons.save,
                        label: 'Guardar',
                        isActive: true,
                        onTap: _saveNote,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isActive 
                  ? _selectedColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.5),
              isActive
                  ? _selectedColor.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? _selectedColor : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? _selectedColor : Colors.grey[600],
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'a. m.' : 'p. m.';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }
}