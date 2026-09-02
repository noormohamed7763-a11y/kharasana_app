import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  // ============================================================
  // App
  // ============================================================

  static const String appName = 'خرسانة';
  static const int defaultPageSize = 20;
  static const String currencySymbol = 'ر.ي';
  static const String yemenPhonePrefix = '+967';

  // ============================================================
  // API
  // ============================================================

  /// Base URL for the API.
  ///
  /// Priority:
  /// 1. API_BASE_URL passed with --dart-define
  /// 2. Web (Chrome)       -> localhost:5000
  /// 3. Android            -> 10.0.2.2:5000
  /// 4. Other platforms    -> local network IP
  static String get baseUrlDev {
    // ----------------------------------------------------------
    // 1. Explicit URL from --dart-define
    // Example:
    // flutter run -d chrome \
    //   --dart-define=API_BASE_URL=http://localhost:5000
    // ----------------------------------------------------------
    const fromEnv = String.fromEnvironment('API_BASE_URL');

    if (fromEnv.isNotEmpty) {
      return _normalizeBaseUrl(fromEnv);
    }

    // ----------------------------------------------------------
    // 2. Flutter Web / Chrome
    // ----------------------------------------------------------
    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    // ----------------------------------------------------------
    // 3. Android Emulator
    // ----------------------------------------------------------
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    }

    // ----------------------------------------------------------
    // 4. Physical device / local network
    // ----------------------------------------------------------
    return 'http://192.168.8.154:5000';
  }

  /// Ensures that the base URL does not end with '/'.
  ///
  /// This prevents URLs such as:
  /// http://localhost:5000//api/Factories
  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/')
        ? url.substring(0, url.length - 1)
        : url;
  }

  // ============================================================
  // Debug Mode
  // ============================================================

  static bool get isDebugMode {
    var debugMode = false;

    assert(() {
      debugMode = true;
      return true;
    }());

    return debugMode;
  }
}