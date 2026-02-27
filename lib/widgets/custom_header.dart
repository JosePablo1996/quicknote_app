import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomHeader extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final VoidCallback onLeftMenuTap;
  final VoidCallback onRightMenuTap;

  const CustomHeader({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onLeftMenuTap,
    required this.onRightMenuTap,
  });

  // Obtener saludo según la hora del día
  Map<String, dynamic> _getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return {
        'message': '¡Buenos días!',
        'icon': Icons.wb_sunny,
        'color': Colors.amber,
      };
    } else if (hour >= 12 && hour < 19) {
      return {
        'message': '¡Buenas tardes!',
        'icon': Icons.sunny,
        'color': Colors.orange,
      };
    } else {
      return {
        'message': '¡Buenas noches!',
        'icon': Icons.nights_stay,
        'color': Colors.indigo,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.grey[900]!,
                  Colors.grey[850]!,
                ]
              : [
                  Colors.white,
                  Colors.blue.shade50,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.blue.shade200)
                .withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior con botones y título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón izquierdo más pequeño
                  GestureDetector(
                    onTap: onLeftMenuTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  Colors.grey[800]!.withValues(alpha: 0.5),
                                  Colors.grey[700]!.withValues(alpha: 0.3),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.7),
                                  Colors.grey[50]!.withValues(alpha: 0.5),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[600]!.withValues(alpha: 0.3)
                              : Colors.blue.shade200.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.menu,
                        color: isDarkMode
                            ? Colors.blue.shade200
                            : Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  // Título centrado
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'QuickNote',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: isDarkMode
                                  ? [Colors.blue.shade200, Colors.purple.shade200]
                                  : [Colors.blue.shade700, Colors.purple.shade700],
                            ).createShader(const Rect.fromLTWH(0, 0, 150, 50)),
                        ),
                      ),
                    ],
                  ),
                  
                  // Botones derecho
                  Row(
                    children: [
                      // Toggle de tema
                      _buildThemeToggle(themeProvider),
                      const SizedBox(width: 6),
                      
                      // Botón derecho más pequeño
                      GestureDetector(
                        onTap: onRightMenuTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? [
                                      Colors.grey[800]!.withValues(alpha: 0.5),
                                      Colors.grey[700]!.withValues(alpha: 0.3),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.7),
                                      Colors.grey[50]!.withValues(alpha: 0.5),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[600]!.withValues(alpha: 0.3)
                                  : Colors.purple.shade200.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            Icons.more_vert,
                            color: isDarkMode
                                ? Colors.purple.shade200
                                : Colors.purple.shade700,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Mensaje de saludo centrado debajo del nombre
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: greeting['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: greeting['color'].withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        greeting['icon'],
                        color: greeting['color'],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        greeting['message'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Chips de categorías con iconos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryChip(
                    label: 'Todas',
                    icon: Icons.view_list,
                    isSelected: selectedCategory == 'Todas',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  _buildCategoryChip(
                    label: 'Personal',
                    icon: Icons.person,
                    isSelected: selectedCategory == 'Personal',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  _buildCategoryChip(
                    label: 'Trabajo',
                    icon: Icons.work,
                    isSelected: selectedCategory == 'Trabajo',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.indigo.shade800, Colors.purple.shade800]
                : [Colors.orange.shade400, Colors.amber.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isDarkMode
                      ? const Icon(
                          Icons.nights_stay,
                          key: ValueKey('dark'),
                          size: 12,
                          color: Colors.indigo,
                        )
                      : const Icon(
                          Icons.wb_sunny,
                          key: ValueKey('light'),
                          size: 12,
                          color: Colors.orange,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: () => onCategorySelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          Colors.grey[800]!.withValues(alpha: 0.5),
                          Colors.grey[700]!.withValues(alpha: 0.3),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.7),
                          Colors.grey[50]!.withValues(alpha: 0.5),
                        ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : (isDarkMode 
                    ? Colors.grey[600]!.withValues(alpha: 0.3)
                    : Colors.blue.shade200.withValues(alpha: 0.3)),
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}