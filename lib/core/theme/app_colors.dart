import 'package:flutter/material.dart';

/// ألوان التطبيق — المصدر الوحيد للحقيقة.
///
/// لا يجوز كتابة `Color(0xFF…)` في أي شاشة أو widget. سبب القاعدة عملي لا
/// جمالي: قبل هذا التوحيد كان في المشروع ٥٣ لوناً مكتوباً يدوياً في ١٤ ملفاً،
/// ولوحتان متنافستان لا تتفقان حتى على لون الهوية، وستّة أزواج تفشل في معيار
/// التباين WCAG AA — أخطرها شرائح حالة الطلب، وهي أكثر عنصر يُقرأ في التطبيق.
///
/// كل زوج (نص/خلفية) هنا مقيس. النسب المذكورة في التعليقات محسوبة بمعادلة
/// السطوع النسبي في WCAG 2.1، والحدّ المطلوب 4.5:1 للنص العادي و3:1 للنص
/// الكبير والعناصر غير النصّية.
///
/// الطبقتان: سلّم خام (ink / brand / surface) ثم أسماء دلالية تشير إليه.
/// استخدم الأسماء الدلالية في الواجهة؛ السلّم للحالات الخاصة فقط.
class AppColors {
  AppColors._();

  // ==========================================================================
  // ١) السلّم الخام
  // ==========================================================================

  // --- الهوية: برتقالي محروق دافئ (طين/خرسانة) ---------------------------
  /// أغمق درجة — عنوان على خلفية برتقالية فاتحة.
  static const Color brand900 = Color(0xFF3E1A00);

  /// لون الهوية الأساسي للنصوص والأيقونات. 7.01:1 على [ground].
  static const Color brand800 = Color(0xFF8A3C04);

  /// نص هوية أفتح قليلاً. 5.57:1 على [ground]، و6.11:1 مع الأبيض.
  static const Color brand700 = Color(0xFF9E4A06);

  /// الدرجة التفاعلية: الوحيدة التي تحمل نصاً أبيض بأمان. 5.18:1.
  static const Color brand600 = Color(0xFFC2410C);

  /// تعبئة/أيقونات كبيرة فقط — مع الأبيض 3.79:1، لا يكفي لنص عادي.
  static const Color brand500 = Color(0xFFE65100);

  /// زخرفي بحت (تدرّجات، حدود، مؤشرات). مع الأبيض 2.82:1 — لا نص أبداً.
  static const Color brand400 = Color(0xFFFF6D00);

  /// أفتح — تعبئة شرائح ومساحات نشطة.
  static const Color brand100 = Color(0xFFFFE0C2);

  /// أخف تلوين للهوية.
  static const Color brand50 = Color(0xFFFFF0E0);

  // --- الحبر: رمادي دافئ يوافق أرضية الكريم -------------------------------
  /// نص أساسي. 14.12:1 على [ground] — أعلى بكثير من المطلوب، مقصود لأن
  /// التطبيق يُستخدم في الشمس المباشرة على أجهزة رخيصة.
  static const Color ink900 = Color(0xFF2C221E);

  /// نص ثانوي قوي / نص على خلفيات ملوّنة فاتحة. 7.68:1 على [ground].
  static const Color ink700 = Color(0xFF5A4A42);

  /// نص ثانوي. 4.82:1 على [ground] و5.29:1 على الأبيض.
  static const Color ink500 = Color(0xFF7A685E);

  /// حالة معطَّلة فقط (3.73:1 — النص المعطَّل مستثنى من WCAG)، وأيقونات زخرفية.
  static const Color ink300 = Color(0xFF8C7A70);

  /// عناصر غير نصّية باهتة: حدود، فواصل داخلية، أيقونات ثانوية.
  static const Color ink200 = Color(0xFFA08E84);

  // --- الأسطح: أرضية كريم دافئة ------------------------------------------
  static const Color ground = Color(0xFFFBF3EC);
  static const Color white = Color(0xFFFFFFFF);

  /// سطح بديل شديد الفتحة (بطاقات على أرضية بيضاء).
  static const Color surfaceAlt = Color(0xFFFCF7F2);

  /// سطح خافت (أشرطة تنقّل، رؤوس أقسام).
  static const Color surfaceSubtle = Color(0xFFFAF4EE);

