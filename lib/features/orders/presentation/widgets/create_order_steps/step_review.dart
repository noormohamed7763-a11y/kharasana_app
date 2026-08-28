import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../providers/order_creation_controller.dart';
import '../../providers/order_draft.dart';

class StepReview extends ConsumerStatefulWidget {
  const StepReview({
    super.key,
    required this.draft,
    this.initialFactoryId,
  });
  final OrderDraft draft;
  final int? initialFactoryId;

  @override
  ConsumerState<StepReview> createState() => _StepReviewState();
}

class _StepReviewState extends ConsumerState<StepReview> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final controller = ref
        .read(orderCreationControllerProvider(widget.initialFactoryId).notifier);
    final result = await controller.submit();
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case SubmissionSuccess(orderId: final orderId):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم إنشاء الطلب بنجاح! رقم الطلب: $orderId')),
        );
        context.go(AppRoutes.clientOrders);
      case SubmissionFailed(message: final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $message')),
        );
      case SubmissionInProgress():
      case SubmissionIdle():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('مراجعة الطلب', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          _ReviewRow(label: 'المصنع', value: draft.factoryName ?? '—'),
          _ReviewRow(label: 'نوع الخرسانة', value: draft.concreteTypeName ?? '—'),
          _ReviewRow(
              label: 'الكمية', value: '${draft.quantity?.toStringAsFixed(0) ?? '—'} م³'),
          _ReviewRow(label: 'نوع البلاطة', value: draft.slabType.arabicLabel),
          _ReviewRow(label: 'المضخة', value: draft.needPump ? 'نعم' : 'لا'),
          if (draft.needPump)
            _ReviewRow(label: 'الطابق', value: draft.floorNumber?.toString() ?? '—'),
          _ReviewRow(label: 'طريقة النقل', value: draft.transportMethod.arabicLabel),
          if (draft.estimatedTotal != null)
            _ReviewRow(
              label: 'السعر التقديري',
              value: '${draft.estimatedTotal!.toStringAsFixed(0)} ${AppConstants.currencySymbol}',
              highlight: true,
            ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            '* السعر النهائي يحدَّده موظف المصنع بعد مراجعة الطلب.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'إرسال الطلب',
            isLoading: _isSubmitting,
            onPressed: draft.isReadyToSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: highlight
                ? AppTextStyles.h3.copyWith(color: AppColors.primary)
                : AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }
}