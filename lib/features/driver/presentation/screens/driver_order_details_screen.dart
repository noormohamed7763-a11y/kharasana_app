import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../orders/presentation/providers/order_details_provider.dart';
import '../providers/driver_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_format.dart';

class DriverOrderDetailsScreen extends ConsumerStatefulWidget {
  const DriverOrderDetailsScreen({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<DriverOrderDetailsScreen> createState() =>
      _DriverOrderDetailsScreenState();
}

class _DriverOrderDetailsScreenState
    extends ConsumerState<DriverOrderDetailsScreen> {
  bool _isActionInProgress = false;

  Future<void> _runAction(
    Future<Result<void>> Function() action,
    String successMessage,
  ) async {
    if (_isActionInProgress) return;
    setState(() => _isActionInProgress = true);

    final result = await action();

    if (!mounted) return;
    setState(() => _isActionInProgress = false);

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case Success():
        ref.invalidate(orderDetailsProvider(widget.orderId));
        ref.invalidate(driverOrdersProvider);
        messenger.showSnackBar(SnackBar(content: Text(successMessage)));
      case Error(failure: final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.messageAr)));
    }
  }

  void _startDelivery() => _runAction(
        () => ref.read(ordersRepositoryProvider).startDelivery(widget.orderId),
        'تم بدء التوصيل بنجاح',
      );

  void _confirmDelivery() => _runAction(
        () => ref.read(ordersRepositoryProvider).deliverOrder(widget.orderId),
        'تم تسليم الطلب بنجاح',
      );

  Future<void> _callClient(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    var launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (e, st) {
      launched = false;
      AppLogger.error('DriverUI', e, st, 'فشل أثناء محاولة الاتصال');
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر بدء الاتصال من هذا الجهاز.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailsProvider(widget.orderId));
    final dateFormat = DateFormat('d MMMM yyyy', 'ar');

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تفاصيل التوصيل',
          style: TextStyle(
            color: AppColors.brand700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.brand700),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorStateView(
          message: 'تعذر تحميل تفاصيل الطلب.',
          onRetry: () => ref.invalidate(orderDetailsProvider(widget.orderId)),
        ),
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Order Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طلب #${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.factoryName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.ink500,
                          ),
                        ),
                      ],
                    ),
                    StatusBadge(status: order.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Client Info Card with Direct Call Action
              _SectionCard(
                title: 'بيانات العميل',
                icon: Icons.person_rounded,
                children: [
                  _InfoRow(label: 'اسم العميل', value: order.clientName),
                  if (order.clientPhone != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'رقم الهاتف', value: order.clientPhone!),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => _callClient(order.clientPhone!),
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: const Text(
                          'اتصال مباشر بالعميل',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // 3. Delivery Location Card
              _SectionCard(
                title: 'موقع التسليم والمشروع',
                icon: Icons.location_on_rounded,
                children: [
                  _InfoRow(label: 'المنطقة', value: order.siteArea ?? 'غير محدد'),
                  if (order.projectName != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'اسم المشروع', value: order.projectName!),
                  ],
                  if (order.siteDescription != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'تفاصيل العنوان', value: order.siteDescription!),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // 4. Concrete & Shipment Specifications
              _SectionCard(
                title: 'مواصفات الشحنة والخرسانة',
                icon: Icons.layers_rounded,
                children: [
                  _InfoRow(label: 'المصنع', value: order.factoryName),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'نوع الخرسانة', value: order.concreteTypeName),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'الكمية', value: AppFormat.cubicMetres(order.quantity)),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'نوع البلاطة', value: order.slabType.arabicLabel),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'المضخة', value: order.needPump ? 'نعم (مطلوبة)' : 'لا'),
                  if (order.needPump && order.floorNumber != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'رقم الطابق', value: order.floorNumber!.toString()),
                  ],
                  if (order.pouringDate != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(label: 'موعد الصب', value: dateFormat.format(order.pouringDate!)),
                  ],
                ],
              ),

              // 5. Notes
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'ملاحظات إضافية',
                  icon: Icons.notes_rounded,
                  children: [
                    Text(
                      order.notes!,
                      style: const TextStyle(fontSize: 14, color: AppColors.ink900, height: 1.4),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // 6. Action Button for Current Status
              _DeliveryAction(
                status: order.status,
                isLoading: _isActionInProgress,
                onStartDelivery: _startDelivery,
                onDeliver: _confirmDelivery,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryAction extends StatelessWidget {
  const _DeliveryAction({
    required this.status,
    required this.isLoading,
    required this.onStartDelivery,
    required this.onDeliver,
  });

  final OrderStatus status;
  final bool isLoading;
  final VoidCallback onStartDelivery;
  final VoidCallback onDeliver;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      OrderStatus.approved => SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onStartDelivery,
            icon: const Icon(Icons.local_shipping_rounded, size: 20),
            label: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2))
                : const Text('بدء التوصيل الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              // primary لا brand500: الأخير مع أبيض 3.79:1، دون حدّ AA.
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      OrderStatus.onTheWay => SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onDeliver,
            icon: const Icon(Icons.check_circle_rounded, size: 20),
            label: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2))
                : const Text('تأكيد التسليم بنجاح', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      OrderStatus.delivered || OrderStatus.closed => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.successBorder),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 22),
              SizedBox(width: 8),
              Text(
                'تم إكمال وتفريغ هذا التوصيل بنجاح',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.brand800),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
      ],
    );
  }
}
