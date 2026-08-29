import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../factories/data/models/factory_dto.dart';
import '../../../concrete_types/data/models/concrete_type_dto.dart';
import '../../../client/presentation/widgets/concrete_type_card.dart';

class FactoriesListScreen extends ConsumerWidget {
  const FactoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoriesAsync = ref.watch(factoriesListProvider);
    final concreteTypesAsync = ref.watch(concreteTypesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المصانع'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: factoriesAsync.when(
        loading: () => const LoadingList(),
        error: (error, _) => ErrorStateView(
          message: 'تعذر تحميل المصانع.',
          onRetry: () => ref.invalidate(factoriesListProvider),
        ),
        data: (factories) {
          if (factories.isEmpty) {
            return const EmptyState(
              title: 'لا توجد مصانع متاحة حالياً',
              message: 'يرجى المحاولة لاحقاً.',
              icon: Icons.factory_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                ref.refresh(factoriesListProvider.future),
                ref.refresh(concreteTypesListProvider.future),
              ]);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: factories.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final factory = factories[index];

                return concreteTypesAsync.when(
                  loading: () => _FactoryCardWithLoading(factory: factory),
                  error: (error, _) => _FactoryCardWithError(factory: factory),
                  data: (allConcreteTypes) {
                    final factoryConcreteTypes = allConcreteTypes
                        .where((type) => type.factoryId == factory.factoryId)
                        .toList();

                    return _FactoryWithConcreteTypes(
                      factory: factory,
                      concreteTypes: factoryConcreteTypes,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FactoryWithConcreteTypes extends StatelessWidget {
  const _FactoryWithConcreteTypes({
    required this.factory,
    required this.concreteTypes,
  });

  final FactoryDto factory;
  final List<ConcreteTypeDto> concreteTypes;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.factory_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factory.factoryName,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (factory.area != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              factory.area!,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      if (factory.phone != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              factory.phone!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            const Text(
              'أنواع الخرسانة المتاحة:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (concreteTypes.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'لا توجد أنواع خرسانة متاحة لهذا المصنع حالياً',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: concreteTypes.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ConcreteTypeCard(concreteType: type),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _FactoryCardWithLoading extends StatelessWidget {
  const _FactoryCardWithLoading({required this.factory});
  final FactoryDto factory;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.factory_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factory.factoryName,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (factory.area != null)
                        Text(
                          factory.area!,
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FactoryCardWithError extends StatelessWidget {
  const _FactoryCardWithError({required this.factory});
  final FactoryDto factory;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.factory_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factory.factoryName,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (factory.area != null)
                        Text(
                          factory.area!,
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'تعذر تحميل أنواع الخرسانة',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
