import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../orders/presentation/providers/orders_list_controller.dart';
import '../widgets/client_bottom_nav_bar.dart';
import '../../../../core/theme/app_colors.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = ref.read(secureStorageProvider);
    final ordersState = ref.watch(ordersListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الرئيسية',
          style: TextStyle(
            color: AppColors.brand700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.ink700),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا توجد إشعارات جديدة')),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.brand700),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await storage.clearSession();
              if (!context.mounted) return;
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.refresh(factoriesListProvider.future),
            ref.refresh(ordersListControllerProvider.notifier).refresh(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User Greeting
              FutureBuilder<String?>(
                future: storage.readFullName(),
                builder: (context, snapshot) {
                  final name = snapshot.data ?? 'عميلنا العزيز';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أهلاً بك،',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.ink500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'مرحباً $name',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink900,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. Quick Action Cards (المصانع & طلباتي)
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'المصانع',
                      subtitle: 'استكشف مصانع\nالخرسانة',
                      icon: Icons.factory_rounded,
                      onTap: () => context.push(AppRoutes.clientFactories),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'طلباتي',
                      subtitle: 'متابعة حالة الطلبات\nوالشحنات',
                      icon: Icons.receipt_long_rounded,
                      onTap: () => context.push(AppRoutes.clientOrders),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // 3. Section Header: آخر الطلبات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'آخر الطلبات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink900,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.clientOrders),
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: AppColors.brand700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Recent Orders Horizontal Cards or Preview
              switch (ordersState) {
                OrdersListLoaded(items: final items) when items.isNotEmpty => SizedBox(
                    height: 135,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length > 3 ? 3 : items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final order = items[index];
                        return _RecentOrderCard(
                          orderNumber: order.orderNumber,
                          concreteType: order.concreteTypeName,
                          factoryName: order.factoryName,
                          status: order.status,
                          onTap: () => context.push('/client/orders/${order.orderId}'),
                        );
                      },
                    ),
                  ),
                _ => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brand50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: AppColors.brand500,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'لا توجد طلبات جارية',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.ink900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'أنشئ طلبك الأول واطلب خرسانة الآن بكل سهولة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.ink500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              },
              const SizedBox(height: 24),

              // 4. Promotional Card & Action
              Container(
                decoration: BoxDecoration(
                  // التدرّج يحمل نصاً أبيض، فلا يجوز أن يبدأ من brand400:
                  // الأبيض عليه 2.82:1 والأبيض الشفّاف 2.05:1 — أسوأ فشل تباين
                  // كان في التطبيق، في أبرز بطاقة بالشاشة. brand600←brand800
                  // يعطي الأبيض 5.18:1 عند أفتح طرف و7.70:1 عند أغمقه.
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.brand600,
                      AppColors.brand800,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background Watermark Icon
                    const Positioned(
                      left: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.architecture_rounded,
                          size: 160,
                          color: AppColors.white,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'وفّر في مشروعك القادم',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'احصل على عروض حصرية من أفضل مصانع الخرسانة في منطقتك عند الطلب عبر التطبيق.',
                            style: TextStyle(
                              // معتم لا 0.9: الشفافية تنزل به إلى 4.48:1، أي
                              // تحت الحد بفرق لا يُرى لكنه يُقاس.
                              color: AppColors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            children: [
                              ElevatedButton(
                                onPressed: () => context.push(AppRoutes.clientFactories),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brand900,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'اكتشف العروض',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => context.push(AppRoutes.clientOrderCreate),
                                icon: const Icon(Icons.add, color: AppColors.white, size: 18),
                                label: const Text(
                                  'إنشاء طلب جديد',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderWarm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.borderWarm,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.brand800, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.ink500,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({
    required this.orderNumber,
    required this.concreteType,
    required this.factoryName,
    required this.status,
    required this.onTap,
  });

  final String orderNumber;
  final String concreteType;
  final String factoryName;
  final OrderStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.ink900,
                  ),
                ),
                StatusBadge(status: status),
              ],
            ),
            Text(
              concreteType,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                const Icon(Icons.factory_outlined, size: 14, color: AppColors.ink300),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    factoryName,
                    style: const TextStyle(fontSize: 12, color: AppColors.ink500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}