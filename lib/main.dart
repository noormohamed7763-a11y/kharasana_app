import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app.dart';
import 'core/providers/core_providers.dart';
import 'core/storage/secure_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorageService(const FlutterSecureStorage());

  runApp(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(secureStorage),
      ],
      child: const KharasanaApp(),
    ),
  );
}