import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../client/presentation/widgets/client_bottom_nav_bar.dart';
import '../../../client/presentation/widgets/factory_card.dart';
import '../../../../core/theme/app_colors.dart';

class FactoriesListScreen extends ConsumerStatefulWidget {
  const FactoriesListScreen({super.key});

  @override
  ConsumerState<FactoriesListScreen> createState() => _FactoriesListScreenState();
}

class _FactoriesListScreenState extends ConsumerState<FactoriesListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final factoriesAsync = ref.watch(factoriesListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'المصانع',
          style: TextStyle(
            color: AppColors.brand700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: AppColors.ink700),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.brand700),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      // ‎-1‎: قائمة المصانع ليست إحدى وجهات التنقّل الثلاث. كانت 0 فتُضيء
      // "الرئيسية" والمستخدم ليس فيها. الشريط يبقى ليسهل الخروج، لكنه
      // لا يدّعي موقعاً.
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: -1),
      body: factoriesAsync.when(
        loading: () => const LoadingList(),
        error: (error, stack) => ErrorStateView(
          message: 'حدث خطأ في تحميل المصانع',
          onRetry: () => ref.invalidate(factoriesListProvider),
        ),
        data: (factories) {
          final filteredFactories = factories.where((f) {
            if (_searchQuery.isEmpty) return true;
            return f.factoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (f.area?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                (f.ownerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          }).toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(factoriesListProvider.future),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // 1. Search & Filter Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          decoration: const InputDecoration(
                            hintText: 'بحث عن مصنع...',
                            hintStyle: TextStyle(fontSize: 14, color: AppColors.ink500),
                            prefixIcon: Icon(Icons.search_rounded, color: AppColors.ink300, size: 22),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune_rounded, color: AppColors.brand800, size: 22),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تفعيل التصفية التلقائية')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 2. Subheader & Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المصانع المتاحة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${filteredFactories.length} مصنع',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brand800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. Factory Cards List
                if (filteredFactories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: EmptyState(
                      title: 'لا توجد نتائج مطابقة',
                      message: 'جرب البحث باسم مصنع آخر أو منطقة أخرى.',
                      icon: Icons.factory_outlined,
                    ),
                  )
                else
                  ...filteredFactories.map((factory) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: FactoryCard(
                          factory: factory,
                          onTap: () => context.push(
                            '${AppRoutes.clientOrderCreate}?factoryId=${factory.factoryId}',
                          ),
                        ),
                      )),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
