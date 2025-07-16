import 'package:shared_preferences/shared_preferences.dart';

class DocumentNumberStorage {
  static const String _timestampSuffix = '_timestamp';
  
  /// Save document number to persistent storage for a specific form
  static Future<void> saveDocumentNumber(String formKey, String documentNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(formKey, documentNumber);
      await prefs.setString('$formKey$_timestampSuffix', DateTime.now().toIso8601String());
      print('💾 Saved document number for $formKey: $documentNumber');
    } catch (e) {
      print('❌ Error saving document number for $formKey: $e');
    }
  }

  /// Load document number from persistent storage for a specific form
  static Future<String?> loadDocumentNumber(String formKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDocNumber = prefs.getString(formKey);
      final savedTimestamp = prefs.getString('$formKey$_timestampSuffix');
      
      if (savedDocNumber != null && savedTimestamp != null) {
        final savedTime = DateTime.parse(savedTimestamp);
        final now = DateTime.now();
        
        // Check if the saved document number is from today (within 24 hours)
        if (now.difference(savedTime).inHours < 24) {
          print('📂 Loaded document number for $formKey: $savedDocNumber');
          return savedDocNumber;
        } else {
          // Clear old document number if it's older than 24 hours
          await prefs.remove(formKey);
          await prefs.remove('$formKey$_timestampSuffix');
          print('🗑️ Cleared old document number for $formKey (older than 24 hours)');
        }
      }
      return null;
    } catch (e) {
      print('❌ Error loading document number for $formKey: $e');
      return null;
    }
  }

  /// Clear document number from persistent storage for a specific form
  static Future<void> clearDocumentNumber(String formKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(formKey);
      await prefs.remove('$formKey$_timestampSuffix');
      print('🗑️ Cleared document number for $formKey');
    } catch (e) {
      print('❌ Error clearing document number for $formKey: $e');
    }
  }

  /// Clear all document numbers from persistent storage
  static Future<void> clearAllDocumentNumbers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (String key in keys) {
        if (key.contains('document_number') || key.contains('_timestamp')) {
          await prefs.remove(key);
        }
      }
      print('🗑️ Cleared all document numbers from persistent storage');
    } catch (e) {
      print('❌ Error clearing all document numbers: $e');
    }
  }
}

/// Form keys for different DSR entry forms
class DocumentNumberKeys {
  static const String btlActivities = 'btl_activities_document_number';
  static const String phoneCallBuilder = 'phone_call_builder_document_number';
  static const String meetingsContractor = 'meetings_contractor_document_number';
  static const String meetingNewPurchaser = 'meeting_new_purchaser_document_number';
  static const String internalTeamMeeting = 'internal_team_meeting_document_number';
  static const String checkSamplingSite = 'check_sampling_site_document_number';
  static const String officeWork = 'office_work_document_number';
  static const String workFromHome = 'work_from_home_document_number';
  static const String onLeave = 'on_leave_document_number';
  static const String anyOtherActivity = 'any_other_activity_document_number';
} 