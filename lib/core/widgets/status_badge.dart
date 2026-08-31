import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../utils/api_enums.dart';

/// شريحة حالة الطلب — أكثر عنصر يُقرأ في التطبيق.
///
/// أيقونة + نص + لون. الثلاثة مقصودة: الحالات ثمانٍ والألوان خمسة، فاللون
/// وحده لا يفرّق "تمت الموافقة" من "في الطريق". والنصّ وحده يُبطئ المسح
/// البصري في قائمة فيها عشرات الطلبات.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.arabicLabel,
            style: AppTextStyles.badgeText.copyWith(color: status.color),
          ),
        ],
      ),
    );
  }
}
