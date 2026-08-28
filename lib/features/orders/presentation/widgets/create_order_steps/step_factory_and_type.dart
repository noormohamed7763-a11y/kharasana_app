import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/core_providers.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../client/presentation/widgets/concrete_type_card.dart';
import '../../../../factories/data/models/factory_dto.dart';
import '../../providers/order_creation_controller.dart';
import '../../providers/order_draft.dart';

class StepFactoryAndType extends ConsumerWidget {
  const StepFactoryAndType({super.key, required this.draft, required this.controller});
  final OrderDraft draft;
  final OrderCreationController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoriesAsync = ref.watch(factoriesListProvider);
    final concreteTypesAsync = ref.watch(concreteTypesListProvider);

    return factoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Text('تعذر تحميل المصانع.', style: AppTextStyles.bodyMedium),
      data: (factories) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. اختر المصنع', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.sm),
              ...factories.map((f) => _FactoryOption(
                    factory: f,
                    isSelected: draft.factoryId == f.factoryId,
                    onTap: () {
                      controller.updateDraft((d) => d.copyWith(
                            factoryId: f.factoryId,
                            factoryName: f.factoryName,
                            concreteTypeId: null,
                            concreteTypeName: null,
                            concreteUnitPrice: null,
                          ));
                    },
                  )),
              if (draft.factoryId != null) ...[
                const SizedBox(height: AppSpacing.lg),
                const Text('2. اختر نوع الخرسانة', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.sm),
                concreteTypesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      const Text('تعذر تحميل أنواع الخرسانة.', style: AppTextStyles.bodyMedium),
                  data: (allTypes) {
                    final typesForFactory =
                        allTypes.where((t) => t.factoryId == draft.factoryId).toList();
                    if (typesForFactory.isEmpty) {
                      return const Text(
                        'لا توجد أنواع خرسانة متاحة من هذا المصنع حالياً.',
                        style: AppTextStyles.bodyMedium,
                      );
                    }
                    return Column(
                      children: typesForFactory
                          .map((t) => GestureDetector(
                                onTap: () => controller.updateDraft((d) => d.copyWith(
                                      concreteTypeId: t.concreteTypeId,
                                      concreteTypeName: t.name,
                                      concreteUnitPrice: t.unitPrice,
                                    )),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(
                                      color: draft.concreteTypeId == t.concreteTypeId
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: ConcreteTypeCard(concreteType: t),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FactoryOption extends StatelessWidget {
  const _FactoryOption({required this.factory, required this.isSelected, required this.onTap});
  final FactoryDto factory;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: isSelected ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : AppColors.textDisabled,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(factory.factoryName, style: AppTextStyles.h3),
                      if (factory.area != null)
                        Text(factory.area!, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}