import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/utils/result.dart';

/// مُبدِّل حالة توفّر السائق (متاح / مشغول / غير متصل).
///
/// ⏸️ غير مُستخدَم حالياً — مُعطَّل بسبب الخادم، لا بسبب خطأ في هذا الملف:
///   • `PUT /api/Users/{id}/driver-status` → 403 لدور Driver (حتى على سجله)
///   • ولا توجد أي طريقة لقراءة الحالة الحالية (`GET /api/Users/me` → 405،
///     `GET /api/Users/{id}` → 403)
///
/// لإعادة تشغيله بعد منح دور Driver الصلاحية في الخادم:
///   1. أضف مصدراً لقراءة الحالة (`GET /api/Users/me`).
///   2. أعِد تركيب هذه الودجت في أعلى `DriverHomeScreen` بدل `_DriverGreeting`.
/// شكل جسم الطلب صحيح ومُتحقَّق منه مقابل مخطط `UpdateDriverStatusDto`.
class DriverStatusSelector extends ConsumerStatefulWidget {
  const DriverStatusSelector({
    super.key,
    required this.userId,
    required this.currentStatus,
    this.onStatusChanged,
  });

  final int userId;
  final DriverStatus? currentStatus;

  /// يُنادى بعد نجاح التحديث، ليتيح للشاشة الحاضنة إعادة قراءة الحالة.
  final ValueChanged<DriverStatus>? onStatusChanged;

  @override
  ConsumerState<DriverStatusSelector> createState() =>
      _DriverStatusSelectorState();
}

class _DriverStatusSelectorState extends ConsumerState<DriverStatusSelector> {
  bool _isUpdating = false;

  Future<void> _changeStatus(DriverStatus status) async {
    if (_isUpdating || status == widget.currentStatus) return;
    setState(() => _isUpdating = true);

    final result = await ref
        .read(profileRepositoryProvider)
        .updateDriverStatus(widget.userId, status);

    if (!mounted) return;
    setState(() => _isUpdating = false);

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case Success():
        // TODO: أعِد قراءة الحالة من الخادم هنا بعد إضافة `GET /api/Users/me`،
        // حتى تُعرض الحالة كما سجّلها الخادم فعلاً وليس كما اخترناها محلياً.
        widget.onStatusChanged?.call(status);
        messenger.showSnackBar(
          SnackBar(content: Text('تم تحديث حالتك إلى: ${status.arabicLabel}')),
        );
      case Error(failure: final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.messageAr)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('حالتك الحالية', style: AppTextStyles.inputLabel),
          const SizedBox(height: AppSpacing.sm),
          if (_isUpdating)
            const SizedBox(
              height: 62,
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else
            Row(
              children: [
                for (final status in DriverStatus.values)
                  Expanded(
                    child: _StatusOption(
                      status: status,
                      isSelected: widget.currentStatus == status,
                      onTap: () => _changeStatus(status),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final DriverStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon => switch (status) {
        DriverStatus.available => Icons.check_circle_outline,
        DriverStatus.busy => Icons.local_shipping_outlined,
        DriverStatus.offline => Icons.pause_circle_outline,
      };

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? status.color : AppColors.textSecondary;
    return Padding(
      // symmetric حتى لا يتأثر التوزيع باتجاه RTL
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? status.color.withAlpha(25) : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isSelected ? status.color : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(_icon, size: AppSizes.iconSm, color: color),
              const SizedBox(height: AppSpacing.xs),
              Text(
                status.arabicLabel,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
