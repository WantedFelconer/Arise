import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import 'ornate_panel.dart';

enum SystemAlertType { alarm, notice, warning }

class SystemAlert extends StatelessWidget {
  final SystemAlertType type;
  final String title;
  final String content;
  final VoidCallback? onDismiss;

  const SystemAlert({
    super.key,
    this.type = SystemAlertType.notice,
    required this.title,
    required this.content,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color accent;
    Color bg;
    Color border;

    switch (type) {
      case SystemAlertType.alarm:
        accent = AppColors.dangerRed;
        bg = const Color(0x14FF2E4D);
        border = const Color(0x80FF2E4D);
        break;
      case SystemAlertType.notice:
        accent = AppColors.manaCyan;
        bg = const Color(0x0D3EE6F5);
        border = const Color(0x663EE6F5);
        break;
      case SystemAlertType.warning:
        accent = AppColors.expFrom;
        bg = const Color(0x0FFF3D24C);
        border = const Color(0x66FFD24C);
        break;
    }

    return OrnatePanel(
      cornerSize: 28,
      backgroundColor: bg,
      borderColor: border,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: accent, blurRadius: 10),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '!',
                  style: AppTypography.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                type.name.toUpperCase(),
                style: AppTypography.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  letterSpacing: 0.12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent.withValues(alpha: 0.6), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTypography.rajdhani(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withValues(alpha: 0.2), accent.withValues(alpha: 0.08)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: accent.withValues(alpha: 0.6)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '[ ACKNOWLEDGE ]',
                  style: AppTypography.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: 0.12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
