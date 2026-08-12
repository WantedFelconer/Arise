import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class TerminalLineItem {
  final String text;
  final String? status;
  final bool dim;

  const TerminalLineItem({
    required this.text,
    this.status,
    this.dim = false,
  });
}

class TerminalReadout extends StatelessWidget {
  final List<TerminalLineItem> lines;
  final EdgeInsetsGeometry? padding;

  const TerminalReadout({
    super.key,
    required this.lines,
    this.padding,
  });

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'OK': return AppColors.terminalGreen;
      case 'SYNC': return AppColors.manaCyan;
      case 'WARN': return AppColors.expFrom;
      case 'ERR': return AppColors.dangerRed;
      case 'INIT': return AppColors.textSecondary;
      case '...':
      default:
        return AppColors.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((l) {
          final color = l.dim
              ? AppColors.terminalGreen.withValues(alpha: 0.55)
              : AppColors.terminalGreen;
          final statusColor = _getStatusColor(l.status);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                Text(
                  '> ',
                  style: AppTypography.monoStat(
                    fontSize: 12,
                    color: AppColors.terminalGreen.withValues(alpha: 0.55),
                  ),
                ),
                Expanded(
                  child: Text(
                    l.text,
                    style: AppTypography.monoStat(
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ),
                if (l.status != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      '[${l.status}]',
                      style: AppTypography.monoStat(
                        fontSize: 9,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
