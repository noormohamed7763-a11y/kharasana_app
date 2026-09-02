import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_enums.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    final storage = ref.read(secureStorageProvider);
    final hasSession = await storage.hasActiveSession();

    if (!hasSession) {
      if (!mounted) return;
      context.go(AppRoutes.login);
      return;
    }

    final role = await storage.readRole();
    if (!mounted) return;

    // الأدوار الثلاثة صريحة: كان الفرع `else` يرسل كلّ دور غير السائق إلى
    // واجهة العميل — ومنها المدير وموظف المصنع ودورٌ لم يُخزَّن أصلاً — فيردّهم
    // حارس الراوتر إلى شاشة الدخول فيرتدّ المستخدم بين شاشتين عند كل تشغيل.
    if (role == UserRole.driver.name) {
      context.go(AppRoutes.driverHome);
    } else if (role == UserRole.client.name) {
      context.go(AppRoutes.clientHome);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping, size: 80, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'خَرَسَانَة',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}