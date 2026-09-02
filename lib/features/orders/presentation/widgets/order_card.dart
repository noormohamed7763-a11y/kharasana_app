import 'package:flutter/material.dart';
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
    final dateStr =
        order.createdAt != null ? AppFormat.date(order.createdAt!) : 'مؤخراً';

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

          // المواصفات: النوع، الكمية، التاريخ.
          //
          // `Wrap` لا `Row` مع `spaceBetween`: كانت ثلاث `Row` غير مقيّدة
          // داخل صفّ واحد، فتتجاوز الحدود على كلّ عرض جهاز — قياساً ١٤px عند
          // ٤١٢dp باسم نوع قصير، و٢٦٥px عند ٣٢٠dp باسم طويل. والنصّ المقصوص
          // هنا يخفي بيانات يقرأها العميل (الكمية والموعد)، فالانتقال إلى
          // سطر ثانٍ أصحّ من الحذف بالنقاط.
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _Spec(icon: Icons.layers_outlined, text: order.concreteTypeName),
              _Spec(
                icon: Icons.view_in_ar_rounded,
                text: AppFormat.cubicMetres(order.quantity),
              ),
              _Spec(
                icon: Icons.calendar_today_outlined,
                text: dateStr,
                iconColor: AppColors.ink300,
                textColor: AppColors.ink500,
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

/// مواصفة واحدة: أيقونة + نصّ، بحجمها الطبيعي داخل `Wrap`.
class _Spec extends StatelessWidget {
  const _Spec({
    required this.icon,
    required this.text,
    this.iconColor = AppColors.brand800,
    this.textColor = AppColors.ink900,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        // `Flexible` لازم داخل `Row`: الـ`Wrap` يقيّد عرض المواصفة بعرض
        // البطاقة، لكن الصفّ يمنح ابنه عرضاً غير محدود، فنصّ طويل جداً
        // (اسم نوع خرسانة مطوَّل) يتجاوز حدود الصفّ نفسه.
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}