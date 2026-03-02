// lib/widgets/tag_cloud.dart

import 'package:flutter/material.dart';
import 'tag_chip.dart'; // Solo necesitamos importar tag_chip

class TagCloud extends StatelessWidget {
  final List<String> tags;
  final Map<String, int>? tagCounts;
  final Function(String)? onTagTap;
  final Function(String)? onTagDelete;
  final String? selectedTag;

  const TagCloud({
    super.key,
    required this.tags,
    this.tagCounts,
    this.onTagTap,
    this.onTagDelete,
    this.selectedTag,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.label_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No hay etiquetas',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: tags.map((tag) {
        // Calcular tamaño basado en cantidad de notas (si hay datos)
        double fontSize = 14.0; // Valor por defecto como double
        
        if (tagCounts != null && tagCounts!.containsKey(tag)) {
          final count = tagCounts![tag]!;
          // Asegurar que el resultado sea double
          fontSize = (12 + (count * 2)).clamp(12.0, 24.0).toDouble();
        }

        // Determinar opacidad basada en frecuencia (opcional)
        double opacity = 1.0;
        if (tagCounts != null && tagCounts!.containsKey(tag)) {
          final maxCount = tagCounts!.values.isNotEmpty 
              ? tagCounts!.values.reduce((a, b) => a > b ? a : b).toDouble()
              : 1.0;
          final count = tagCounts![tag]!.toDouble();
          opacity = (0.5 + (count / maxCount * 0.5)).clamp(0.5, 1.0);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: TagChip(
            tagName: tagCounts != null 
                ? '$tag (${tagCounts![tag]})' 
                : tag,
            onTap: onTagTap != null ? () => onTagTap!(tag) : null,
            onDelete: onTagDelete != null ? () => onTagDelete!(tag) : null,
            isSelected: selectedTag == tag,
            fontSize: fontSize,
            opacity: opacity,
          ),
        );
      }).toList(),
    );
  }
}