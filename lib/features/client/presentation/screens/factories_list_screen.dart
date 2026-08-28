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

class FactoriesListScreen extends ConsumerWidget {
  const FactoriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoriesAsync = ref.watch(factoriesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المصانع')),
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
            onRefresh: () => ref.refresh(factoriesListProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: factories.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _FactoryCard(factory: factories[index]),
            ),
          );
        },
      ),
    );
  }
}

class _FactoryCard extends StatelessWidget {
  const _FactoryCard({required this.factory});
  final FactoryDto factory;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.factory, color: AppColors.primaryDark),
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
                  const SizedBox(height: 4),
                  if (factory.area != null)
                    Text(
                      factory.area!,
                      style: AppTextStyles.bodyMedium,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}