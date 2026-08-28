import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String tag, String message) {
    if (!kReleaseMode) {
      developer.log(message, name: 'ℹ️ $tag');
    }
  }

  static void warning(String tag, String message) {
    if (!kReleaseMode) {
      developer.log(message, name: '⚠️ $tag');
    }
  }

  static void error(String tag, Object error, [StackTrace? stackTrace, String? context]) {
    if (!kReleaseMode) {
      developer.log(
        context ?? 'حدث خطأ',
        name: '🔴 $tag',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }

  static void apiRequest(String method, String path, {dynamic data}) {
    if (!kReleaseMode) {
      developer.log('$method $path\nBody: ${_redact(data)}', name: '🌐 API →');
    }
  }

  static void apiResponse(String method, String path, int? statusCode) {
    if (!kReleaseMode) {
      developer.log('$method $path → [$statusCode]', name: '🌐 API ←');
    }
  }

  static void apiError(String method, String path, int? statusCode, dynamic responseBody) {
    if (!kReleaseMode) {
      developer.log(
        '$method $path → [$statusCode]\nResponse: ${_redact(responseBody)}',
        name: '🔴 API ✗',
      );
    }
  }

  static dynamic _redact(dynamic data) {
    if (data is Map) {
      final copy = Map<String, dynamic>.from(data);
      for (final key in ['password', 'confirmPassword', 'token']) {
        if (copy.containsKey(key)) copy[key] = '***';
      }
      return copy;
    }
    return data;
  }
}
