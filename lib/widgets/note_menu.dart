import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

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

  // Cache para evitar reconstrucciones innecesarias
  final Map<int, Animation<double>> _itemAnimations = {};

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Reducido de 500ms
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

  // Obtener animación de item con cache
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
    // Primero cerramos el diálogo con animación
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
        // Luego ejecutamos la acción después de cerrar el diálogo
        action();
      }
    });
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
          width: 320, // Un poco más ancho
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
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Reducido de 20
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
                    // Header mejorado
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
                            child: Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Opciones de notas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de opciones
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
                            onTap: () => _handleTap(widget.onSelect),
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
                  // Icono con efecto vidrio mejorado
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
                  
                  // Texto
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
                  
                  // Indicador visual mejorado
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