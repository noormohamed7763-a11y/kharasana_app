import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_enums.dart';
import '../providers/driver_status_controller.dart';

/// شريحة تبديل حالة توفّر السائق (متاح / مشغول / غير متصل).
///
/// كانت هذه الشريحة سابقاً تُبنى داخل `sessionUserProvider.when(...)`، فكان
/// إبطال ذلك المزوّد بعد كل تحديث ناجح يُعيده إلى حالة التحميل ويهدم الشريحة
/// من شجرة الواجهة ثم يبنيها من جديد — فتبدو الضغطة كأنها لم تفعل شيئاً.
/// الآن تقرأ من [driverStatusControllerProvider] الذي يحتفظ بالحالة بنفسه.
class DriverStatusSelector extends ConsumerWidget {
  const DriverStatusSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(driverStatusControllerProvider);
    final controller = ref.read(driverStatusControllerProvider.notifier);

    // الخطأ يُعرَض مرة واحدة بعد اكتمال الإطار، ثم يُمسح من الحالة حتى لا
    // يتكرّر مع كل إعادة بناء لاحقة.
    ref.listen<DriverStatusState>(driverStatusControllerProvider, (_, next) {
      final error = next.error;
      if (error == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      controller.clearError();
    });

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'حالتك الحالية',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink500,
                ),
              ),
              const Spacer(),
              if (state.current != null)
                Text(
                  state.current!.arabicLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: state.current!.color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: DriverStatus.values.map((status) {
              return Expanded(
                child: _StatusChip(
                  status: status,
                  isSelected: state.current == status,
                  isSending: state.pending == status,
                  // أثناء الإرسال تُعطَّل الشرائح كلها لمنع طلبين متزامنين،
                  // لكنها تبقى مرئية بدل استبدالها بمؤشّر تحميل واحد.
                  isEnabled: !state.isSending && !state.isInitializing,
                  onTap: () => controller.select(status),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.isSelected,
    required this.isSending,
    required this.isEnabled,
    required this.onTap,
  });

  final DriverStatus status;
  final bool isSelected;
  final bool isSending;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? status.color : AppColors.ink500;

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: status.arabicLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: isSelected
              ? status.color.withValues(alpha: 0.12)
              : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? status.color : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: isSending
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: status.color,
                          )
                        : Icon(
                            status.icon,
                            size: 20,
                            color: isSelected ? status.color : AppColors.ink300,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.arabicLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
