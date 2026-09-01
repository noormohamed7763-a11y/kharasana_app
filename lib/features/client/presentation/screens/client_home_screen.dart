import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../orders/data/models/order_summary_dto.dart';
import '../../../orders/presentation/providers/orders_list_controller.dart';
import '../widgets/client_bottom_nav_bar.dart';

/// أقصى عدد طلبات يظهر في شريط «آخر الطلبات» الأفقي.
const int _maxRecentOrders = 3;

/// ارتفاع بطاقة الطلب الأساسي — يُضرب في مقياس خطّ المستخدم.
const double _recentCardHeight = 160;

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  /// يُقرأ مرّة واحدة، لا في كلّ `build`.
  ///
  /// كان `FutureBuilder(future: storage.readFullName())` مكتوباً داخل build،
  /// أي أنّ Future جديداً يُنشأ مع كلّ إعادة بناء — وحالة الطلبات وحدها تعيد
  /// البناء ثلاث مرّات (Initial ← Loading ← Loaded) — فيرتدّ الاسم المعروض إلى
  /// «عميلنا العزيز» ثم يعود، ومعه قراءة جديدة من التخزين المشفَّر كلّ مرّة.
  late final Future<String?> _fullName;

  @override
  void initState() {
    super.initState();
    _fullName = ref.read(secureStorageProvider).readFullName();
  }

  /// السحب للتحديث.
  ///
  /// كان: `ref.refresh(ordersListControllerProvider.notifier).refresh()`.
  /// و`refresh` على `.notifier` يتلف الـnotifier ويبني واحداً جديداً،
  /// وباني `OrdersListController` ينادي `loadFirstPage()` بنفسه — ثم ينادي
  /// السطر `.refresh()` عليه مرّة ثانية: طلبَا شبكة لكلّ سحبة واحدة.
  /// و`ref.refresh(factoriesListProvider.future)` كان طلباً ثالثاً مهدوراً:
  /// المزوّد `autoDispose` ولا أحد في هذه الشاشة يراقبه، فتُجلب المصانع
  /// ثم يُتلَف الناتج فوراً دون أن يراه أحد.
  Future<void> _refresh() =>
      ref.read(ordersListControllerProvider.notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الرئيسية',
          style: TextStyle(
            color: AppColors.brand700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.ink700,
          ),
          tooltip: 'الإشعارات',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا توجد إشعارات جديدة')),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.brand700),
            tooltip: 'تسجيل الخروج',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ١) الترحيب
              FutureBuilder<String?>(
                future: _fullName,
                builder: (context, snapshot) {
                  final name = snapshot.data ?? 'عميلنا العزيز';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أهلاً بك،',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.ink500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'مرحباً $name',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink900,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // ٢) إجراءات سريعة
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'المصانع',
                      subtitle: 'استكشف مصانع\nالخرسانة',
                      icon: Icons.factory_rounded,
                      onTap: () => context.push(AppRoutes.clientFactories),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'طلباتي',
                      subtitle: 'متابعة حالة الطلبات\nوالشحنات',
                      icon: Icons.receipt_long_rounded,
                      onTap: () => context.push(AppRoutes.clientOrders),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // ٣) آخر الطلبات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'آخر الطلبات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink900,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.clientOrders),
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: AppColors.brand700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _recentOrders(ordersState),
              const SizedBox(height: 24),

              // ٤) البطاقة الترويجية
              const _PromoCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// لكلّ حالة فرعها الخاص.
  ///
  /// كان الفرع الجامع `_` يعرض «لا توجد طلبات جارية» لحالات التحميل والخطأ
  /// أيضاً، فيُخبر المستخدم أنّه لا يملك طلبات وهو لا يعلم: عند انقطاع
  /// الشبكة تُبتلع رسالة الخطأ ولا يبقى للمستخدم زرّ إعادة محاولة، وعند
  /// كلّ فتح للشاشة تظهر «لا توجد طلبات» لحظةً قبل أن تصل البطاقات.
  Widget _recentOrders(OrdersListState state) {
    return switch (state) {
      OrdersListInitial() || OrdersListLoading() => const _OrdersNotice(
          title: 'جارٍ تحميل طلباتك…',
          message: 'لحظة واحدة.',
          showSpinner: true,
        ),
      OrdersListError(message: final message) => _OrdersNotice(
          icon: Icons.cloud_off_rounded,
          iconColor: AppColors.error,
          iconBackground: AppColors.errorBg,
          title: 'تعذّر تحميل الطلبات',
          message: message,
          action: TextButton(
            onPressed: _refresh,
            style: TextButton.styleFrom(foregroundColor: AppColors.brand700),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      OrdersListLoaded(items: final items) when items.isEmpty => _OrdersNotice(
          title: 'لا توجد طلبات جارية',
          message: 'أنشئ طلبك الأول واطلب خرسانة الآن بكل سهولة',
          // البطاقة نفسها تقود إلى ما تدعو إليه؛ نصّها كان يطلب إنشاء طلب
          // دون أن يكون فيها ما يُلمس.
          onTap: () => context.push(AppRoutes.clientOrderCreate),
        ),
      OrdersListLoaded(items: final items) => _RecentOrdersCarousel(
          items: items.take(_maxRecentOrders).toList(),
        ),
    };
  }

  Future<void> _confirmLogout() async {
    // زرّ الخروج كان ينهي الجلسة من أول لمسة، وهو مجاور لزرّ الإشعارات في
    // شريط علوي واحد على شاشة يُستخدم فيها التطبيق بيد واحدة في الموقع.
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (leave != true || !mounted) return;

    await ref.read(secureStorageProvider).clearSession();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }
}

// ============================================================================
// الشريط الأفقي لآخر الطلبات
// ============================================================================

class _RecentOrdersCarousel extends StatelessWidget {
  const _RecentOrdersCarousel({required this.items});

  final List<OrderSummaryDto> items;

  @override
  Widget build(BuildContext context) {
    // الارتفاع ثابت لأنّ قائمة أفقية تحتاج قيداً رأسياً، لكن محتواها نصّ
    // يكبر مع إعداد حجم الخطّ في النظام؛ ارتفاع ١٦٠ الجامد يفيض عند
    // تكبير الخطّ. السقف ٢٤٠ يمنع البطاقة من أن تأكل الشاشة.
    final height = MediaQuery.textScalerOf(context)
        .scale(_recentCardHeight)
        .clamp(_recentCardHeight, 240.0);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final order = items[index];
          return _RecentOrderCard(
            orderNumber: order.orderNumber,
            concreteType: order.concreteTypeName,
            factoryName: order.factoryName,
            status: order.status,
            onTap: () => context.push('/client/orders/${order.orderId}'),
          );
        },
      ),
    );
  }
}

