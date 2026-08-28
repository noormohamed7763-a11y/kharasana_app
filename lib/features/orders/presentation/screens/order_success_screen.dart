import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_routes.dart';

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
      backgroundColor: const Color(0xFFFCF7F2),
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
                    color: const Color(0xFFD7EEF7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0288D1).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF0288D1),
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
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C221E),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'شكراً لثقتك بنا، سنقوم بمعالجة طلبك قريباً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF7A685E),
                ),
              ),
              const SizedBox(height: 28),

              // 3. Order Summary Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFE5DC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                            color: Color(0xFF8A3C04),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'قيد المراجعة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF0E5DC)),
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
                    color: const Color(0xFFEFE7DE),
                    border: Border.all(color: const Color(0xFFE5D7CC)),
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF8A3C04),
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C221E),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4C2B4)),
                    backgroundColor: Colors.white,
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
                        fontSize: 11,
                        color: Color(0xFFA08E84),
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
        Icon(icon, size: 18, color: const Color(0xFF8A3C04)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF7A685E),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C221E),
          ),
        ),
      ],
    );
  }
}
