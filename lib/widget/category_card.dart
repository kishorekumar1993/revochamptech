// ==================== CATEGORY CARD COMPONENT ====================

import 'package:flutter/material.dart';
import 'package:techtutorial/core/theme.dart';

import '../screens/home.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String emoji;
  final int color;
  final int courseCount;
  final VoidCallback onTap;
   final bool? isSelected;

  const CategoryCard({super.key, 
    required this.name,
    required this.emoji,
    required this.color,
    required this.courseCount,
    required this.onTap,
         this.isSelected =false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
                       color: isSelected! ? Color(color).withValues(alpha:0.08) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected! 
                    ? Color(color).withValues(alpha:0.3)
                    : PremiumTheme.lightGray,
                width: 1.5,
              ),
 ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 42)),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: PremiumTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$courseCount courses",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: PremiumTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
