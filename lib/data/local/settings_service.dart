import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await _prefs!.setString(_settingsKey, jsonString);
  }

  static Future<AppSettings> getSettings() async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonString = _prefs!.getString(_settingsKey);

    if (jsonString == null) {
      return AppSettings();
    }

    try {
      final json = jsonDecode(jsonString);
      return AppSettings.fromJson(json);
    } catch (e) {
      return AppSettings();
    }
  }
}
