import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/note_provider.dart';
import '../utils/snackbar_utils.dart';

class NoteMenu extends StatefulWidget {
  final VoidCallback onViewList;
  final VoidCallback onSelect;
  final VoidCallback onSort;
  final VoidCallback onSync;
  final VoidCallback onImport;

  const NoteMenu({
    super.key,
    required this.onViewList,
    required this.onSelect,
    required this.onSort,
    required this.onSync,
    required this.onImport,
  });

  @override
  State<NoteMenu> createState() => _NoteMenuState();
}

class _NoteMenuState extends State<NoteMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<int, Animation<double>> _itemAnimations = {};

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Animation<double> _getItemAnimation(int index) {
    if (!_itemAnimations.containsKey(index)) {
      _itemAnimations[index] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.1 + (index * 0.05),
            0.4 + (index * 0.05),
            curve: Curves.easeOut,
          ),
        ),
      );
    }
    return _itemAnimations[index]!;
  }

  void _handleTap(VoidCallback action) {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
        action();
      }
    });
  }

  Future<void> _handleSelectMultiple() async {
    _animationController.reverse().then((_) async {
      if (!mounted) return;
      
      Navigator.pop(context);
      
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      if (noteProvider.notes.isEmpty) {
        SnackbarUtils.showInfoSnackbar(
          context,
          'No hay notas para seleccionar',
        );
        return;
      }
      
      _showMultiSelectDialog(noteProvider);
    });
  }

  Future<void> _showMultiSelectDialog(NoteProvider noteProvider) async {
    final List<bool> selected = List.generate(noteProvider.notes.length, (index) => false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final selectedCount = selected.where((s) => s).length;
            
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.grey[50]!.withValues(alpha: 0.8),
                                ],
                        ),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[600]!.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade700,
                                  Colors.purple.shade700,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.checklist,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Seleccionar notas',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$selectedCount seleccionadas',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                          
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: noteProvider.notes.length,
                              itemBuilder: (context, index) {
                                final note = noteProvider.notes[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: selected[index]
                                        ? Colors.blue.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: selected[index]
                                          ? Colors.blue
                                          : Colors.grey.withValues(alpha: 0.2),
                                      width: selected[index] ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: selected[index],
                                      onChanged: (value) {
                                        setState(() {
                                          selected[index] = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    title: Text(
                                      note.title,
                                      style: TextStyle(
                                        fontWeight: selected[index] 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(
                                      note.content.length > 50
                                          ? '${note.content.substring(0, 47)}...'
                                          : note.content,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selected[index] = !selected[index];
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: selectedCount == noteProvider.notes.length
                                        ? () {
                                            setState(() {
                                              for (int i = 0; i < selected.length; i++) {
                                                selected[i] = false;
                                              }
                                            });
                                          }
                                        : () {
                                            setState(() {
                                              for (int i = 0; i < selected.length; i++) {
                                                selected[i] = true;
                                              }
                                            });
                                          },
                                    icon: Icon(
                                      selectedCount == noteProvider.notes.length
                                          ? Icons.deselect
                                          : Icons.select_all,
                                      size: 18,
                                    ),
                                    label: Text(
                                      selectedCount == noteProvider.notes.length
                                          ? 'Deseleccionar todo'
                                          : 'Seleccionar todo',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: selectedCount == 0
                                        ? null
                                        : () => _confirmDeleteSelected(
                                            context,
                                            noteProvider,
                                            selected,
                                          ),
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: Text('Eliminar ($selectedCount)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    NoteProvider noteProvider,
    List<bool> selected,
  ) async {
    final selectedNotes = noteProvider.notes
        .asMap()
        .entries
        .where((entry) => selected[entry.key])
        .map((entry) => entry.value)
        .toList();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Se eliminarán ${selectedNotes.length} nota${selectedNotes.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '¿Estás seguro de continuar?',
              style: TextStyle(fontSize: 14),
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
    );

    if (confirm == true) {
      Navigator.pop(context);
      
      int successCount = 0;
      
      for (var note in selectedNotes) {
        try {
          await noteProvider.deleteNote(note.id);
          successCount++;
        } catch (e) {
          // Silencioso
        }
      }
      
      if (successCount > 0 && mounted) {
        _showSuccessDialog(successCount);
      }
    }
  }

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡$count nota${count > 1 ? 's' : ''} eliminada${count > 1 ? 's' : ''}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Las notas han sido eliminadas exitosamente',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.blue.withValues(alpha: 0.15)
                    : Colors.blue.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            Colors.grey[900]!.withValues(alpha: 0.6),
                            Colors.grey[800]!.withValues(alpha: 0.5),
                            Colors.grey[900]!.withValues(alpha: 0.6),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.6),
                            Colors.blue.shade50.withValues(alpha: 0.5),
                            Colors.white.withValues(alpha: 0.6),
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey[600]!.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [
                                  Colors.blue.shade900.withValues(alpha: 0.8),
                                  Colors.purple.shade900.withValues(alpha: 0.7),
                                  Colors.grey[900]!.withValues(alpha: 0.6),
                                ]
                              : [
                                  Colors.blue.shade700.withValues(alpha: 0.8),
                                  Colors.purple.shade700.withValues(alpha: 0.7),
                                  Colors.blue.shade900.withValues(alpha: 0.6),
                                ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(35),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: isDarkMode
                                ? Colors.grey[400]!.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Opciones de notas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.view_list,
                            label: 'Vista de lista',
                            index: 0,
                            color: Colors.blue.shade400,
                            onTap: () => _handleTap(widget.onViewList),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 8),
                          _buildMenuItem(
                            icon: Icons.check_box,
                            label: 'Seleccionar',
                            index: 1,
                            color: Colors.green.shade400,
                            onTap: _handleSelectMultiple,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 8),
                          _buildMenuItem(
                            icon: Icons.sort,
                            label: 'Ordenar',
                            index: 2,
                            color: Colors.orange.shade400,
                            onTap: () => _handleTap(widget.onSort),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 8),
                          _buildMenuItem(
                            icon: Icons.sync,
                            label: 'Sincronizar',
                            index: 3,
                            color: Colors.purple.shade400,
                            onTap: () => _handleTap(widget.onSync),
                            isDarkMode: isDarkMode,
                          ),
                        ],
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

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final itemAnimation = _getItemAnimation(index).value;
        
        return Opacity(
          opacity: itemAnimation,
          child: Transform.translate(
            offset: Offset(20 * (1 - itemAnimation), 0),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Colors.grey[800]!.withValues(alpha: 0.6),
                    Colors.grey[850]!.withValues(alpha: 0.5),
                    color.withValues(alpha: 0.1),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.6),
                    Colors.grey[50]!.withValues(alpha: 0.5),
                    color.withValues(alpha: 0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? color.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDarkMode ? 0.1 : 0.15),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: color.withValues(alpha: 0.15),
            highlightColor: color.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isDarkMode ? color.withValues(alpha: 0.9) : color,
                      size: 22,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: color.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}