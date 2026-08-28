import 'package:flutter/material.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../providers/order_creation_controller.dart';
import '../../providers/order_draft.dart';

class StepProjectInfo extends StatefulWidget {
  const StepProjectInfo({
    super.key,
    required this.draft,
    required this.controller,
  });
  final OrderDraft draft;
  final OrderCreationController controller;

  @override
  State<StepProjectInfo> createState() => _StepProjectInfoState();
}

class _StepProjectInfoState extends State<StepProjectInfo> {
  late final _projectNameController =
      TextEditingController(text: widget.draft.projectName);
  late final _ownerNameController =
      TextEditingController(text: widget.draft.projectOwnerName);

  @override
  void dispose() {
    _projectNameController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('بيانات المشروع', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'هذه البيانات اختيارية، لكنها تساعد المصنع على تجهيز طلبك بشكل أدق.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'اسم المشروع (اختياري)',
            hint: 'مثال: فيلا سكنية - حي السلام',
            controller: _projectNameController,
            textInputAction: TextInputAction.next,
            onChanged: (v) => controller.updateDraft(
              (d) => d.copyWith(projectName: v.isEmpty ? null : v),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'اسم صاحب المشروع (اختياري)',
            hint: 'مثال: محمد أحمد',
            controller: _ownerNameController,
            textInputAction: TextInputAction.done,
            onChanged: (v) => controller.updateDraft(
              (d) => d.copyWith(projectOwnerName: v.isEmpty ? null : v),
            ),
          ),
        ],
      ),
    );
  }
}