/// بطاقة إشعار أفقية في مكان الشريط: تحميل، خطأ، أو لا طلبات.
class _OrdersNotice extends StatelessWidget {
  const _OrdersNotice({
    required this.title,
    required this.message,
    this.icon = Icons.receipt_long_outlined,
    this.iconColor = AppColors.brand500,
    this.iconBackground = AppColors.brand50,
    this.showSpinner = false,
    this.action,
    this.onTap,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool showSpinner;
  final Widget? action;
  final VoidCallback? onTap;

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: showSpinner
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.brand500,
                    ),
                  )
                : Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.ink500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (action != null) action!,
          if (action == null && onTap != null)
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 8),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.ink300,
              ),
            ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: _radius,
        border: Border.all(color: AppColors.border),
      ),
      child: onTap == null
          ? content
          : _InkOverlay(radius: _radius, onTap: onTap!, child: content),
    );
  }
}

// ============================================================================
// البطاقة الترويجية
// ============================================================================

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  static const _radius = BorderRadius.all(Radius.circular(22));

  @override
  Widget build(BuildContext context) {
    return Container(
      // الظلّ يبقى على الحاوية الخارجية: لو وُضع داخل ClipRRect لاقتُصّ معها.
      decoration: BoxDecoration(
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // القصّ ضروري: `BoxDecoration.borderRadius` يدوّر ما ترسمه الحاوية
      // نفسها فقط، ولا يقصّ أبناءها. فأيقونة الخلفية (١٦٠ بكسل عند
      // left/bottom: -20) كانت ترسم في الأركان المستديرة وخارج التدرّج،
      // فتظهر بقعة بيضاء شفّافة على أرضية الصفحة عند الزاوية السفلية.
      child: ClipRRect(
        borderRadius: _radius,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            // التدرّج يحمل نصاً أبيض، فلا يجوز أن يبدأ من brand400:
            // الأبيض عليه 2.82:1 والأبيض الشفّاف 2.05:1 — أسوأ فشل تباين
            // كان في التطبيق، في أبرز بطاقة بالشاشة. brand600←brand800
            // يعطي الأبيض 5.18:1 عند أفتح طرف و7.70:1 عند أغمقه.
            gradient: LinearGradient(
              colors: [AppColors.brand600, AppColors.brand800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                left: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.architecture_rounded,
                    size: 160,
                    color: AppColors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'وفّر في مشروعك القادم',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'احصل على عروض حصرية من أفضل مصانع الخرسانة في منطقتك عند الطلب عبر التطبيق.',
                      style: TextStyle(
                        // معتم لا 0.9: الشفافية تنزل به إلى 4.48:1، أي
                        // تحت الحد بفرق لا يُرى لكنه يُقاس.
                        color: AppColors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              context.push(AppRoutes.clientFactories),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brand900,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'اكتشف العروض',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.clientOrderCreate),
                          icon: const Icon(
                            Icons.add,
                            color: AppColors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'إنشاء طلب جديد',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// بطاقات
// ============================================================================

/// طبقة لمس فوق تلوين البطاقة.
///
/// `InkWell` يرسم موجة اللمس على أقرب `Material` أعلاه — أي على مادة الشاشة،
/// أسفل خلفية البطاقة المعتمة — فلا يُرى للمس أثر. هذا الـMaterial الشفّاف
/// يجعل الموجة ترسم فوق التلوين لا تحته، دون تغيير أي لون.
class _InkOverlay extends StatelessWidget {
  const _InkOverlay({
    required this.radius,
    required this.onTap,
    required this.child,
  });

  final BorderRadius radius;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(onTap: onTap, borderRadius: radius, child: child),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: _radius,
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: _InkOverlay(
        radius: _radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.borderWarm,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.brand800, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.ink500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({
    required this.orderNumber,
    required this.concreteType,
    required this.factoryName,
    required this.status,
    required this.onTap,
  });

  final String orderNumber;
  final String concreteType;
  final String factoryName;
  final OrderStatus status;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: _radius,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _InkOverlay(
        radius: _radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رقم الطلب وشريحة الحالة
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brand50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$orderNumber',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppColors.brand800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: status),
                ],
              ),

              const Spacer(),

              // نوع الخرسانة
              Text(
                concreteType,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink900,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // المصنع
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSunken,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.factory_rounded,
                      size: 12,
                      color: AppColors.ink300,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      factoryName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.ink500,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.ink300,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}