import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../sync/sync_engine.dart';
import 'glass_card.dart';

class UplinkChip extends StatelessWidget {
  final bool stable;
  final SyncEngineStatus? syncStatus;
  final int pendingCount;

  const UplinkChip({
    super.key,
    this.stable = true,
    this.syncStatus,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    if (!stable) {
      color = AppColors.dangerRed;
      label = 'UPLINK: SEVERED';
    } else if (syncStatus == SyncEngineStatus.syncing) {
      color = AppColors.manaCyan;
      label = pendingCount > 0 ? 'SYNCING [$pendingCount]...' : 'SYNCING...';
    } else if (syncStatus == SyncEngineStatus.error) {
      color = AppColors.rankB; // Amber warning color
      label = 'SYNC: RETRYING';
    } else {
      color = AppColors.terminalGreen;
      label = 'UPLINK: STABLE';
    }

    return GlassCard(
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderColor: color.withValues(alpha: stable ? 0.25 : 0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.monoStat(
              fontSize: 8,
              color: color,
              letterSpacing: 0.04,
            ),
          ),
        ],
      ),
    );
  }
}
