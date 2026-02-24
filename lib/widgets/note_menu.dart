import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart'; // ✅ Añadir provider
import '../providers/theme_provider.dart'; // ✅ Importar ThemeProvider

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

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
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
      begin: const Offset(0, 0.2),
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

  void _handleTap(VoidCallback action) {
    _animationController.reverse().then((_) {
      Navigator.pop(context);
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Obtener el estado del tema
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
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            Colors.grey[900]!.withValues(alpha: 0.7),
                            Colors.grey[800]!.withValues(alpha: 0.6),
                            Colors.grey[900]!.withValues(alpha: 0.7),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.7),
                            Colors.blue.shade50.withValues(alpha: 0.6),
                            Colors.white.withValues(alpha: 0.7),
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.grey[600]!.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header con efecto vidrio más pronunciado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: isDarkMode
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[800]!.withValues(alpha: 0.9),
                                  Colors.grey[850]!.withValues(alpha: 0.9),
                                  Colors.grey[900]!.withValues(alpha: 0.9),
                                ],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade400.withValues(alpha: 0.9),
                                  Colors.blue.shade600.withValues(alpha: 0.9),
                                  Colors.blue.shade800.withValues(alpha: 0.9),
                                ],
                              ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: isDarkMode
                                ? Colors.grey[400]!.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[600]!.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.menu,
                              color: isDarkMode ? Colors.blue.shade200 : Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Opciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.blue.shade200 : Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de opciones
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _buildAnimatedMenuItem(
                            icon: Icons.view_list,
                            label: 'Vista de lista',
                            index: 0,
                            color: Colors.blue,
                            onTap: () => _handleTap(widget.onViewList),
                            isDarkMode: isDarkMode,
                          ),
                          _buildAnimatedMenuItem(
                            icon: Icons.check_box,
                            label: 'Seleccionar',
                            index: 1,
                            color: Colors.green,
                            onTap: () => _handleTap(widget.onSelect),
                            isDarkMode: isDarkMode,
                          ),
                          _buildAnimatedMenuItem(
                            icon: Icons.sort,
                            label: 'Ordenar',
                            index: 2,
                            color: Colors.orange,
                            onTap: () => _handleTap(widget.onSort),
                            isDarkMode: isDarkMode,
                          ),
                          _buildAnimatedMenuItem(
                            icon: Icons.sync,
                            label: 'Sincronizar',
                            index: 3,
                            color: Colors.purple,
                            onTap: () => _handleTap(widget.onSync),
                            isDarkMode: isDarkMode,
                          ),
                          _buildAnimatedMenuItem(
                            icon: Icons.import_export,
                            label: 'Importar',
                            index: 4,
                            color: Colors.teal,
                            onTap: () => _handleTap(widget.onImport),
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

  Widget _buildAnimatedMenuItem({
    required IconData icon,
    required String label,
    required int index,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.1 + (index * 0.05),
          0.4 + (index * 0.05),
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: itemAnimation.value,
          child: Transform.translate(
            offset: Offset(30 * (1 - itemAnimation.value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Colors.grey[800]!.withValues(alpha: 0.8),
                    Colors.grey[800]!.withValues(alpha: 0.9),
                    color.withValues(alpha: 0.15),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.9),
                    color.withValues(alpha: 0.15),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? Colors.grey[600]!.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? color.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
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
                  // Icono con efecto vidrio
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
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
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  
                  // Toggle vidrioso mejorado
                  Container(
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: isDarkMode ? 0.3 : 0.4),
                          color.withValues(alpha: isDarkMode ? 0.15 : 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: color.withValues(alpha: isDarkMode ? 0.4 : 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: isDarkMode ? 0.2 : 0.3),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Puntos decorativos
                        Positioned(
                          left: 4,
                          top: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        
                        // Círculo central con efecto vidrioso
                        Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  color,
                                  color.withValues(alpha: 0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
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
  }
}