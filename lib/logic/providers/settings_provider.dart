import 'package:flutter/foundation.dart';
import '../../data/models/settings_model.dart';
import '../../data/local/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  Future<void> loadSettings() async {
    _settings = await SettingsService.getSettings();
    notifyListeners();
  }

  Future<void> updateSnoozeTime(int minutes) async {
    _settings = _settings.copyWith(snoozeMinutes: minutes);
    await SettingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAlarmSound(String sound) async {
    _settings = _settings.copyWith(alarmSound: sound);
    await SettingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateVibration(bool enabled) async {
    _settings = _settings.copyWith(vibration: enabled);
    await SettingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateShowOnLockScreen(bool enabled) async {
    _settings = _settings.copyWith(showOnLockScreen: enabled);
    await SettingsService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updatePersistentNotification(bool enabled) async {
    _settings = _settings.copyWith(persistentNotification: enabled);
    await SettingsService.saveSettings(_settings);
    notifyListeners();
  }
}
