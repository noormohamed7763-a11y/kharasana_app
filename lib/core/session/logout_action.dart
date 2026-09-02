import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../../features/authentication/presentation/providers/auth_controller.dart';
import '../../features/driver/presentation/providers/driver_status_controller.dart';

/// تسجيل خروج واحد لكلّ الشاشات: تأكيد، ثمّ إنهاء الجلسة، ثمّ العودة للدخول.
///
/// كان مكرّراً في أربع شاشات بسلوكين مختلفين: شاشة العميل الرئيسية تسأل قبل
/// الخروج، والثلاث الأخرى تُنهي الجلسة من أوّل لمسة — وزرّ الخروج فيها مجاور
/// لزرّ الإشعارات في شريط علوي واحد، على تطبيق يُستخدم بيد واحدة في موقع
/// البناء. فالتأكيد يصير هنا لكلّ الشاشات.
///
/// وكانت كلّها تنادي `SecureStorageService.clearSession()` مباشرةً بدل
/// [AuthController.logout]، فتُمحى الجلسة من التخزين وتبقى `AuthState` على
/// `AuthAuthenticated` — حالة تقول إنّ المستخدم داخل وهو خارج.
Future<void> confirmAndLogout(BuildContext context, WidgetRef ref) async {
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
  if (leave != true || !context.mounted) return;

  await ref.read(authControllerProvider.notifier).logout();

  // حالة توفّر السائق ليست `autoDispose` عن قصد (تبقى ثابتة بين تبويبَيه)،
  // فبدون إبطالها يرث السائق التالي حالة سابقه معروضةً على الشاشة.
  ref.invalidate(driverStatusControllerProvider);

  if (!context.mounted) return;
  context.go(AppRoutes.login);
}
