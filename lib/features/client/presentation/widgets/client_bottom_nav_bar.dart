import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class ClientBottomNavBar extends StatelessWidget {
  const ClientBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  /// 0: الرئيسية, 1: طلباتي, 2: حسابي.
  ///
  /// مرّر ‎-1‎ في شاشة ليست إحدى هذه الوجهات الثلاث (مثل قائمة المصانع
  /// المدفوعة على المكدّس): فلا يُضاء شيء، لأن إضاءة "الرئيسية" والمستخدم
  /// ليس فيها تكذب على المستخدم بموقعه.
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: 'الرئيسية',
            icon: Icons.home_rounded,
            isActive: currentIndex == 0,
            onTap: () {
              if (currentIndex != 0) context.go(AppRoutes.clientHome);
            },
          ),
          _NavItem(
            label: 'طلباتي',
            icon: Icons.receipt_long_rounded,
            isActive: currentIndex == 1,
            onTap: () {
              if (currentIndex != 1) context.go(AppRoutes.clientOrders);
            },
          ),
          _NavItem(
            label: 'حسابي',
            icon: Icons.person_rounded,
            isActive: currentIndex == 2,
            onTap: () {
              if (currentIndex != 2) context.go(AppRoutes.clientProfile);
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            // primary لا brand500: الأخير مع نص أبيض 3.79:1، دون حدّ AA.
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textOnPrimary, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
