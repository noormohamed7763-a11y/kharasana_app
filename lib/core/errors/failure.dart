sealed class Failure {
  final String messageAr;
  const Failure(this.messageAr);
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('تعذر الاتصال بالخادم، تحقق من اتصال الإنترنت وحاول مرة أخرى.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('استغرق الطلب وقتًا طويلاً، يرجى المحاولة مرة أخرى.');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى.');
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure() : super('لا تملك صلاحية تنفيذ هذا الإجراء.');
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  const ValidationFailure(super.messageAr, {this.fieldErrors});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('البيانات المطلوبة غير موجودة.');
}

class ServerFailure extends Failure {
  const ServerFailure() : super('حدث خطأ في الخادم، يرجى المحاولة لاحقًا.');
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('حدث خطأ غير متوقع.');
}

/// فشل تحليل استجابة الخادم: وصلت الاستجابة بنجاح لكن شكل البيانات
/// لا يطابق ما يتوقعه التطبيق (حقل صار `null`، أو تغيّر نوعه، أو اختفى).
///
/// كان هذا النوع من الأخطاء يُبتلع سابقاً داخل `UnknownFailure`، فتظهر
/// الشاشة فارغة بلا أي دليل على السبب. الآن يُسجَّل التفصيل في وضع التطوير.
class ParseFailure extends Failure {
  const ParseFailure(this.details)
      : super('تعذر قراءة بيانات الخادم — تحقق من تطابق التطبيق مع الواجهة البرمجية.');

  final Object details;
}

/// نص الخطأ المناسب للعرض من كائن خطأ قادم من أي `provider`.
///
/// كانت هذه الدالة داخل `driver_providers.dart`، وتحتاجها شاشات العميل
/// أيضاً — فمكانها إلى جانب [Failure] نفسه.
String failureMessage(Object error) =>
    error is Failure ? error.messageAr : 'حدث خطأ غير متوقع.';