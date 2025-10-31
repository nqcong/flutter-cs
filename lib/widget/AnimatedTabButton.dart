// lib/widgets/animated_tab_button.dart
import 'package:flutter/material.dart';
import '../coordinator/TabItem.dart';

class AnimatedTabButton extends StatelessWidget {
  final TabItem tabItem;
  final bool isActive;
  final VoidCallback onTap;

  const AnimatedTabButton({
    Key? key,
    required this.tabItem,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(isActive ? 16 : 12),
            decoration: BoxDecoration(
              color: isActive ? tabItem.color : Colors.grey.shade100,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: tabItem.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                isActive ? tabItem.activeIcon : tabItem.icon,
                color: isActive ? Colors.white : Colors.grey.shade600,
                size: isActive ? 28 : 24,
              ),
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: tabItem.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
