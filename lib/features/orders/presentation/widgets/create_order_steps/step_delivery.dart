import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/api_enums.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../providers/order_creation_controller.dart';
import '../../providers/order_draft.dart';

class StepDelivery extends StatefulWidget {
  const StepDelivery({
    super.key,
    required this.draft,
    required this.controller,
    required this.reviewChild,
  });
  final OrderDraft draft;
  final OrderCreationController controller;
  final Widget reviewChild;

  @override
  State<StepDelivery> createState() => _StepDeliveryState();
}

class _StepDeliveryState extends State<StepDelivery> {
  late final _notesController = TextEditingController(text: widget.draft.notes);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.draft.pouringDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      locale: const Locale('ar', 'YE'),
    );
    if (picked != null) {
      widget.controller.updateDraft((d) => d.copyWith(pouringDate: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final controller = widget.controller;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('موعد الصب (اختياري)', style: AppTextStyles.inputLabel),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(
              draft.pouringDate != null
                  ? '${draft.pouringDate!.year}/${draft.pouringDate!.month}/${draft.pouringDate!.day}'
                  : 'اختر التاريخ',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('طريقة النقل', style: AppTextStyles.inputLabel),
          const SizedBox(height: 6),
          Column(
            children: TransportMethod.values.map((method) {
              return RadioListTile<TransportMethod>(
                contentPadding: EdgeInsets.zero,
                value: method,
                groupValue: draft.transportMethod,
                activeColor: AppColors.primary,
                title: Text(method.arabicLabel, style: AppTextStyles.bodyLarge),
                onChanged: (value) =>
                    controller.updateDraft((d) => d.copyWith(transportMethod: value!)),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'ملاحظات (اختياري)',
            hint: 'مثال: نرجو الالتزام بالموعد',
            controller: _notesController,
            maxLines: 3,
            onChanged: (v) =>
                controller.updateDraft((d) => d.copyWith(notes: v.isEmpty ? null : v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          widget.reviewChild,
        ],
      ),
    );
  }
}