import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EnvironmentService {
  // ============================================================
  // اكتشاف عنوان IP الخاص بالجهاز
  // ============================================================
  static Future<String> getLocalIpAddress() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet)) {
        // محاولة الحصول على IP عبر NetworkInterface
        for (final interface in await NetworkInterface.list()) {
          for (final address in interface.addresses) {
            // البحث عن عنوان IPv4 محلي (ليس loopback)
            if (address.type == InternetAddressType.IPv4 &&
                !address.address.startsWith('127.') &&
                !address.address.startsWith('169.254')) {
              return address.address;
            }
          }
        }
      }
      return '10.0.2.2'; // القيمة الافتراضية
    } catch (_) {
      return '10.0.2.2';
    }
  }

  // ============================================================
  // هل يعمل على Android Emulator؟
  // ============================================================
  static bool get isAndroidEmulator {
    if (!Platform.isAndroid) return false;
    // في Android Emulator، بعض الخصائص تشير إلى ذلك
    try {
      // قراءة ملف خاصية الجهاز
      const emulatorCheck = String.fromEnvironment('EMULATOR');
      return emulatorCheck.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // الحصول على رابط API المناسب
  // ============================================================
  static Future<String> getApiBaseUrl() async {
    // 1. إذا كان الرابط محدداً عبر --dart-define
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    // 2. إذا كان يعمل على Web
    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    // 3. إذا كان يعمل على Android Emulator
    if (Platform.isAndroid && isAndroidEmulator) {
      return 'http://10.0.2.2:5000';
    }

    // 4. إذا كان يعمل على Android حقيقي
    if (Platform.isAndroid) {
      final ip = await getLocalIpAddress();
      return 'http://$ip:5000';
    }

    // 5. إذا كان يعمل على iOS
    if (Platform.isIOS) {
      final ip = await getLocalIpAddress();
      return 'http://$ip:5000';
    }

    // 6. Desktop (Windows, Mac, Linux)
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:5000';
    }

    // 7. القيمة الافتراضية
    return 'http://10.0.2.2:5000';
  }
}