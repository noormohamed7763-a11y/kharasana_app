import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ---------------- UserRole ----------------
enum UserRole {
  admin,
  factoryEmployee,
  driver,
  client;

  static UserRole fromApiString(String value) {
    return switch (value) {
      'Admin' => UserRole.admin,
      'FactoryEmployee' => UserRole.factoryEmployee,
      'Driver' => UserRole.driver,
      'Client' => UserRole.client,
      _ => throw ArgumentError('Unknown UserRole: $value'),
    };
  }

  static UserRole fromApiValue(int value) => UserRole.values[value];
  int toApiValue() => index;

  String get arabicLabel => switch (this) {
        UserRole.admin => 'مدير النظام',
        UserRole.factoryEmployee => 'موظف مصنع',
        UserRole.driver => 'سائق',
        UserRole.client => 'عميل',
      };
}

// ---------------- DriverStatus ----------------
enum DriverStatus {
  available,
  busy,
  offline;

  static DriverStatus fromApiValue(int value) => DriverStatus.values[value];
  int toApiValue() => index;

  String get arabicLabel => switch (this) {
        DriverStatus.available => 'متاح',
        DriverStatus.busy => 'مشغول',
        DriverStatus.offline => 'غير متصل',
      };

  Color get color => switch (this) {
        DriverStatus.available => AppColors.success,
        DriverStatus.busy => AppColors.warning,
        DriverStatus.offline => AppColors.neutralBadge,
      };

  /// أيقونة مميّزة لكل حالة، فلا تُحمَل المعلومة على اللون وحده.
  IconData get icon => switch (this) {
        DriverStatus.available => Icons.check_circle_outline_rounded,
        DriverStatus.busy => Icons.local_shipping_rounded,
        DriverStatus.offline => Icons.cloud_off_rounded,
      };
}

// ---------------- TransportMethod ----------------
enum TransportMethod {
  factoryTransport,
  clientOwnTransport;

  static TransportMethod fromApiValue(int value) => TransportMethod.values[value];
  int toApiValue() => index;

  String get arabicLabel => switch (this) {
        TransportMethod.factoryTransport => 'نقل عبر المصنع',
        TransportMethod.clientOwnTransport => 'نقل ذاتي (العميل)',
      };

  /// كانت الأيقونة إيموجي داخل النصّ نفسه (‏🚛 و🚗). ذلك خطأ لثلاثة أسباب:
  /// شكل الإيموجي يتغيّر بين أندرويد و‏iOS وبين إصداراتهما فتفقد الهوية
  /// تماسكها؛ وقارئ الشاشة ينطق اسمه الكامل ("شاحنة ثقيلة") قبل النصّ
  /// المفيد؛ ولا يمكن تلوينه ولا قياسه مع سلّم الخط. الأيقونة تخرج من
  /// النصّ إلى طبقة العرض.
  IconData get icon => switch (this) {
        TransportMethod.factoryTransport => Icons.local_shipping_rounded,
        TransportMethod.clientOwnTransport => Icons.directions_car_rounded,
      };
}

// ---------------- SlabType ----------------
enum SlabType {
  foundation,
  columns,
  beams,
  roof,
  other;

  static SlabType fromApiValue(int value) => SlabType.values[value];
  int toApiValue() => index;

  String get arabicLabel => switch (this) {
        SlabType.foundation => 'أساسات',
        SlabType.columns => 'أعمدة',
        SlabType.beams => 'كمرات',
        SlabType.roof => 'سقف',
        SlabType.other => 'أخرى',
      };
}

// ---------------- OrderStatus ----------------
enum OrderStatus {
  newOrder,
  pending,
  approved,
  rejected,
  cancelled,
  onTheWay,
  delivered,
  closed;

  static OrderStatus fromApiValue(String value) {
    return switch (value) {
      'New' => OrderStatus.newOrder,
      'Pending' => OrderStatus.pending,
      'Approved' => OrderStatus.approved,
      'Rejected' => OrderStatus.rejected,
      'Cancelled' => OrderStatus.cancelled,
      'OnTheWay' => OrderStatus.onTheWay,
      'Delivered' => OrderStatus.delivered,
      'Closed' => OrderStatus.closed,
      _ => throw ArgumentError('Unknown OrderStatus: $value'),
    };
  }

  String toApiValue() => switch (this) {
        OrderStatus.newOrder => 'New',
        OrderStatus.pending => 'Pending',
        OrderStatus.approved => 'Approved',
        OrderStatus.rejected => 'Rejected',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.onTheWay => 'OnTheWay',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.closed => 'Closed',
      };

  String get arabicLabel => switch (this) {
        OrderStatus.newOrder => 'طلب جديد',
        OrderStatus.pending => 'قيد المراجعة',
        OrderStatus.approved => 'تمت الموافقة',
        OrderStatus.rejected => 'مرفوض',
        OrderStatus.cancelled => 'ملغي',
        OrderStatus.onTheWay => 'في الطريق',
        OrderStatus.delivered => 'تم التسليم',
        OrderStatus.closed => 'مكتمل',
      };

  Color get color => switch (this) {
        OrderStatus.newOrder => AppColors.neutralBadge,
        OrderStatus.pending => AppColors.warning,
        OrderStatus.approved => AppColors.info,
        OrderStatus.rejected => AppColors.error,
        OrderStatus.cancelled => AppColors.error,
        OrderStatus.onTheWay => AppColors.info,
        OrderStatus.delivered => AppColors.success,
        OrderStatus.closed => AppColors.success,
      };

  Color get backgroundColor => switch (this) {
        OrderStatus.newOrder => AppColors.neutralBadgeBg,
        OrderStatus.pending => AppColors.warningBg,
        OrderStatus.approved => AppColors.infoBg,
        OrderStatus.rejected => AppColors.errorBg,
        OrderStatus.cancelled => AppColors.errorBg,
        OrderStatus.onTheWay => AppColors.infoBg,
        OrderStatus.delivered => AppColors.successBg,
        OrderStatus.closed => AppColors.successBg,
      };

  /// أيقونة مميّزة لكل حالة من الثماني.
  ///
  /// الألوان أعلاه خمسة فقط، فثلاثة أزواج تتقاسم اللون نفسه: "تمت الموافقة"
  /// و"في الطريق" أزرق، و"مرفوض" و"ملغي" أحمر، و"تم التسليم" و"مكتمل" أخضر.
  /// بلا أيقونة يضطر السائق إلى قراءة نصّ كل شريحة ليفرّق بينها — وهو يقرأ
  /// عشرات الطلبات في الشاشة الواحدة. الأيقونة تُعيد المسح البصري السريع،
  /// وتُغني عن اللون لمن لا يميّز الأحمر من الأخضر.
  IconData get icon => switch (this) {
        OrderStatus.newOrder => Icons.fiber_new_rounded,
        OrderStatus.pending => Icons.hourglass_top_rounded,
        OrderStatus.approved => Icons.verified_outlined,
        OrderStatus.rejected => Icons.block_rounded,
        OrderStatus.cancelled => Icons.remove_circle_outline_rounded,
        OrderStatus.onTheWay => Icons.local_shipping_rounded,
        OrderStatus.delivered => Icons.check_circle_outline_rounded,
        OrderStatus.closed => Icons.task_alt_rounded,
      };
}