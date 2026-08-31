import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/driver_providers.dart';
import '../widgets/driver_bottom_nav_bar.dart';

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionUserProvider);
    final ordersAsync = ref.watch(driverOrdersProvider);
    final storage = ref.read(secureStorageProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ملفي الشخصي',
          style: TextStyle(
            color: AppColors.brand700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.ink700),
          onPressed: () {},
        ),
      ),
      bottomNavigationBar: const DriverBottomNavBar(currentIndex: 1),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذر قراءة بيانات الجلسة.')),
        data: (user) {
          final factoryName = ordersAsync.maybeWhen(
            data: (orders) => orders.isNotEmpty ? orders.first.factoryName : 'مصنع الخرسانة الجاهزة',
            orElse: () => 'مصنع الخرسانة الجاهزة',
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // 1. Driver Avatar & Role Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.brand500, width: 2.5),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.local_shipping_rounded,
                            size: 46,
                            color: AppColors.brand500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'سائق شاحنة خرسانة معتمد',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Factory Workplace Information Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.factory_rounded, color: AppColors.brand800, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'المصنع وبيانات العمل',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 10),
                      _ProfileRow(label: 'المصنع التابع له', value: factoryName),
                      if (user.userId != null) ...[
                        const SizedBox(height: 8),
                        _ProfileRow(label: 'رقم السائق التعريفي', value: '#DRV-${user.userId}'),
                      ],
                      const SizedBox(height: 8),
                      const _ProfileRow(label: 'نوع العمل', value: 'نقل وتفريغ خرسانة جاهزة'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Driver Responsibilities & Capabilities Overview
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.task_alt_rounded, color: AppColors.brand800, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'صلاحيات ومهام السائق في المنصة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(height: 1, color: AppColors.border),
                      SizedBox(height: 12),
                      _CapabilityItem(
                        icon: Icons.check_circle_outline_rounded,
                        text: 'استلام الشحنات والطلبات المسندة من إدارة المصنع.',
                      ),
                      SizedBox(height: 8),
                      _CapabilityItem(
                        icon: Icons.check_circle_outline_rounded,
                        text: 'بدء التوصيل وتحديث الحالة لحظياً في النظام.',
                      ),
                      SizedBox(height: 8),
                      _CapabilityItem(
                        icon: Icons.check_circle_outline_rounded,
                        text: 'التواصل والاتصال المباشر بالعميل لتنسيق موقع الصب.',
                      ),
                      SizedBox(height: 8),
                      _CapabilityItem(
                        icon: Icons.check_circle_outline_rounded,
                        text: 'تأكيد التسليم وإتمام التوصيل فور انتهاء الصب.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Logout Button
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await storage.clearSession();
                      if (!context.mounted) return;
                      context.go(AppRoutes.login);
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.ink500),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.ink900,
          ),
        ),
      ],
    );
  }
}

class _CapabilityItem extends StatelessWidget {
  const _CapabilityItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.success),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.ink700, height: 1.35),
          ),
        ),
      ],
    );
  }
}
