import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.manaCyan,
    this.inactiveColor = AppColors.textDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: 44,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: value ? activeColor.withValues(alpha: 0.25) : AppColors.manaCyan.withValues(alpha: 0.08),
          border: Border.all(
            color: value ? activeColor.withValues(alpha: 0.5) : AppColors.manaCyan.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? activeColor : inactiveColor,
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
