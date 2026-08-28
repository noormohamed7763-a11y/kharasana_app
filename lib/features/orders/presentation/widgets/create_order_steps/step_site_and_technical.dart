import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/api_enums.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../providers/order_creation_controller.dart';
import '../../providers/order_draft.dart';

class StepSiteAndTechnical extends StatefulWidget {
  const StepSiteAndTechnical({
    super.key,
    required this.draft,
    required this.controller,
  });
  final OrderDraft draft;
  final OrderCreationController controller;

  @override
  State<StepSiteAndTechnical> createState() => _StepSiteAndTechnicalState();
}

class _StepSiteAndTechnicalState extends State<StepSiteAndTechnical> {
  late final _siteAreaController =
      TextEditingController(text: widget.draft.siteArea);
  late final _siteDescriptionController =
      TextEditingController(text: widget.draft.siteDescription);
  late final _quantityController = TextEditingController(
    text: widget.draft.quantity?.toStringAsFixed(0) ?? '',
  );
  late final _floorNumberController = TextEditingController(
    text: widget.draft.floorNumber?.toString() ?? '',
  );

  @override
  void dispose() {
    _siteAreaController.dispose();
    _siteDescriptionController.dispose();
    _quantityController.dispose();
    _floorNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final controller = widget.controller;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('موقع الصب', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'المنطقة (اختياري)',
            hint: 'مثال: صنعاء - شارع الستين',
            controller: _siteAreaController,
            textInputAction: TextInputAction.next,
            onChanged: (v) => controller.updateDraft(
              (d) => d.copyWith(siteArea: v.isEmpty ? null : v),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'وصف الموقع (اختياري)',
            hint: 'مثال: بجانب مسجد النور، الطريق ترابي',
            controller: _siteDescriptionController,
            maxLines: 3,
            onChanged: (v) => controller.updateDraft(
              (d) => d.copyWith(siteDescription: v.isEmpty ? null : v),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const Text('المتطلبات الفنية', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),

          const Text('نوع البلاطة', style: AppTextStyles.inputLabel),
          const SizedBox(height: 6),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: SlabType.values.map((type) {
              return ChoiceChip(
                label: Text(type.arabicLabel),
                selected: draft.slabType == type,
                selectedColor: AppColors.primaryLight,
                onSelected: (_) => controller.updateDraft(
                  (d) => d.copyWith(slabType: type),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'الكمية المطلوبة (م³) *',
            hint: 'مثال: 25',
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            onChanged: (v) => controller.updateDraft(
              (d) => d.copyWith(quantity: double.tryParse(v)),
            ),
          ),
          if (draft.quantity != null && draft.estimatedTotal != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'السعر التقديري: ${draft.estimatedTotal!.toStringAsFixed(0)}',
              style: AppTextStyles.caption,
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: draft.needPump,
            activeThumbColor: AppColors.primary,
            title: const Text('أحتاج مضخة خرسانة', style: AppTextStyles.bodyLarge),
            subtitle: const Text(
              'اختره إذا كان الصب في طابق مرتفع أو موقع يصعب الوصول إليه',
              style: AppTextStyles.caption,
            ),
            onChanged: (value) {
              if (!value) _floorNumberController.clear();
              controller.updateDraft(
                (d) => d.copyWith(needPump: value, clearFloorNumber: !value),
              );
            },
          ),
          if (draft.needPump) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'رقم الطابق *',
              hint: 'مثال: 3',
              controller: _floorNumberController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: (v) => controller.updateDraft(
                (d) => d.copyWith(floorNumber: int.tryParse(v)),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          if (!draft.isSiteAndTechnicalValid)
            Text(
              draft.needPump && draft.floorNumber == null
                  ? '* يرجى إدخال رقم الطابق عند طلب المضخة.'
                  : '* يرجى إدخال كمية صحيحة أكبر من صفر.',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
        ],
      ),
    );
  }
}
