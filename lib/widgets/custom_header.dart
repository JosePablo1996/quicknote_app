import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onLeftMenuTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.grey[800] : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.menu,
                    color: isDarkMode ? Colors.white : Colors.blue,
                    size: 24,
                  ),
                ),
              ),
              
              Text(
                'QuickNote',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue,
                ),
              ),
              
              Row(
                children: [
                  _buildAnimatedThemeToggle(themeProvider),
                  const SizedBox(width: 8),
                  
                  GestureDetector(
                    onTap: onRightMenuTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.grey[800] : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: isDarkMode ? Colors.white : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryChip('Todas', selectedCategory == 'Todas', isDarkMode),
              const SizedBox(width: 12),
              _buildCategoryChip('Personal', selectedCategory == 'Personal', isDarkMode),
              const SizedBox(width: 12),
              _buildCategoryChip('Trabajo', selectedCategory == 'Trabajo', isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedThemeToggle(ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.isDarkMode
                ? [Colors.indigo.shade900, Colors.purple.shade900]
                : [Colors.orange.shade400, Colors.yellow.shade600],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (themeProvider.isDarkMode ? Colors.purple : Colors.orange).withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (themeProvider.isDarkMode) ...[
              Positioned(
                left: 8,
                top: 6,
                child: Icon(
                  Icons.star,
                  size: 8,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 6,
                child: Icon(
                  Icons.star,
                  size: 6,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ],
            
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: themeProvider.isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
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
                  child: themeProvider.isDarkMode
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
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.blue 
              : (isDarkMode ? Colors.grey[800] : Colors.transparent),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.blue 
                : (isDarkMode ? Colors.grey[700]! : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDarkMode ? Colors.grey[300] : Colors.grey.shade600),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}