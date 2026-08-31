import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/order_summary_dto.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_format.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final OrderSummaryDto order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ar');
    final dateStr = order.createdAt != null ? dateFormat.format(order.createdAt!) : 'مؤخراً';

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Order Number, Project Name & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلب رقم #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.factoryName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.ink500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: order.status),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Specs (Concrete type, Quantity, Date)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.layers_outlined, size: 16, color: AppColors.brand800),
                  const SizedBox(width: 4),
                  Text(
                    order.concreteTypeName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.view_in_ar_rounded, size: 16, color: AppColors.brand800),
                  const SizedBox(width: 4),
                  Text(
                    AppFormat.cubicMetres(order.quantity),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink900,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.ink300),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: AppColors.ink500),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Outlined Action Button "عرض التفاصيل"
          SizedBox(
            height: 42,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderStrong),
                backgroundColor: AppColors.surfaceAlt,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'عرض التفاصيل',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brand800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}