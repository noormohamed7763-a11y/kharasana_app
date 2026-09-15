import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_state.dart';
import '../../data/models/factory_dto.dart';

/// تفاصيل مصنع واحد للعميل: الشعار، معلومات الاتصال، وزر إنشاء طلب.
///
/// مساران للوصول:
/// 1. من بطاقة القائمة عبر `extra` — الـ [FactoryDto] جاهز، فيُعرض فوراً
///    بلا إعادة جلب (القائمة تحمل كل الحقول، فطلب آخر مضيعة بلا داعٍ).
/// 2. فتح المسار مباشرةً بـ `:id` (استعادة الحالة أو deep link) حيث لا
///    يتوفّر `extra` — يُجلب المصنع من الخادم حسب المعرّف عبر
///    [factoryByIdProvider].
class FactoryDetailsScreen extends ConsumerWidget {
  const FactoryDetailsScreen({super.key, this.factory, this.factoryId});

  final FactoryDto? factory;

  /// معرّف المصنع عند الفتح المباشر للمسار دون كائن جاهز.
  final int? factoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          factory?.factoryName ?? 'تفاصيل المصنع',
          style: const TextStyle(
            color: AppColors.brand700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final known = factory;
    if (known != null) return _FactoryBody(factory: known);

    final id = factoryId;
    if (id == null) {
      return const Center(
        child: Text(
          'بيانات المصنع غير متاحة',
          style: TextStyle(color: AppColors.ink500),
        ),
      );
    }

    final factoryAsync = ref.watch(factoryByIdProvider(id));
    return factoryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorStateView(
        message: failureMessage(error),
        onRetry: () => ref.invalidate(factoryByIdProvider(id)),
      ),
      data: (factory) => _FactoryBody(factory: factory),
    );
  }
}

/// محتوى الصفحة لمصنف معلوم — يُرسم فور توفّر الكيان (جاهزاً أو جُلِب).
class _FactoryBody extends StatelessWidget {
  const _FactoryBody({required this.factory});

  final FactoryDto factory;

  Future<void> _launch(BuildContext context, Uri uri) async {
    var launched = false;
    try {
      launched = await launchUrl(uri);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح هذا الإجراء من هذا الجهاز.')),
      );
    }
  }

  /// يحوّل رقماً قد يأتي بصيغة «+967 …» إلى أرقام فقط لـ wa.me.
  static String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ١) الشعار
          Center(child: _logoHero()),
          const SizedBox(height: 18),

          // ٢) الاسم وحالة النشاط
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  factory.factoryName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: factory.isActive ? AppColors.successBg : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                factory.isActive ? 'مصنع نشط' : 'غير نشط',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: factory.isActive ? AppColors.success : AppColors.ink500,
                ),
              ),
            ),
          ),
          if (factory.ownerName != null && factory.ownerName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'المالك',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.ink500),
            ),
            const SizedBox(height: 2),
            Text(
              factory.ownerName!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.ink900,
              ),
            ),
          ],
          const SizedBox(height: 22),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 18),

          // ٣) معلومات الاتصال والموقع
          if (factory.phone != null && factory.phone!.isNotEmpty)
            _InfoTile(
              icon: Icons.phone_outlined,
              iconColor: AppColors.success,
              label: 'رقم الموبايل',
              value: factory.phone!,
              onTap: () => _launch(
                context,
                Uri(scheme: 'tel', path: factory.phone),
              ),
            ),
          if (factory.whatsApp != null && factory.whatsApp!.isNotEmpty)
            _InfoTile(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: AppColors.success,
              label: 'واتساب',
              value: factory.whatsApp!,
              onTap: () => _launch(
                context,
                Uri.parse('https://wa.me/${_digitsOnly(factory.whatsApp!)}'),
              ),
            ),
          if (factory.email != null && factory.email!.isNotEmpty)
            _InfoTile(
              icon: Icons.mail_outline_rounded,
              iconColor: AppColors.info,
              label: 'البريد الإلكتروني',
              value: factory.email!,
              onTap: () => _launch(
                context,
                Uri(scheme: 'mailto', path: factory.email),
              ),
            ),
          if (factory.area != null && factory.area!.isNotEmpty)
            _InfoTile(
              icon: Icons.location_on_outlined,
              iconColor: AppColors.brand500,
              label: 'المنطقة',
              value: factory.area!,
            ),
          if (factory.address != null && factory.address!.isNotEmpty)
            _InfoTile(
              icon: Icons.map_outlined,
              iconColor: AppColors.brand500,
              label: 'العنوان',
              value: factory.address!,
            ),
          const SizedBox(height: 26),

          // ٤) زر إنشاء طلب من هذا المصنع
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.push(
                '${AppRoutes.clientOrderCreate}?factoryId=${factory.factoryId}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_road_rounded, size: 20),
              label: const Text(
                'اطلب خرسانة الآن',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// شعار المصنع بحجم كبير، مع سقوط احتياطي على أيقونة المصنع.
  Widget _logoHero() {
    final logo = factory.logo;
    return Container(
      width: 140,
      height: 140,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: (logo == null || logo.isEmpty)
          ? _logoHeroFallback()
          : CachedNetworkImage(
              imageUrl: logo,
              fit: BoxFit.cover,
              placeholder: (_, __) => _logoHeroFallback(),
              errorWidget: (_, __, ___) => _logoHeroFallback(),
            ),
    );
  }

  Widget _logoHeroFallback() => Container(
        color: AppColors.surfaceSunken,
        alignment: Alignment.center,
        child: const Icon(
          Icons.factory_rounded,
          color: AppColors.brand800,
          size: 64,
        ),
      );
}

/// صفّ معلومة: أيقونة، عنوان، قيمة، ولمسة اختيارية.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.ink500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: content,
              ),
            ),
    );
  }
}