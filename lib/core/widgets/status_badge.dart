import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../utils/api_enums.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        status.arabicLabel,
        style: AppTextStyles.badgeText.copyWith(color: status.color),
      ),
    );
  }
}