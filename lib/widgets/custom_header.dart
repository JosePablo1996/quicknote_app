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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                .withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: (isDarkMode ? Colors.purple.shade900 : Colors.blue.shade100)
                .withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón izquierdo con efecto glass
                  GestureDetector(
                    onTap: onLeftMenuTap,
                    child: Container(
                      padding: const EdgeInsets.all(10),
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
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[600]!.withValues(alpha: 0.3)
                              : Colors.blue.shade200.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.blue.withValues(alpha: 0.1)
                                : Colors.blue.shade200.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.menu,
                        color: isDarkMode
                            ? Colors.blue.shade200
                            : Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  // Título con estilo mejorado
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'QuickNote',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: isDarkMode
                                  ? [Colors.blue.shade200, Colors.purple.shade200]
                                  : [Colors.blue.shade700, Colors.purple.shade700],
                            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                        ),
                      ),
                    ],
                  ),
                  
                  // Botones derecho
                  Row(
                    children: [
                      // Toggle de tema mejorado
                      _buildAnimatedThemeToggle(themeProvider),
                      const SizedBox(width: 8),
                      
                      // Botón derecho con efecto glass
                      GestureDetector(
                        onTap: onRightMenuTap,
                        child: Container(
                          padding: const EdgeInsets.all(10),
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
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[600]!.withValues(alpha: 0.3)
                                  : Colors.blue.shade200.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.purple.withValues(alpha: 0.1)
                                    : Colors.purple.shade200.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.more_vert,
                            color: isDarkMode
                                ? Colors.purple.shade200
                                : Colors.purple.shade700,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Chips de categorías con estilo mejorado
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCategoryChip('Todas', selectedCategory == 'Todas', isDarkMode),
                  const SizedBox(width: 16),
                  _buildCategoryChip('Personal', selectedCategory == 'Personal', isDarkMode),
                  const SizedBox(width: 16),
                  _buildCategoryChip('Trabajo', selectedCategory == 'Trabajo', isDarkMode),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedThemeToggle(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;
    
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 60,
        height: 34,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.indigo.shade800, Colors.purple.shade800]
                : [Colors.orange.shade400, Colors.amber.shade600],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.purple : Colors.orange)
                  .withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Efecto de brillo
            Positioned(
              left: isDarkMode ? 35 : 5,
              top: 5,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(5),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationTransition(
                      turns: animation,
                      child: ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                    );
                  },
                  child: isDarkMode
                      ? const Icon(
                          Icons.nights_stay,
                          key: ValueKey('dark'),
                          size: 16,
                          color: Colors.indigo,
                        )
                      : const Icon(
                          Icons.wb_sunny,
                          key: ValueKey('light'),
                          size: 16,
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

  Widget _buildCategoryChip(String label, bool isSelected, bool isDarkMode) {
    return GestureDetector(
      onTap: () => onCategorySelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 10,
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
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : (isDarkMode 
                    ? Colors.grey[600]!.withValues(alpha: 0.3)
                    : Colors.blue.shade200.withValues(alpha: 0.3)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}