import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService(this._storage);
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'kharasana_jwt_token';
  static const _roleKey = 'kharasana_user_role';
  static const _userIdKey = 'kharasana_user_id';
  static const _fullNameKey = 'kharasana_user_full_name';
  static const _driverStatusKey = 'kharasana_driver_status'; // ✅ جديد

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveSession({
    required String token,
    required String role,
    required int userId,
    required String fullName,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _fullNameKey, value: fullName);
  }

  Future<String?> readRole() => _storage.read(key: _roleKey);

  Future<int?> readUserId() async {
    final raw = await _storage.read(key: _userIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<String?> readFullName() => _storage.read(key: _fullNameKey);

  /// ✅ حالة توفّر السائق مخزَّنة محلياً بعد كل تحديث ناجح فقط.
  ///
  /// السبب: GET /api/Users/{id} يرجع 403 لدور Driver في الخادم الحالي،
  /// فلا يمكن قراءة الحالة من الشبكة عند فتح التطبيق. الحفظ هنا هو مصدر
  /// الحقيقة الوحيد المتاح حتى تُصلَح صلاحية القراءة في الباك-إند.
  Future<void> saveDriverStatus(int statusIndex) =>
      _storage.write(key: _driverStatusKey, value: statusIndex.toString());

  Future<int?> readDriverStatus() async {
    final raw = await _storage.read(key: _driverStatusKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _fullNameKey);
    await _storage.delete(key: _driverStatusKey); // ✅ مسح حالة السائق
  }

  Future<bool> hasActiveSession() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }
}