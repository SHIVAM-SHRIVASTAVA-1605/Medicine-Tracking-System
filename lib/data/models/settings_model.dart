class AppSettings {
  final int snoozeMinutes;
  final String alarmSound;
  final bool vibration;
  final bool showOnLockScreen;
  final bool persistentNotification;
  final int reminderFrequency; // Daily = 1, Custom days

  AppSettings({
    this.snoozeMinutes = 10,
    this.alarmSound = 'alarm_sound',
    this.vibration = true,
    this.showOnLockScreen = true,
    this.persistentNotification = false,
    this.reminderFrequency = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'snoozeMinutes': snoozeMinutes,
      'alarmSound': alarmSound,
      'vibration': vibration,
      'showOnLockScreen': showOnLockScreen,
      'persistentNotification': persistentNotification,
      'reminderFrequency': reminderFrequency,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      snoozeMinutes: json['snoozeMinutes'] ?? 10,
      alarmSound: json['alarmSound'] ?? 'alarm_sound',
      vibration: json['vibration'] ?? true,
      showOnLockScreen: json['showOnLockScreen'] ?? true,
      persistentNotification: json['persistentNotification'] ?? false,
      reminderFrequency: json['reminderFrequency'] ?? 1,
    );
  }

  AppSettings copyWith({
    int? snoozeMinutes,
    String? alarmSound,
    bool? vibration,
    bool? showOnLockScreen,
    bool? persistentNotification,
    int? reminderFrequency,
  }) {
    return AppSettings(
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      alarmSound: alarmSound ?? this.alarmSound,
      vibration: vibration ?? this.vibration,
      showOnLockScreen: showOnLockScreen ?? this.showOnLockScreen,
      persistentNotification:
          persistentNotification ?? this.persistentNotification,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
    );
  }
}
