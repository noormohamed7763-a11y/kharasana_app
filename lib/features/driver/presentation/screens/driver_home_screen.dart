import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/notifications_button.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/session/logout_action.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../orders/data/models/order_summary_dto.dart';
import '../providers/driver_providers.dart';
import '../widgets/driver_bottom_nav_bar.dart';
import '../widgets/driver_status_selector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_format.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(driverOrdersProvider);
    final sessionAsync = ref.watch(sessionUserProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'لوحة تحكم السائق',
          style: TextStyle(
            color: AppColors.brand700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: const NotificationsButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.brand700),
            tooltip: 'تسجيل الخروج',
            onPressed: () => confirmAndLogout(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: const DriverBottomNavBar(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(driverOrdersProvider);
          try {
            await ref.read(driverOrdersProvider.future);
          } catch (e, st) {
            AppLogger.error('DriverUI', e, st, 'فشل أثناء تحديث قائمة الطلبات');
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // 1. Driver Greeting & Workplace Factory Card
            ordersAsync.when(
              loading: () => _DriverHeader(
                driverName: sessionAsync.valueOrNull?.displayName ?? 'السائق',
                factoryName: 'جارِ التحميل...',
              ),
              error: (_, __) => _DriverHeader(
                driverName: sessionAsync.valueOrNull?.displayName ?? 'السائق',
                factoryName: 'مصنع الخرسانة المعتمد',
              ),
              data: (orders) {
                final factory = orders.isNotEmpty ? orders.first.factoryName : 'مصنع الخرسانة الجاهزة';
                return _DriverHeader(
                  driverName: sessionAsync.valueOrNull?.displayName ?? 'السائق',
                  factoryName: factory,
                );
              },
            ),
            const SizedBox(height: 14),

            // 2. حالة توفّر السائق — تدير حالتها بنفسها عبر
            // driverStatusControllerProvider، فلا تُغلَّف بـ sessionAsync.when
            // لأن ذلك كان يهدمها من الشجرة بعد كل تحديث ناجح.
            const DriverStatusSelector(),
            const SizedBox(height: 22),

            // 3. Driver Capabilities / Powers Overview
            const Text(
              'المهام والصلاحيات المتاحة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _CapabilityCard(
                    icon: Icons.local_shipping_rounded,
                    title: 'بدء التوصيل',
                    subtitle: 'تحويل الشحنة إلى (في الطريق)',
                    accentColor: AppColors.brand500,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _CapabilityCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'الاتصال بالعميل',
                    subtitle: 'تنسيق وتحديد موقع الصب',
                    accentColor: AppColors.info,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _CapabilityCard(
                    icon: Icons.check_circle_rounded,
                    title: 'تأكيد التسليم',
                    subtitle: 'إتمام تفريغ الشحنة بنجاح',
                    accentColor: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // 4. Assigned Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'طلبات التوصيل المسندة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink900,
                  ),
                ),
                ordersAsync.maybeWhen(
                  data: (orders) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${orders.length} شحنة',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brand800,
                      ),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 5. Orders List View
            ordersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ErrorStateView(
                  message: failureMessage(error),
                  onRetry: () => ref.invalidate(driverOrdersProvider),
                ),
              ),
              data: (orders) {
                if (orders.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 48, color: AppColors.ink200),
                        SizedBox(height: 12),
                        Text(
                          'لا توجد طلبات توصيل مسندة حالياً',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ستظهر هنا أي شحنة جديدة يتم إسنادها إليك من المصنع فوراً.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.ink500),
                        ),
                      ],
                    ),
                  );
                }

                final activeOrders = _activeFirst(orders);
                return Column(
                  children: activeOrders.map((order) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DriverOrderCard(
                        order: order,
                        onTap: () => context.push('/driver/orders/${order.orderId}'),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<OrderSummaryDto> _activeFirst(List<OrderSummaryDto> orders) {
    final active = <OrderSummaryDto>[];
    final rest = <OrderSummaryDto>[];
    for (final order in orders) {
      final isActive = order.status == OrderStatus.approved ||
          order.status == OrderStatus.onTheWay;
      (isActive ? active : rest).add(order);
    }
    return [...active, ...rest];
  }
}

class _DriverHeader extends StatelessWidget {
  const _DriverHeader({
    required this.driverName,
    required this.factoryName,
  });

  final String driverName;
  final String factoryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_shipping_rounded,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'أهلاً بك، كابتن',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      driverName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.white.withValues(alpha: 0.24)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.factory_rounded, color: AppColors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'المصنع التابع له: $factoryName',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.ink900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink500,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DriverOrderCard extends StatelessWidget {
  const _DriverOrderCard({
    required this.order,
    required this.onTap,
  });

  final OrderSummaryDto order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب رقم #${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink900,
                ),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.concreteTypeName} · ${AppFormat.cubicMetres(order.quantity)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.ink500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عرض تفاصيل التوصيل',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_left_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}