import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.factoryName,
    required this.concreteTypeName,
    this.pouringDate,
  });

  final int orderId;
  final String factoryName;
  final String concreteTypeName;
  final DateTime? pouringDate;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ar');
    final dateStr = pouringDate != null ? dateFormat.format(pouringDate!) : 'اليوم';

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // 1. Success Circle Icon
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.infoBorder,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.info.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.info,
                      size: 52,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Success Title & Subtitle
              const Text(
                'تم إرسال الطلب بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'شكراً لثقتك بنا، سنقوم بمعالجة طلبك قريباً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.ink500,
                ),
              ),
              const SizedBox(height: 28),

              // 3. Order Summary Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Card Header with Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تفاصيل الطلب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brand800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.brand50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'قيد المراجعة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              // brand500 على brand50 = 3.39:1، وهذا نصّ ١٢px
                              // لا يُعدّ كبيراً فيلزمه 4.5:1. primary = 4.63:1
                              // ويبقى مميّزاً عن عنوان القسم بجواره (brand800).
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),

                    // Info Rows
                    _DetailRow(icon: Icons.tag_rounded, label: 'رقم الطلب', value: '#KH-2026-$orderId'),
                    const SizedBox(height: 10),
                    _DetailRow(icon: Icons.factory_outlined, label: 'اسم المصنع', value: factoryName),
                    const SizedBox(height: 10),
                    _DetailRow(icon: Icons.calendar_month_outlined, label: 'تاريخ الصب', value: dateStr),
                    const SizedBox(height: 10),
                    _DetailRow(icon: Icons.layers_outlined, label: 'نوع الخرسانة', value: concreteTypeName),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Map / Site visual preview
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    border: Border.all(color: AppColors.borderWarm),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.25,
                          child: Image.asset(
                            'assets/images/order_banner.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.brand800,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 5. Actions
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.clientHome),
                  icon: const Icon(Icons.home_rounded, size: 20),
                  label: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/client/orders/$orderId'),
                  icon: const Icon(Icons.receipt_long_outlined, size: 20),
                  label: const Text(
                    'عرض تفاصيل الطلب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink900,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderStrong),
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 6. Footer Brand
              const Center(
                child: Column(
                  children: [
                    Text(
                      'KHORSANA • النظام الذكي لخدمات الخرسانة الجاهزة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.ink200,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.brand800),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.ink500,
          ),
        ),
        const Spacer(),
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
