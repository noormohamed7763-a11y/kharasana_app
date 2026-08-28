import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../client/presentation/widgets/client_bottom_nav_bar.dart';
import '../providers/orders_list_controller.dart';
import '../widgets/order_card.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  final _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'جديد', 'قيد المراجعة', 'تم التسليم'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(ordersListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersListControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'طلباتي',
          style: TextStyle(
            color: Color(0xFF9E4A06),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF5A4A42)),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF9E4A06)),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 1),
      body: switch (state) {
        OrdersListInitial() || OrdersListLoading() => const LoadingList(),
        OrdersListError(message: final message) => ErrorStateView(
            message: message,
            onRetry: () => ref.read(ordersListControllerProvider.notifier).loadFirstPage(),
          ),
        OrdersListLoaded(items: final items, isLoadingMore: final loadingMore) => Column(
            children: [
              // 1. Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEFE5DC)),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: const InputDecoration(
                      hintText: 'بحث برقم الطلب أو اسم المشروع...',
                      hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF8C7A70)),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF8C7A70), size: 22),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // 2. Filter Chips
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;

                    return ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF7A685E),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF8A3C04),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF8A3C04) : const Color(0xFFEFE5DC),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // 3. Filtered Orders List
              Expanded(
                child: Builder(
                  builder: (context) {
                    final filteredItems = items.where((order) {
                      final matchesSearch = _searchQuery.isEmpty ||
                          order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          order.factoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          order.concreteTypeName.toLowerCase().contains(_searchQuery.toLowerCase());

                      if (!matchesSearch) return false;

                      if (_selectedFilter == 'الكل') return true;
                      if (_selectedFilter == 'جديد') {
                        return order.status == OrderStatus.newOrder;
                      }
                      if (_selectedFilter == 'قيد المراجعة') {
                        return order.status == OrderStatus.pending || order.status == OrderStatus.approved;
                      }
                      if (_selectedFilter == 'تم التسليم') {
                        return order.status == OrderStatus.delivered || order.status == OrderStatus.closed;
                      }

                      return true;
                    }).toList();

                    if (filteredItems.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => ref.read(ordersListControllerProvider.notifier).refresh(),
                        child: const SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: EmptyState(
                              title: 'لا توجد طلبات مطابقة',
                              message: 'لم يتم العثور على أي طلبات في هذه الحالة.',
                              icon: Icons.receipt_long_outlined,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => ref.read(ordersListControllerProvider.notifier).refresh(),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        itemCount: filteredItems.length + (loadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= filteredItems.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final order = filteredItems[index];
                          return OrderCard(
                            order: order,
                            onTap: () => context.push('/client/orders/${order.orderId}'),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      },
    );
  }
}