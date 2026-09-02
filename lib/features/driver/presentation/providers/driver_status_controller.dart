import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/api_enums.dart';
import '../../../../core/utils/result.dart';
import '../../../users/domain/repositories/profile_repository.dart';

/// حالة شريحة توفّر السائق.
///
/// الحقول الثلاثة منفصلة عمداً: [current] ما يراه السائق مضاءً الآن،
/// و[pending] ما يُرسَل إلى الخادم في هذه اللحظة (تُرسم عليه دائرة انتظار
/// دون إخفاء بقية الشرائح)، و[error] رسالة تُعرض مرة واحدة ثم تُمسح.
class DriverStatusState {
  const DriverStatusState({
    this.current,
    this.pending,
    this.error,
    this.isConfirmed = false,
  });

  /// الحالة المعروضة. `null` فقط أثناء القراءة الأولى من التخزين.
  final DriverStatus? current;

  /// الحالة الجاري إرسالها إلى الخادم الآن.
  final DriverStatus? pending;

  /// رسالة فشل آخر محاولة.
  final String? error;

  /// هل [current] قادمة من كتابة ناجحة سابقة (تخزين) لا من الافتراض؟
  ///
  /// تمييزها ضروري: إن كانت مفترضة فقد تخالف ما لدى الخادم فعلاً، فيجب
  /// السماح بإعادة إرسال القيمة نفسها لمزامنتها بدل تجاهل الضغطة.
  final bool isConfirmed;

  bool get isInitializing => current == null;
  bool get isSending => pending != null;
}

/// المالك الوحيد لحالة توفّر السائق.
///
/// نُقلت من `FutureProvider.family` لأن ذلك النمط كان يخزّن نتيجة كل حالة
/// على حدة (فيتخطّى الطلب الشبكي عند إعادة اختيارها) ويعيد تنفيذ الطلب لو
/// تغيّر أي provider يعتمد عليه بـ `watch`. الإجراءات ليست بيانات مُخزَّنة.
class DriverStatusController extends StateNotifier<DriverStatusState> {
  DriverStatusController(this._repository, this._storage)
      : super(const DriverStatusState()) {
    _restore();
  }

  final ProfileRepository _repository;
  final SecureStorageService _storage;

  /// الحالة المفترَضة قبل أول تحديث ناجح.
  ///
  /// لا سبيل لقراءتها من الخادم حالياً: استجابة `POST /api/Auth/login` لا
  /// تتضمّن `driverStatus`، و`GET /api/Users/{id}` يرجع 403 لدور Driver.
  /// `available` هي القيمة 0 في تعداد الخادم — أي القيمة الافتراضية لعمود
  /// جديد — فهي أقرب تخمين متاح، ويبقى مُعلَّماً بأنه غير مؤكَّد.
  static const _assumedStatus = DriverStatus.available;

  Future<void> _restore() async {
    final index = await _storage.readDriverStatus();
    final isStored =
        index != null && index >= 0 && index < DriverStatus.values.length;
    if (!mounted) return;
    state = DriverStatusState(
      current: isStored ? DriverStatus.values[index] : _assumedStatus,
      isConfirmed: isStored,
    );
  }

  /// يبدّل الحالة مع إضاءة الشريحة فوراً، ويتراجع عنها إن فشل الطلب.
  Future<void> select(DriverStatus next) async {
    final previous = state.current;
    final wasConfirmed = state.isConfirmed;

    if (previous == null || state.isSending) return;
    // إعادة اختيار الحالة نفسها مسموحة ما دامت مفترَضة لا مؤكَّدة، لأنها
    // قد تكون مخالفة لما لدى الخادم فتحتاج مزامنة.
    if (next == previous && wasConfirmed) return;

    state = DriverStatusState(current: next, pending: next);

    final userId = await _storage.readUserId();
    if (userId == null) {
      if (!mounted) return;
      state = DriverStatusState(
        current: previous,
        isConfirmed: wasConfirmed,
        error: const UnauthorizedFailure().messageAr,
      );
      return;
    }

    final result = await _repository.updateDriverStatus(userId, next);
    if (!mounted) return;

    switch (result) {
      case Success():
        await _storage.saveDriverStatus(next.index);
        if (!mounted) return;
        state = DriverStatusState(current: next, isConfirmed: true);
      case Error(failure: final failure):
        state = DriverStatusState(
          current: previous,
          isConfirmed: wasConfirmed,
          error: failure.messageAr,
        );
    }
  }

  /// تُستدعى بعد عرض رسالة الخطأ حتى لا تتكرّر مع كل إعادة بناء.
  void clearError() {
    if (state.error == null) return;
    state = DriverStatusState(
      current: state.current,
      pending: state.pending,
      isConfirmed: state.isConfirmed,
    );
  }
}

/// غير `autoDispose` عمداً: الحالة يجب أن تبقى ثابتة أثناء التنقّل بين
/// تبويبَي السائق. تُبطَل يدوياً عند تسجيل الخروج فقط.
final driverStatusControllerProvider =
    StateNotifierProvider<DriverStatusController, DriverStatusState>((ref) {
  return DriverStatusController(
    ref.watch(profileRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
});
