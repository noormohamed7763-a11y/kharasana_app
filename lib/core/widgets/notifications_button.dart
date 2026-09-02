import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// زرّ الإشعارات في شريط الشاشات العلوي.
///
/// كان مكرّراً في سبع شاشات بثلاثة سلوكيات: شاشتان تعرضان رسالة (بنصّين
/// مختلفين: «إشعارات» و«تنبيهات»)، وخمس شاشات بـ`onPressed: () {}` — زرّ
/// يُضاء عند اللمس ولا يفعل شيئاً، فيقرأه المستخدم كعطل في التطبيق.
///
/// لا توجد خدمة إشعارات في الخادم بعد، فالسلوك الصادق هو إبلاغ المستخدم
/// بذلك من مكان واحد بنصّ واحد.
class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key, this.color = AppColors.ink700});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.notifications_none_rounded, color: color),
      tooltip: 'الإشعارات',
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('لا توجد إشعارات جديدة')),
          );
      },
    );
  }
}
