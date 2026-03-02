// lib/models/tag.dart

import 'package:flutter/material.dart';

class Tag {
  final String name;
  final Color color;
  final int? noteCount;

  Tag({
    required this.name,
    required this.color,
    this.noteCount,
  });

  // Colores predefinidos para tipos comunes
  static final Map<String, Color> defaultColors = {
    'personal': Colors.blue,
    'trabajo': Colors.orange,
    'estudio': Colors.green,
    'compras': Colors.purple,
    'ideas': Colors.amber,
    'proyecto': Colors.teal,
    'urgente': Colors.red,
    'salud': Colors.pink,
    'viajes': Colors.indigo,
    'hogar': Colors.brown,
    'tecnología': Colors.cyan,
    'finanzas': Colors.lightGreen,
    'deportes': Colors.lime,
    'música': Colors.deepPurple,
    'lectura': Colors.blueGrey,
  };

  // Obtener color basado en el nombre (para etiquetas nuevas)
  static Color getColorForName(String name) {
    // Buscar en colores predefinidos
    final lowerName = name.toLowerCase();
    if (defaultColors.containsKey(lowerName)) {
      return defaultColors[lowerName]!;
    }
    
    // Si no está predefinido, generar color basado en el hash del nombre
    final hash = name.hashCode.abs();
    final colorIndex = hash % Colors.primaries.length;
    return Colors.primaries[colorIndex];
  }

  // Obtener icono sugerido basado en el nombre
  static IconData? getIconForName(String name) {
    switch (name.toLowerCase()) {
      case 'personal':
        return Icons.person;
      case 'trabajo':
        return Icons.work;
      case 'estudio':
        return Icons.school;
      case 'compras':
        return Icons.shopping_cart;
      case 'ideas':
        return Icons.lightbulb;
      case 'proyecto':
        return Icons.assignment;
      case 'urgente':
        return Icons.warning;
      case 'salud':
        return Icons.favorite;
      case 'viajes':
        return Icons.flight;
      case 'hogar':
        return Icons.home;
      case 'tecnología':
        return Icons.computer;
      case 'finanzas':
        return Icons.attach_money;
      case 'deportes':
        return Icons.sports;
      case 'música':
        return Icons.music_note;
      case 'lectura':
        return Icons.book;
      default:
        return null;
    }
  }
}