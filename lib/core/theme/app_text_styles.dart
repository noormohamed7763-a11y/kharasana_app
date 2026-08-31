import 'package:flutter/material.dart';
import 'app_colors.dart';

/// أنماط النصوص — المصدر الوحيد للحقيقة.
///
/// السلّم: 32 / 28 / 22 / 18 / 16 / 14 / 12. رُفع عن الأصل (26/20/17/15/13/11)
/// لسببين مقيسين لا ذوقيين:
///
/// ١) 16px هو الحدّ الأدنى لنصّ المتن على الهاتف. ما دونه يجعل قارئ الطلب
///    يُقرّب الشاشة، والتطبيق يُستخدم بيد واحدة وبقفّازات في موقع بناء.
/// ٢) الخط Cairo عربي، وارتفاع محارفه الفعلي أصغر من نظيره اللاتيني بنفس
///    القياس بسبب التشكيل والنقاط، فـ 11px تقرأ فعلياً كـ 9px لاتينية.
///
/// كل نمط يحمل `height` صريحاً. كانت خمسة أنماط بلا ارتفاع سطر فتقع على
/// افتراض المحرّك، والعربية تحتاج فسحة أكبر: 1.7 للمتن مقابل 1.5 اللاتينية،
/// لأن الهمزات والتشكيل تمتد فوق خط الأساس والنقاط تحته.
///
/// 12px هو الأرضية المطلقة. كان في الشاشات مقاس 10px ومقاسات كسرية
/// (11.5 / 12.5 / 13.5 / 14.5) — أي عشرون مقاساً مختلفاً حيث السلّم سبعة.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Cairo';

  /// درجة العرض: اسم التطبيق في شاشة البداية وشاشة الدخول فقط.
  /// خارج سلّم المحتوى — لا تُستخدم داخل الشاشات التشغيلية.
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.7,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );

  /// شريحة الحالة. 12px هو الحدّ الأدنى المطلق؛ كانت 11px.
  static const TextStyle badgeText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// أرقام في أعمدة: أسعار، كميات، معرّفات طلبات.
  ///
  /// الأرقام اللاتينية في Cairo عرضها ثابت (560/1000 em) فتتراصف الأعمدة
  /// أصلاً. لا نُضيف `FontFeature.tabularFigures()` لأن ملفات الخط لا تحتوي
  /// جدول `tnum` — الاستدعاء بلا أثر وقد يُوهم بضمانة غير موجودة.
  ///
  /// ولا يجوز تحويل الأرقام إلى هندية (٠-٩): عرضها في Cairo يتراوح بين 250
  /// و678 وحدة، أي فرق يقارب ثلاثة أمثال، فتنهار كل أعمدة الأسعار.
  static const TextStyle numeric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
}
