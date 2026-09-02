import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/notifications_button.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/session/logout_action.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/client_bottom_nav_bar.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        centerTitle: true,
        leading: const NotificationsButton(),
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 2),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذر قراءة بيانات الحساب')),
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // User Avatar & Name
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'حساب عميل نشط',
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
              const SizedBox(height: 28),

              // Menu Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'طلباتي السابقة',
                      onTap: () => context.go(AppRoutes.clientOrders),
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.factory_outlined,
                      title: 'مصانع الخرسانة',
                      onTap: () => context.push(AppRoutes.clientFactories),
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.support_agent_outlined,
                      title: 'الدعم والمساعدة',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('خدمة العملاء متاحة 24/7')),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'عن منصة خرسانة',
                      // كان `onTap: () {}` — عنصر قائمة يُضاء عند اللمس ولا
                      // يفتح شيئاً.
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: 'الإصدار 1.0.0',
                        applicationIcon: const Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.primary,
                          size: 40,
                        ),
                        children: const [
                          Text(
                            'منصة لطلب الخرسانة الجاهزة ومتابعة شحناتها بين '
                            'العميل والمصنع والسائق.',
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => confirmAndLogout(context, ref),
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
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
