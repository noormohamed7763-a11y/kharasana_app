import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// تنسيق الأرقام والعملة — المصدر الوحيد للحقيقة.
///
/// كانت في المشروع ثلاث طرق لتنسيق السعر نفسه: `_money.format()` في شاشة
/// إنشاء الطلب، و`toStringAsFixed(0)` في تفاصيل الطلب وبطاقة نوع الخرسانة،
/// فالسعر الواحد يظهر `492,500` هنا و`492500` هناك. سبعة أرقام بلا فواصل
/// غير قابلة للقراءة، والاختلاف بين الشاشتين يجعل المستخدم يشكّ في الرقم.
class AppFormat {
  AppFormat._();

  /// الأرقام لاتينية بنيّة صريحة، لا افتراضاً.
  ///
  /// `NumberFormat` بلا لغة يتبع `Intl.defaultLocale`، فلو ضُبط على 'ar'
  /// انقلبت الأرقام إلى هندية (٠-٩). وهذا يهدم كل عمود سعر في التطبيق:
  /// عرض الأرقام اللاتينية في الخط Cairo ثابت (560/1000 em) فتتراصف
  /// الأعمدة، أما الهندية فعرضها يتراوح بين 250 و678 وحدة — قريب من ثلاثة
  /// أمثال — فتتذبذب حدود الأعمدة سطراً بعد سطر.
  static const String _numberLocale = 'en_US';

  static final NumberFormat _integer = NumberFormat('#,##0', _numberLocale);
  static final NumberFormat _decimal = NumberFormat('#,##0.##', _numberLocale);

  /// مبلغ بالعملة: `492,500 ر.ي`.
  static String money(num value) =>
      '${_integer.format(value)} ${AppConstants.currencySymbol}';

  /// سعر الوحدة: `25,000 ر.ي/م³`.
  static String pricePerCubicMetre(num value) =>
      '${_integer.format(value)} ${AppConstants.currencySymbol}/م³';

  /// كمية بالمتر المكعّب: `19.7 م³`. الكسور تظهر فقط إن وُجدت.
  static String cubicMetres(num value) => '${_decimal.format(value)} م³';

  /// رقم مجرّد بفواصل الآلاف، بلا وحدة.
  static String number(num value) => _integer.format(value);

  /// رقم عشري بفواصل الآلاف، بلا وحدة.
  static String decimal(num value) => _decimal.format(value);

  /// تاريخ بالعربية بأرقام لاتينية: `15 يناير 2026`.
  ///
  /// كان `DateFormat('d MMMM yyyy', 'ar')` مكتوباً في أربعة ملفات مستقلّة،
  /// وهو ينتج أرقاماً هندية (`١٥ يناير ٢٠٢٦`) لأن `DateFormat` يتبع أرقام
  /// اللغة. فكانت البطاقة الواحدة تحمل النظامين معاً: `19.75 م³` لاتينية
  /// بجوار `١٥ يناير ٢٠٢٦` هندية. اسم الشهر يبقى من `intl`، واليوم والسنة
  /// يُبنيان من الأعداد مباشرةً فتخرج لاتينية دائماً.
  ///
  /// يعتمد على تهيئة رموز تواريخ العربية، ويوفّرها
  /// `GlobalMaterialLocalizations` المسجَّل في `app.dart`.
  static String date(DateTime value) =>
      '${value.day} ${_monthName.format(value)} ${value.year}';

  static final DateFormat _monthName = DateFormat('MMMM', 'ar');
}
