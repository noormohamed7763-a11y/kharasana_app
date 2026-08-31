import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/order_details_provider.dart';
import '../../../../core/utils/app_format.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الطلب #$orderId'),
      ),
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'تعذر تحميل تفاصيل الطلب',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderDetailsProvider(orderId)),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (order) {
          final dateFormat = DateFormat('d MMMM yyyy', 'ar');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رقم الطلب والحالة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderNumber,
                        style: AppTextStyles.h3,
                      ),
                      StatusBadge(status: order.status),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // معلومات المشروع
                const _SectionTitle('معلومات المشروع'),
                _InfoCard([
                  _InfoRow('اسم المشروع', order.projectName ?? '—'),
                  _InfoRow('مالك المشروع', order.projectOwnerName ?? '—'),
                  _InfoRow('المنطقة', order.siteArea ?? '—'),
                  if (order.siteDescription != null)
                    _InfoRow('الموقع', order.siteDescription!),
                ]),

                const SizedBox(height: AppSpacing.md),

                // معلومات الخرسانة
                const _SectionTitle('مواصفات الخرسانة'),
                _InfoCard([
                  _InfoRow('المصنع', order.factoryName),
                  _InfoRow('نوع الخرسانة', order.concreteTypeName),
                  _InfoRow('الكمية', AppFormat.cubicMetres(order.quantity)),
                  _InfoRow('نوع البلاطة', order.slabType.arabicLabel),
                  _InfoRow(
                    'طريقة النقل',
                    order.transportMethod.arabicLabel,
                    icon: order.transportMethod.icon,
                  ),
                  _InfoRow('المضخة', order.needPump ? 'نعم' : 'لا'),
                  if (order.needPump && order.floorNumber != null)
                    _InfoRow('الطابق', order.floorNumber!.toString()),
                  if (order.pouringDate != null)
                    _InfoRow('موعد الصب', dateFormat.format(order.pouringDate!)),
                ]),

                const SizedBox(height: AppSpacing.md),

                // معلومات السائق
                if (order.hasDriverAssigned) ...[
                  const _SectionTitle('السائق المكلف'),
                  _InfoCard([
                    _InfoRow('اسم السائق', order.driverName ?? '—'),
                    if (order.truckPlate != null)
                      _InfoRow('رقم الخلاطة', order.truckPlate!),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                ],

                // معلومات السعر
                const _SectionTitle('التكلفة'),
                _InfoCard([
                  _InfoRow(
                    'سعر المتر المكعب',
                    order.unitPrice != null
                        ? AppFormat.money(order.unitPrice!)
                        : 'قيد التسعير',
                  ),
                  _InfoRow(
                    'الإجمالي',
                    order.totalPrice != null
                        ? AppFormat.money(order.totalPrice!)
                        : 'قيد التحديد',
                    isBold: true,
                  ),
                ]),

                const SizedBox(height: AppSpacing.md),

                // الملاحظات
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const _SectionTitle('ملاحظات'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      order.notes!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: AppTextStyles.h3),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(this.children);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.isBold = false, this.icon});
  final String label;
  final String value;
  final bool isBold;

  /// أيقونة اختيارية قبل القيمة — بديل الإيموجي الذي كان مدسوساً في النصّ.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppSizes.iconSm, color: AppColors.ink500),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: isBold
                        ? AppTextStyles.h3.copyWith(color: AppColors.primary)
                        : AppTextStyles.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
