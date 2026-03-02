// lib/widgets/tag_chip.dart (actualizado)

import 'package:flutter/material.dart';
import '../models/tag.dart';

class TagChip extends StatelessWidget {
  final String tagName;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool showIcon;
  final double fontSize;
  final double opacity; // NUEVA PROPIEDAD

  const TagChip({
    super.key,
    required this.tagName,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    this.showIcon = true,
    this.fontSize = 12.0,
    this.opacity = 1.0, // Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tagColor = Tag.getColorForName(tagName);
    final iconData = Tag.getIconForName(tagName);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: EdgeInsets.only(
          left: 12,
          right: onDelete != null ? 4 : 12,
          top: 6,
          bottom: 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [tagColor, tagColor.withValues(alpha: 0.8)]
                : [
                    tagColor.withValues(alpha: isDarkMode ? 0.2 * opacity : 0.1 * opacity),
                    tagColor.withValues(alpha: isDarkMode ? 0.15 * opacity : 0.05 * opacity),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : tagColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tagColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon && iconData != null) ...[
              Icon(
                iconData,
                size: fontSize + 2,
                color: isSelected ? Colors.white : tagColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              tagName,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : tagColor,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: fontSize,
                    color: isSelected ? Colors.white : tagColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}