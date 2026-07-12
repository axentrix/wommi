import 'dart:html' as html;

/// Device-specific storage for remembering last logged-in email
/// Uses browser's localStorage for Flutter Web
class DeviceStorage {
  static const String _keyEmail = 'last_logged_in_email';

  /// Store email on device
  static Future<void> saveEmail(String email) async {
    html.window.localStorage[_keyEmail] = email;
  }

  /// Get stored email from device
  static Future<String?> getEmail() async {
    return html.window.localStorage[_keyEmail];
  }

  /// Clear stored email (on logout/delete account)
  static Future<void> clearEmail() async {
    html.window.localStorage.remove(_keyEmail);
  }

  /// Check if device has a stored email
  static Future<bool> hasStoredEmail() async {
    final email = await getEmail();
    return email != null && email.isNotEmpty;
  }
}
