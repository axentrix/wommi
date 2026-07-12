import 'dart:html' as html;
import 'dart:convert';

/// Backup storage using localStorage (more persistent than IndexedDB)
/// Stores critical user data as JSON to survive IndexedDB clearing
class LocalBackupStorage {
  static const String _keyUserProfile = 'wommi_user_profile';
  static const String _keyJourneyHistory = 'wommi_journey_history';

  /// Save user profile to localStorage backup
  static Future<void> saveUserProfile({
    required int profileId,
    required String name,
    required String email,
  }) async {
    final data = {
      'profileId': profileId,
      'name': name,
      'email': email,
      'savedAt': DateTime.now().toIso8601String(),
    };
    html.window.localStorage[_keyUserProfile] = json.encode(data);
    print('[BackupStorage] 💾 Profile saved to localStorage: $email');
  }

  /// Get user profile from localStorage backup
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final stored = html.window.localStorage[_keyUserProfile];
    if (stored == null) return null;

    try {
      final data = json.decode(stored) as Map<String, dynamic>;
      print('[BackupStorage] 📦 Profile loaded from localStorage: ${data['email']}');
      return data;
    } catch (e) {
      print('[BackupStorage] ❌ Error loading profile: $e');
      return null;
    }
  }

  /// Save journey history to localStorage backup
  static Future<void> saveJourneyHistory(List<Map<String, dynamic>> journeys) async {
    final data = {
      'journeys': journeys,
      'savedAt': DateTime.now().toIso8601String(),
    };
    html.window.localStorage[_keyJourneyHistory] = json.encode(data);
    print('[BackupStorage] 💾 ${journeys.length} journeys saved to localStorage');
  }

  /// Get journey history from localStorage backup
  static Future<List<Map<String, dynamic>>> getJourneyHistory() async {
    final stored = html.window.localStorage[_keyJourneyHistory];
    if (stored == null) return [];

    try {
      final data = json.decode(stored) as Map<String, dynamic>;
      final journeys = (data['journeys'] as List).cast<Map<String, dynamic>>();
      print('[BackupStorage] 📦 ${journeys.length} journeys loaded from localStorage');
      return journeys;
    } catch (e) {
      print('[BackupStorage] ❌ Error loading journeys: $e');
      return [];
    }
  }

  /// Clear all backup data (on account deletion)
  static Future<void> clearAll() async {
    html.window.localStorage.remove(_keyUserProfile);
    html.window.localStorage.remove(_keyJourneyHistory);
    print('[BackupStorage] 🗑️ All backup data cleared');
  }

  /// Check if backup data exists
  static Future<bool> hasBackup() async {
    return html.window.localStorage.containsKey(_keyUserProfile);
  }

  /// Get backup info for debugging
  static Future<String> getBackupInfo() async {
    final hasProfile = html.window.localStorage.containsKey(_keyUserProfile);
    final hasJourneys = html.window.localStorage.containsKey(_keyJourneyHistory);

    if (!hasProfile) return 'No backup found';

    final profile = await getUserProfile();
    final journeys = await getJourneyHistory();

    return 'Backup: ${profile?['email']} - ${journeys.length} journeys';
  }
}
