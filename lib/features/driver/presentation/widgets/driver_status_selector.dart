import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_enums.dart';
import '../providers/driver_providers.dart';

/// شريحة تبديل حالة توفّر السائق.
///
/// تُقرأ من [SessionUser] المحلي (لا شبكة، لأن قراءتها من الخادم محظورة
/// حالياً بـ 403)، وتُحدَّث عبر [driverStatusUpdateProvider].
class DriverStatusSelector extends ConsumerStatefulWidget {
  const DriverStatusSelector({super.key, required this.currentStatus});
  final DriverStatus? currentStatus;

  @override
  ConsumerState<DriverStatusSelector> createState() => _DriverStatusSelectorState();
}

class _DriverStatusSelectorState extends ConsumerState<DriverStatusSelector> {
  bool _isUpdating = false;

  Future<void> _changeStatus(DriverStatus status) async {
    if (status == widget.currentStatus || _isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      await ref.read(driverStatusUpdateProvider(status).future);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحديث حالتك، حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'حالتك الحالية',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink500),
          ),
          const SizedBox(height: 10),
          if (_isUpdating)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Row(
              children: DriverStatus.values.map((status) {
                final isSelected = widget.currentStatus == status;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _changeStatus(status),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? status.color.withValues(alpha: 0.12)
                            : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? status.color : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            status.icon,
                            size: 20,
                            color: isSelected ? status.color : AppColors.ink300,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status.arabicLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? status.color : AppColors.ink500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}