  /// سطح غائر (حقول، صفوف ملخّص).
  static const Color surfaceSunken = Color(0xFFF9EDE2);

  /// تلوين وردي خفيف لمناطق التحذير الناعمة.
  static const Color surfaceSoftPink = Color(0xFFFCEDE8);

  // --- الحدود ------------------------------------------------------------
  static const Color border = Color(0xFFEFE5DC);
  static const Color borderWarm = Color(0xFFEEDCD0);
  static const Color borderStrong = Color(0xFFD4C2B4);
  static const Color borderAccent = Color(0xFFE5CFBD);
  static const Color borderError = Color(0xFFF2CFC4);

  // --- الظلّ ---------------------------------------------------------------
  /// لون أساس الظلال، يُستخدم دائماً مع `withValues(alpha: …)`.
  ///
  /// موجود كرمز لا لتغيير الشكل — قيمته أسود صريح كما كانت `Colors.black` —
  /// بل ليصبح للظلال مكان واحد. الظلّ الأسود على أرضية كريم يميل إلى الرمادي
  /// المتّسخ، ودرجة دافئة ([ink900]) أنسب للوحة؛ لكن ذلك تغيير بصري في ٢٣
  /// موضعاً فتُركَ قراراً منفصلاً بعد فحص على جهاز.
  static const Color shadow = Color(0xFF000000);

  // ==========================================================================
  // ٢) الأسماء الدلالية — استخدم هذه في الواجهة
  // ==========================================================================

  /// اللون التفاعلي: خلفيات الأزرار، الروابط، الحالة النشطة.
  ///
  /// كان [brand400] فيفشل مع النص الأبيض عند 2.82:1. النقل إلى [brand600]
  /// ليس تنازلاً جمالياً: أكثر من ثلاثين موضعاً في الشاشات كان يستخدم
  /// #8A3C04 و#9E4A06 أصلاً، فالتطبيق كان يظهر بهذه الدرجة الغامقة فعلاً
  /// و#FF6D00 هو الشاذ.
  static const Color primary = brand600;

  /// درجة أغمق للحالة المضغوطة والعناوين.
  static const Color primaryDark = brand800;

  /// تعبئة فاتحة لخلفيات الشرائح والأيقونات النشطة.
  static const Color primaryLight = brand100;

  /// تعبئة زخرفية فقط — تدرّجات ومؤشرات لا تحمل نصاً.
  static const Color primaryVivid = brand400;

  static const Color background = ground;
  static const Color surface = white;
  static const Color surfaceMuted = surfaceSunken;
  static const Color divider = border;

  static const Color textPrimary = ink900;
  static const Color textSecondary = ink500;

  /// نص ثانوي على سطح ملوّن أو غائر، حيث لا يكفي [ink500].
  static const Color textTertiary = ink700;

  static const Color textOnPrimary = white;
  static const Color textDisabled = ink300;

  // ==========================================================================
  // ٣) ألوان الحالة
  // ==========================================================================
  // كل زوج نص/خلفية أدناه مقيس ويجتاز AA. الأصل كان يفشل في خمسة من ستة:
  // التحذير 1.85:1، المحايد 2.22:1، والمعلومة والخطأ تحت الحد.

  /// 4.56:1 على [successBg]، و5.13:1 مع الأبيض.
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color successBorder = Color(0xFFC8E6C9);

  /// كان #F9A825 على #FFF8E1 = 1.85:1 — أسوأ فشل في التطبيق. الآن 6.01:1.
  static const Color warning = Color(0xFF8A5200);
  static const Color warningBg = Color(0xFFFFF8E1);

  /// كان #1E88E5 = 3.36:1 على خلفيته. الآن 7.44:1، و8.50:1 مع الأبيض.
  static const Color info = Color(0xFF0B4E8A);
  static const Color infoBg = Color(0xFFE3F2FD);
  static const Color infoBorder = Color(0xFFD7EEF7);

  /// كان #D32F2F = 4.13:1 على خلفيته — قريب لكنه دون الحد. الآن 6.44:1.
  static const Color error = Color(0xFFA3261E);
  static const Color errorBg = Color(0xFFFDECEA);

  /// كان #9E9E9E رمادياً بارداً على أرضية دافئة و2.22:1. الآن 6.78:1.
  static const Color neutralBadge = ink700;
  static const Color neutralBadgeBg = border;
}
