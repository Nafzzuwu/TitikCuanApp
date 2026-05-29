import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _nameKey = 'user_name';
  static const _businessKey = 'business_name';
  static const _profilePictureKey = 'profile_picture';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserInfo({
    required int userId,
    required String name,
    required String businessName,
    String? profilePicture,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_businessKey, businessName);
    if (profilePicture != null) {
      await prefs.setString(_profilePictureKey, profilePicture);
    }
  }

  static Future<void> saveProfilePicture(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePictureKey, url);
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getInt(_userIdKey),
      'name': prefs.getString(_nameKey),
      'business_name': prefs.getString(_businessKey),
      'profile_picture': prefs.getString(_profilePictureKey),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
