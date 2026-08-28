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
}

// ---------------- TransportMethod ----------------
enum TransportMethod {
  factoryTransport,
  clientOwnTransport;

  static TransportMethod fromApiValue(int value) => TransportMethod.values[value];
  int toApiValue() => index;

  String get arabicLabel => switch (this) {
        TransportMethod.factoryTransport => '🚛 نقل عبر المصنع',
        TransportMethod.clientOwnTransport => '🚗 نقل ذاتي (العميل)',
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
        OrderStatus.newOrder => AppColors.surfaceMuted,
        OrderStatus.pending => AppColors.warningBg,
        OrderStatus.approved => AppColors.infoBg,
        OrderStatus.rejected => AppColors.errorBg,
        OrderStatus.cancelled => AppColors.errorBg,
        OrderStatus.onTheWay => AppColors.infoBg,
        OrderStatus.delivered => AppColors.successBg,
        OrderStatus.closed => AppColors.successBg,
      };
}