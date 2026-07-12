import 'package:shared_preferences/shared_preferences.dart';

/// Device-specific storage for remembering last logged-in email
class DeviceStorage {
  static const String _keyEmail = 'last_logged_in_email';

  /// Store email on device
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  /// Get stored email from device
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Clear stored email (on logout/delete account)
  static Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
  }

  /// Check if device has a stored email
  static Future<bool> hasStoredEmail() async {
    final email = await getEmail();
    return email != null && email.isNotEmpty;
  }
}
