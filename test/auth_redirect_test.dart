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

  group('resolveAuthRedirect — أدوار غير مغطّاة (سلوك حالي موثَّق)', () {
    // `UserRole` فيه أربعة أدوار (admin, factoryEmployee, driver, client)
    // لكن الحماية تشترط 'driver' أو 'client' نصّاً، فبقية الأدوار — ودورٌ
    // مفقود — تمرّ إلى مسارات الطرفين. هذه الاختبارات تُثبّت الواقع كما هو
    // حتى لا يتغيّر صمتاً؛ تشديدها قرار منتج (سيُخرج المدير وموظف المصنع
    // من واجهة العميل التي يستخدمانها اليوم).
    test('المدير يمرّ إلى مسارات العميل والسائق', () async {
      final admin = _FakeStorage(token: 'jwt', role: 'admin');
      expect(await resolveAuthRedirect(admin, AppRoutes.clientHome), isNull);
      expect(await resolveAuthRedirect(admin, AppRoutes.driverHome), isNull);
    });

    test('موظف المصنع يمرّ إلى مسارات العميل والسائق', () async {
      final employee = _FakeStorage(token: 'jwt', role: 'FactoryEmployee');
      expect(await resolveAuthRedirect(employee, AppRoutes.clientHome), isNull);
      expect(await resolveAuthRedirect(employee, AppRoutes.driverHome), isNull);
    });

    test('جلسة بلا دور مخزَّن تمرّ إلى مسارات الطرفين', () async {
      final noRole = _FakeStorage(token: 'jwt');
      expect(await resolveAuthRedirect(noRole, AppRoutes.clientHome), isNull);
      expect(await resolveAuthRedirect(noRole, AppRoutes.driverHome), isNull);
    });

    test('الدور حسّاس لحالة الأحرف: "Client" لا يُطابق "client"', () async {
      final cased = _FakeStorage(token: 'jwt', role: 'Client');
      // لا يُمنع من مسارات السائق، ويُوجَّه من شاشة الدخول إلى رئيسية العميل
      // (لأن الفرع الأخير هو else) — فالمطابقة النصّية هنا هشّة.
      expect(await resolveAuthRedirect(cased, AppRoutes.driverHome), isNull);
      expect(
        await resolveAuthRedirect(cased, AppRoutes.login),
        AppRoutes.clientHome,
      );
    });
  });
}
