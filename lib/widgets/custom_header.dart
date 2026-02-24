import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Menú izquierdo, título y menú derecho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menú hamburguesa (izquierda)
              GestureDetector(
                onTap: onLeftMenuTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ),
              
              // Título centrado
              const Text(
                'QuickNote',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              
              // Menú de 3 puntos (derecha)
              GestureDetector(
                onTap: onRightMenuTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Categorías
          Row(
            children: [
              _buildCategoryChip('Todas', selectedCategory == 'Todas'),
              const SizedBox(width: 12),
              _buildCategoryChip('Personal', selectedCategory == 'Personal'),
              const SizedBox(width: 12),
              _buildCategoryChip('Trabajo', selectedCategory == 'Trabajo'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => onCategorySelected(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}