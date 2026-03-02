import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/note_provider.dart';
import '../models/tag.dart';

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

  // Obtener todas las etiquetas únicas de las notas
  List<String> _getAllTags(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final allTags = <String>{};
    
    for (var note in noteProvider.notes) {
      if (!note.isDeleted) {
        allTags.addAll(note.tags);
      }
    }
    
    final tagsList = allTags.toList()..sort();
    return ['Todas', ...tagsList];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final greeting = _getGreeting();
    final allTags = _getAllTags(context);
    final hasTags = allTags.length > 1; // Más de "Todas"

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
                  // Botón izquierdo
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
                  
                  // Título con estilo mejorado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                Colors.blue.shade900.withValues(alpha: 0.3),
                                Colors.purple.shade900.withValues(alpha: 0.3),
                              ]
                            : [
                                Colors.blue.shade50.withValues(alpha: 0.8),
                                Colors.purple.shade50.withValues(alpha: 0.8),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.blue.shade700.withValues(alpha: 0.3)
                            : Colors.blue.shade200.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(width: 8),
                        const Text(
                          'QuickNote',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 3,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.blue],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botones derecho
                  Row(
                    children: [
                      // Toggle de tema
                      _buildThemeToggle(themeProvider),
                      const SizedBox(width: 6),
                      
                      // Botón derecho
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
              
              // Mensaje de saludo centrado
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
              
              // Dropdown de etiquetas
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
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
                    color: isDarkMode
                        ? Colors.grey[600]!.withValues(alpha: 0.3)
                        : Colors.blue.shade200.withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                    dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    items: allTags.map((tag) {
                      final tagColor = tag != 'Todas' 
                          ? Tag.getColorForName(tag)
                          : (isDarkMode ? Colors.blue.shade200 : Colors.blue.shade700);
                      
                      return DropdownMenuItem<String>(
                        value: tag,
                        child: Row(
                          children: [
                            if (tag != 'Todas') ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: tagColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              tag == 'Todas' ? Icons.view_list : Icons.label,
                              size: 16,
                              color: tagColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: tag != 'Todas'
                                      ? tagColor
                                      : (isDarkMode ? Colors.grey[300] : Colors.grey[800]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onCategorySelected(value);
                      }
                    },
                  ),
                ),
              ),
              
              // Mensaje si no hay etiquetas
              if (!hasTags) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'No hay etiquetas disponibles',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
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
}