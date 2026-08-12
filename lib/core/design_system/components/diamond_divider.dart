import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class DiamondDivider extends StatelessWidget {
  final double margin;
  final Color color;

  const DiamondDivider({
    super.key,
    this.margin = 12.0,
    this.color = AppColors.manaCyan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: margin),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, color.withValues(alpha: 0.3)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '◆',
              style: TextStyle(
                color: color,
                fontSize: 10,
                shadows: [
                  Shadow(color: color, blurRadius: 4),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.3), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
