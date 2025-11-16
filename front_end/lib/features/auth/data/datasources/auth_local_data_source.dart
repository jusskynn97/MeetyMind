// features/auth/data/datasources/auth_local_data_source.dart
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  static const _tokenKey = 'auth_token';

  AuthLocalDataSourceImpl(this.prefs);

  @override
  Future<void> saveToken(String token) => prefs.setString(_tokenKey, token);

  @override
  Future<String?> getToken() => Future.value(prefs.getString(_tokenKey));

  @override
  Future<void> clearToken() => prefs.remove(_tokenKey);
}