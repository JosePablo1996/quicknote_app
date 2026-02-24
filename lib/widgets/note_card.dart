import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 8,
        shadowColor: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
            border: Border.all(
              color: Colors.blue.shade100,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Decoración de fondo
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ),
              
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra de color lateral
                    Container(
                      width: 8,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Contenido de texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Contenido
                          Text(
                            note.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Fecha y acciones
                          Row(
                            children: [
                              // Icono de fecha
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(note.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const Spacer(),
                              // Botones de acción
                              _buildActionButton(
                                icon: Icons.edit,
                                color: Colors.blue,
                                onTap: onEdit,
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                icon: Icons.delete,
                                color: Colors.red,
                                onTap: onDelete,
                              ),
                            ],
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
    );
  }

  // Widget para botones de acción circulares
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  // Formatear fecha
  String _formatDate(String date) {
    if (date.length >= 10) {
      final parts = date.substring(0, 10).split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}'; // DD/MM/YYYY
      }
    }
    return date;
  }
}