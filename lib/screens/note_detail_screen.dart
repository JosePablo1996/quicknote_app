import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/note.dart';
import '../models/tag.dart'; // 👈 IMPORTACIÓN AGREGADA
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'tag_notes_screen.dart'; // 👈 IMPORTACIÓN AGREGADA

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final noteColor = _getNoteColor(note);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detalle de Nota',
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
        // 👇 ACCIONES MEJORADAS: Indicadores de archivada y favorito
        actions: [
          if (note.isArchived)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.archive, color: Colors.teal, size: 16),
                  SizedBox(width: 4),
                  Text('Archivada', style: TextStyle(color: Colors.teal, fontSize: 12)),
                ],
              ),
            ),
          if (note.isFavorite)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.amber, size: 18),
            ),
        ],
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TARJETA PRINCIPAL (Título) =====
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          Colors.grey[850]!.withValues(alpha: 0.8),
                          Colors.grey[900]!.withValues(alpha: 0.6),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.grey[50]!.withValues(alpha: 0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey[700]!.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.9),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: noteColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar decorativo
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                noteColor,
                                noteColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: noteColor.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(note.title),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Título y metadata
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.grey[800],
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateTime(note.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
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

            // ===== TARJETA DE FECHAS =====
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
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
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey[700]!.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Fecha de creación
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Creada',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _formatDateOnly(note.createdAt),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Separador vertical
                        Container(
                          height: 30,
                          width: 1,
                          color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        
                        // Hora de creación
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.access_time,
                                  color: Colors.purple,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hora',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _formatTimeOnly(note.createdAt),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                      ),
                                    ),
                                  ],
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

            // ===== TARJETA DE ACTUALIZACIÓN (si existe) =====
            if (note.updatedAt != null && note.updatedAt != note.createdAt) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
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
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.update,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Última actualización',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _formatDateTime(note.updatedAt!),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
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
            ],

            // ===== TARJETA DE CONTENIDO =====
            Container(
              width: double.infinity,
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
                      ? Colors.grey[700]!.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header de contenido
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade400.withValues(alpha: 0.2),
                                    Colors.purple.shade400.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.purple.shade400.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.description,
                                color: Colors.purple.shade400,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Contenido',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.grey[200] : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Área de contenido
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.grey[800]!.withValues(alpha: 0.3)
                                : Colors.grey[100]!.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[700]!.withValues(alpha: 0.2)
                                  : Colors.grey[300]!.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            note.content.isEmpty ? 'Sin contenido' : note.content,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ),

                        // 👇 ETIQUETAS MEJORADAS con colores y navegación
                        if (note.tags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: note.tags.map((tag) {
                              final tagColor = Tag.getColorForName(tag);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TagNotesScreen(tag: tag),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tagColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: tagColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: tagColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Obtener iniciales del título
  String _getInitials(String title) {
    if (title.isEmpty) return '?';
    final words = title.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return title[0].toUpperCase();
  }

  // Obtener color de la nota
  Color _getNoteColor(Note note) {
    if (note.colorHex != null && note.colorHex!.isNotEmpty) {
      try {
        return Color(int.parse(note.colorHex!.replaceFirst('#', '0xff')));
      } catch (e) {
        final List<Color> colors = [
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal,
          Colors.pink,
          Colors.indigo,
        ];
        return colors[note.id % colors.length];
      }
    }
    
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[note.id % colors.length];
  }

  // Formatear fecha completa
  String _formatDateTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      
      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      if (dateTime.length >= 16) {
        return dateTime.substring(0, 16).replaceAll('T', ' ');
      }
      return dateTime;
    }
  }

  // Formatear solo fecha
  String _formatDateOnly(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day/$month/$year';
    } catch (e) {
      if (dateTime.length >= 10) {
        return dateTime.substring(0, 10);
      }
      return dateTime;
    }
  }

  // Formatear solo hora
  String _formatTimeOnly(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      if (dateTime.length >= 16) {
        return dateTime.substring(11, 16);
      }
      return '';
    }
  }
}