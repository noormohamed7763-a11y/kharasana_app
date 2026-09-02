import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharasana_app/core/router/app_router.dart';
import 'package:kharasana_app/core/router/app_routes.dart';
import 'package:kharasana_app/core/storage/secure_storage_service.dart';

/// تخزين مزيّف: نورّث الصنف الحقيقي ونتجاوز الدالتين اللتين يقرأهما
/// الراوتر فقط، فلا نحتاج حزمة mock ولا تخزيناً فعلياً على الجهاز.
class _FakeStorage extends SecureStorageService {
  _FakeStorage({this.token, this.role}) : super(const FlutterSecureStorage());

  final String? token;
  final String? role;

  @override
  Future<bool> hasActiveSession() async => token != null && token!.isNotEmpty;

  @override
  Future<String?> readRole() async => role;
}

void main() {
  group('resolveAuthRedirect — بلا جلسة', () {
    final storage = _FakeStorage();

    test('يسمح بشاشة البداية دائماً', () async {
      expect(await resolveAuthRedirect(storage, AppRoutes.splash), isNull);
    });

    test('يسمح بتسجيل الدخول والتسجيل', () async {
      expect(await resolveAuthRedirect(storage, AppRoutes.login), isNull);
      expect(await resolveAuthRedirect(storage, AppRoutes.register), isNull);
    });

    test('يمنع مسارات العميل ويحوّل إلى تسجيل الدخول', () async {
      expect(
        await resolveAuthRedirect(storage, AppRoutes.clientHome),
        AppRoutes.login,
      );
      expect(
        await resolveAuthRedirect(storage, AppRoutes.clientOrderCreate),
        AppRoutes.login,
      );
    });

    test('يمنع مسارات السائق ويحوّل إلى تسجيل الدخول', () async {
      expect(
        await resolveAuthRedirect(storage, AppRoutes.driverHome),
        AppRoutes.login,
      );
      expect(
        await resolveAuthRedirect(storage, '/driver/orders/30'),
        AppRoutes.login,
      );
    });

    test('توكن فارغ يُعامل كعدم وجود جلسة', () async {
      final empty = _FakeStorage(token: '', role: 'client');
      expect(
        await resolveAuthRedirect(empty, AppRoutes.clientHome),
        AppRoutes.login,
      );
    });
  });

  group('resolveAuthRedirect — جلسة عميل', () {
    final client = _FakeStorage(token: 'jwt', role: 'client');

    test('يُبعده عن شاشات الدخول إلى رئيسية العميل', () async {
      expect(
        await resolveAuthRedirect(client, AppRoutes.login),
        AppRoutes.clientHome,
      );
      expect(
        await resolveAuthRedirect(client, AppRoutes.register),
        AppRoutes.clientHome,
      );
    });

    test('يسمح بمسارات العميل', () async {
      expect(await resolveAuthRedirect(client, AppRoutes.clientHome), isNull);
      expect(await resolveAuthRedirect(client, AppRoutes.clientOrders), isNull);
      expect(
        await resolveAuthRedirect(client, AppRoutes.clientOrderCreate),
        isNull,
      );
    });

    test('يمنعه من مسارات السائق', () async {
      expect(
        await resolveAuthRedirect(client, AppRoutes.driverHome),
        AppRoutes.clientHome,
      );
      expect(
        await resolveAuthRedirect(client, '/driver/orders/30'),
        AppRoutes.clientHome,
      );
    });
  });

  group('resolveAuthRedirect — جلسة سائق', () {
    final driver = _FakeStorage(token: 'jwt', role: 'driver');

    test('يُبعده عن شاشات الدخول إلى رئيسية السائق', () async {
      expect(
        await resolveAuthRedirect(driver, AppRoutes.login),
        AppRoutes.driverHome,
      );
    });

    test('يسمح بمسارات السائق', () async {
      expect(await resolveAuthRedirect(driver, AppRoutes.driverHome), isNull);
      expect(await resolveAuthRedirect(driver, '/driver/orders/30'), isNull);
    });

    test('يمنعه من مسارات العميل — أهم قاعدة حماية', () async {
      expect(
        await resolveAuthRedirect(driver, AppRoutes.clientHome),
        AppRoutes.driverHome,
      );
      expect(
        await resolveAuthRedirect(driver, AppRoutes.clientOrderCreate),
        AppRoutes.driverHome,
      );
      expect(
        await resolveAuthRedirect(driver, '/client/orders/30'),
        AppRoutes.driverHome,
      );
    });
  });

  group('resolveAuthRedirect — أدوار بلا واجهة في التطبيق', () {
    // `UserRole` فيه أربعة أدوار، والتطبيق يضمّ واجهتين فقط: العميل والسائق.
    // المدير وموظف المصنع يسجّلان الدخول بنجاح في الخادم، لكن لا شاشة رئيسية
    // لهما هنا — وكذلك جلسة لم يُخزَّن دورها أو خُزِّن بحالة أحرف مختلفة.
    //
    // كانت هذه الأدوار تمرّ إلى مسارات العميل والسائق كلّها. الآن تُمنع:
    // تُردّ عن كلّ مسار محمي، وتُترك على شاشة الدخول (`null`) لا تُوجَّه
    // إليها، فلا توجيه إلى الموضع نفسه.
    test('المدير يُمنع من مسارات العميل والسائق', () async {
      final admin = _FakeStorage(token: 'jwt', role: 'admin');
      expect(
        await resolveAuthRedirect(admin, AppRoutes.clientHome),
        AppRoutes.login,
      );
      expect(
        await resolveAuthRedirect(admin, AppRoutes.driverHome),
        AppRoutes.login,
      );
    });

    test('موظف المصنع يُمنع من مسارات العميل والسائق', () async {
      final employee = _FakeStorage(token: 'jwt', role: 'FactoryEmployee');
      expect(
        await resolveAuthRedirect(employee, AppRoutes.clientHome),
        AppRoutes.login,
      );
      expect(
        await resolveAuthRedirect(employee, AppRoutes.driverHome),
        AppRoutes.login,
      );
    });

    test('جلسة بلا دور مخزَّن تُمنع من مسارات الطرفين', () async {
      final noRole = _FakeStorage(token: 'jwt');
      expect(
        await resolveAuthRedirect(noRole, AppRoutes.clientHome),
        AppRoutes.login,
      );
      expect(
        await resolveAuthRedirect(noRole, AppRoutes.driverHome),
        AppRoutes.login,
      );
    });

    test('الدور حسّاس لحالة الأحرف: "Client" لا يُطابق "client"', () async {
      // الدور يُخزَّن من `UserRole.name` (حروف صغيرة) في
      // `AuthRepositoryImpl.login`، فقيمة بحالة أحرف أخرى تعني تخزيناً
      // تالفاً — تُعامَل كدور غير معروف لا كعميل.
      final cased = _FakeStorage(token: 'jwt', role: 'Client');
      expect(
        await resolveAuthRedirect(cased, AppRoutes.driverHome),
        AppRoutes.login,
      );
      expect(
        await resolveAuthRedirect(cased, AppRoutes.clientHome),
        AppRoutes.login,
      );
    });

    test('لا توجيه إلى شاشة الدخول وهو عليها أصلاً', () async {
      // شرط بقاء المستخدم قادراً على تسجيل الدخول: لو أعاد التوجيه إلى
      // `/login` وهو على `/login` لصار الحارس يقرأ كأنه يفعل شيئاً وهو لا
      // يفعل، ويُخفي أن شاشة الدخول هي المسؤولة عن إبلاغ هذه الأدوار.
      for (final role in [null, 'admin', 'FactoryEmployee', 'Client']) {
        final storage = _FakeStorage(token: 'jwt', role: role);
        expect(
          await resolveAuthRedirect(storage, AppRoutes.login),
          isNull,
          reason: 'الدور $role يجب أن يبقى على شاشة الدخول',
        );
        expect(
          await resolveAuthRedirect(storage, AppRoutes.register),
          isNull,
          reason: 'الدور $role يجب أن يبقى على شاشة التسجيل',
        );
      }
    });
  });
}
