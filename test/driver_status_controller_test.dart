import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kharasana_app/core/errors/failure.dart';
import 'package:kharasana_app/core/storage/secure_storage_service.dart';
import 'package:kharasana_app/core/utils/api_enums.dart';
import 'package:kharasana_app/core/utils/result.dart';
import 'package:kharasana_app/features/driver/presentation/providers/driver_status_controller.dart';
import 'package:kharasana_app/features/users/data/models/user_dto.dart';
import 'package:kharasana_app/features/users/domain/repositories/profile_repository.dart';

/// تخزين مزيّف في الذاكرة: نورّث الصنف الحقيقي ونتجاوز ما يقرأه/يكتبه
/// المتحكّم فقط، فلا نحتاج حزمة mock ولا تخزيناً فعلياً على الجهاز.
class _FakeStorage extends SecureStorageService {
  _FakeStorage({this.userId = 7, int? statusIndex})
      : _statusIndex = statusIndex,
        super(const FlutterSecureStorage());

  final int? userId;
  int? _statusIndex;

  /// كل كتابة ناجحة للحالة تُسجَّل هنا للتحقق من أنها لم تُحفظ عند الفشل.
  final List<int> writes = [];

  @override
  Future<int?> readUserId() async => userId;

  @override
  Future<int?> readDriverStatus() async => _statusIndex;

  @override
  Future<void> saveDriverStatus(int statusIndex) async {
    _statusIndex = statusIndex;
    writes.add(statusIndex);
  }
}

/// مستودع مزيّف يسجّل ما أُرسل ويعيد نتيجة محدَّدة مسبقاً.
class _FakeRepository implements ProfileRepository {
  _FakeRepository({this.result = const Success<void>(null)});

  Result<void> result;
  final List<DriverStatus> sent = [];

  @override
  Future<Result<void>> updateDriverStatus(int userId, DriverStatus status) async {
    sent.add(status);
    return result;
  }

  @override
  Future<Result<UserDto>> getMyProfile() => throw UnimplementedError();

  @override
  Future<Result<void>> updateMyProfile({
    String? fullName,
    String? phone,
    String? whatsApp,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();
}

/// ينتظر انتهاء `_restore()` الذي يبدأ في المُنشئ.
Future<DriverStatusController> _boot(
  _FakeRepository repository,
  _FakeStorage storage,
) async {
  final controller = DriverStatusController(repository, storage);
  await Future<void>.delayed(Duration.zero);
  return controller;
}

void main() {
  group('DriverStatusController — القراءة الأولى', () {
    test('يفترض «متاح» غير مؤكَّدة حين لا توجد حالة محفوظة', () async {
      // بدون هذا كانت الحالة تبقى null فلا تُضيء أي شريحة بعد تسجيل الدخول،
      // لأن الخادم لا يرسل driverStatus في استجابة الدخول ولا يسمح بقراءته.
      final controller = await _boot(_FakeRepository(), _FakeStorage());
      addTearDown(controller.dispose);

      expect(controller.state.current, DriverStatus.available);
      expect(controller.state.isConfirmed, isFalse);
      expect(controller.state.isInitializing, isFalse);
    });

    test('يستعيد الحالة المحفوظة ويعلّمها مؤكَّدة', () async {
      final controller = await _boot(
        _FakeRepository(),
        _FakeStorage(statusIndex: DriverStatus.busy.index),
      );
      addTearDown(controller.dispose);

      expect(controller.state.current, DriverStatus.busy);
      expect(controller.state.isConfirmed, isTrue);
    });

    test('يتجاهل فهرساً خارج المدى بدل أن يرمي RangeError', () async {
      final controller = await _boot(_FakeRepository(), _FakeStorage(statusIndex: 99));
      addTearDown(controller.dispose);

      expect(controller.state.current, DriverStatus.available);
      expect(controller.state.isConfirmed, isFalse);
    });
  });

  group('DriverStatusController — التبديل', () {
    test('«مشغول» تُرسَل وتُحفظ وتصبح مؤكَّدة', () async {
      final repository = _FakeRepository();
      final storage = _FakeStorage(statusIndex: DriverStatus.available.index);
      final controller = await _boot(repository, storage);
      addTearDown(controller.dispose);

      await controller.select(DriverStatus.busy);

      expect(repository.sent, [DriverStatus.busy]);
      expect(storage.writes, [DriverStatus.busy.index]);
      expect(controller.state.current, DriverStatus.busy);
      expect(controller.state.isConfirmed, isTrue);
      expect(controller.state.isSending, isFalse);
    });

    test('«غير متصل» تُرسَل بقيمة التعداد نفسها التي يتوقعها الخادم', () async {
      final repository = _FakeRepository();
      final controller = await _boot(repository, _FakeStorage());
      addTearDown(controller.dispose);

      await controller.select(DriverStatus.offline);

      expect(repository.sent.single.toApiValue(), 2);
      expect(controller.state.current, DriverStatus.offline);
    });

    test('عند فشل الطلب تعود الحالة السابقة ولا يُحفَظ شيء', () async {
      final repository = _FakeRepository(result: const Error(ServerFailure()));
      final storage = _FakeStorage(statusIndex: DriverStatus.available.index);
      final controller = await _boot(repository, storage);
      addTearDown(controller.dispose);

      await controller.select(DriverStatus.busy);

      expect(controller.state.current, DriverStatus.available);
      expect(controller.state.isConfirmed, isTrue);
      expect(storage.writes, isEmpty);
      expect(controller.state.error, const ServerFailure().messageAr);
    });

    test('إعادة اختيار حالة مؤكَّدة لا تُرسِل طلباً', () async {
      final repository = _FakeRepository();
      final controller = await _boot(
        repository,
        _FakeStorage(statusIndex: DriverStatus.busy.index),
      );
      addTearDown(controller.dispose);

      await controller.select(DriverStatus.busy);

      expect(repository.sent, isEmpty);
    });

    test('إعادة اختيار حالة مفترَضة تُرسِل طلباً للمزامنة', () async {
      // الحالة المفترَضة قد تخالف ما لدى الخادم، فتجاهل الضغطة يترك
      // السائق عاجزاً عن تصحيحها.
      final repository = _FakeRepository();
      final controller = await _boot(repository, _FakeStorage());
      addTearDown(controller.dispose);

      await controller.select(DriverStatus.available);

      expect(repository.sent, [DriverStatus.available]);
      expect(controller.state.isConfirmed, isTrue);
    });

    test('بلا معرّف مستخدم: لا طلب، وتظهر رسالة انتهاء الجلسة', () async {
      final repository = _FakeRepository();
      final controller = await _boot(repository, _FakeStorage(userId: null));
      addTearDown(controller.dispose);

      await controller.select(DriverStatus.busy);

      expect(repository.sent, isEmpty);
      expect(controller.state.current, DriverStatus.available);
      expect(controller.state.error, const UnauthorizedFailure().messageAr);
    });

    test('clearError يمسح الرسالة ويُبقي الحالة', () async {
      final repository = _FakeRepository(result: const Error(ServerFailure()));
      final controller = await _boot(repository, _FakeStorage());
      addTearDown(controller.dispose);

      await controller.select(DriverStatus.busy);
      expect(controller.state.error, isNotNull);

      controller.clearError();

      expect(controller.state.error, isNull);
      expect(controller.state.current, DriverStatus.available);
    });
  });
}
