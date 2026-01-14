import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/settings_model.dart';
import '../../data/local/settings_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Callback for notification actions
  static Function(String)? onNotificationAction;
  
  // Store pending actions that occurred before callback was set
  static final List<String> _pendingActions = [];

  static Future<void> loadSettings() async {
    // Settings will be loaded on-demand when needed
  }

  static Future<void> init() async {
    try {
      print('========== Initializing Notifications ==========');
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const LinuxInitializationSettings linuxSettings =
          LinuxInitializationSettings(defaultActionName: 'Open notification');

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        linux: linuxSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) async {
          try {
            print('\n\n');
            print('═══════════════════════════════════════════════════');
            print('🔔 NOTIFICATION RESPONSE DETECTED');
            print('═══════════════════════════════════════════════════');
            print('📋 Payload: ${details.payload ?? "NULL"}');
            print(
                '🎯 Action ID: ${details.actionId ?? "NULL (notification tapped)"}');
            print('📝 Input: ${details.input ?? "NULL"}');
            print('⏰ Time: ${DateTime.now()}');
            print('🔍 Notification ID: ${details.id}');
            print('───────────────────────────────────────────────────');

            // Handle notification actions
            if (details.actionId == 'snooze') {
              print('✅ SNOOZE BUTTON PRESSED!');
              print('🔍 Processing snooze action...');
              // Cancel the current notification first
              if (details.payload != null) {
                final id = int.tryParse(details.payload!);
                print('📍 Notification ID parsed: $id');
                if (id != null) {
                  await cancelNotification(id);
                  print('✅ Notification $id cancelled successfully');
                  print('📞 Calling callback: snooze_${details.payload}');
                  // Call the callback with snooze action
                  final action = 'snooze_${details.payload}';
                  if (onNotificationAction != null) {
                    onNotificationAction?.call(action);
                    print('✅ Snooze callback executed');
                  } else {
                    print('⚠️  Callback not ready, storing action for later');
                    _pendingActions.add(action);
                  }
                } else {
                  print('❌ ERROR: Could not parse notification ID');
                }
              } else {
                print('❌ ERROR: Payload is null');
              }
            } else if (details.actionId == 'dismiss') {
              print('✅ MARK TAKEN BUTTON PRESSED!');
              print('🔍 Processing mark taken action...');
              // Cancel the notification
              if (details.payload != null) {
                final id = int.tryParse(details.payload!);
                print('📍 Notification ID parsed: $id');
                if (id != null) {
                  await cancelNotification(id);
                  print('✅ Notification $id cancelled successfully');
                  print('📞 Calling callback: dismiss_${details.payload}');
                  // Call the callback with dismiss action
                  final action = 'dismiss_${details.payload}';
                  if (onNotificationAction != null) {
                    onNotificationAction?.call(action);
                    print('✅ Mark Taken callback executed');
                  } else {
                    print('⚠️  Callback not ready, storing action for later');
                    _pendingActions.add(action);
                  }
                } else {
                  print('❌ ERROR: Could not parse notification ID');
                }
              } else {
                print('❌ ERROR: Payload is null');
              }
            } else {
              print('✅ NOTIFICATION BODY TAPPED (not an action button)');
              print('🔍 Processing tap action...');
              // Trigger alarm screen when notification is tapped
              if (details.payload != null) {
                final id = int.tryParse(details.payload!);
                print('📍 Notification ID parsed: $id');
                if (id != null) {
                  print('📞 Calling callback: tap_${details.payload}');
                  // Call the callback to show alarm screen
                  final action = 'tap_${details.payload}';
                  if (onNotificationAction != null) {
                    onNotificationAction?.call(action);
                    print('✅ Tap callback executed');
                  } else {
                    print('⚠️  Callback not ready, storing action for later');
                    _pendingActions.add(action);
                  }
                } else {
                  print('❌ ERROR: Could not parse notification ID');
                }
              } else {
                print('❌ ERROR: Payload is null');
              }
            }
            print('═══════════════════════════════════════════════════');
            print('\n\n');
          } catch (e, stackTrace) {
            print('\n');
            print('═══════════════════════════════════════════════════');
            print('⚠️  ERROR IN NOTIFICATION CALLBACK');
            print('═══════════════════════════════════════════════════');
            print('❌ Error: $e');
            print('📋 Stack trace: $stackTrace');
            print('🔄 Continuing execution...');
            print('═══════════════════════════════════════════════════');
            print('\n');
          }
        },
      );

      print('Notification plugin initialized: $initialized');

      // Only create notification channel on Android
      if (Platform.isAndroid) {
        final androidImpl =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImpl != null) {
          await androidImpl.createNotificationChannel(_medicineChannel);
          print('Notification channel created: ${_medicineChannel.id}');

          // Request notification permission for Android 13+
          final permissionGranted =
              await androidImpl.requestNotificationsPermission();
          print('Notification permission granted: $permissionGranted');

          // Request exact alarm permission
          final alarmPermission =
              await androidImpl.requestExactAlarmsPermission();
          print('Exact alarm permission granted: $alarmPermission');
        }
      }

      _initialized = true;
      print('========== Notification Service Ready ==========');
    } catch (e, stackTrace) {
      print('ERROR initializing notifications: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static const AndroidNotificationChannel _medicineChannel =
      AndroidNotificationChannel(
    'medicine_reminders',
    'Medicine Reminders',
    description: 'Alarm notifications for medicine reminders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    sound: RawResourceAndroidNotificationSound('alarm_sound'),
  );

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    AppSettings? settings,
  }) async {
    // Load settings if not provided
    settings ??= await SettingsService.getSettings();
    try {
      if (!_initialized) {
        print('Notification service not initialized, initializing now...');
        await init();
      }

      // If the scheduled time is in the past, schedule for the next day
      DateTime notificationTime = scheduledTime;
      final now = DateTime.now();

      if (notificationTime.isBefore(now)) {
        notificationTime = DateTime(
          now.year,
          now.month,
          now.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );

        // If still in the past (same day but earlier time), add one day
        if (notificationTime.isBefore(now)) {
          notificationTime = notificationTime.add(const Duration(days: 1));
        }
      }

      print('========== Scheduling Notification ==========');
      print('ID: $id');
      print('Title: $title');
      print('Scheduled for: $notificationTime');
      print('Current time: $now');

      final tzTime = tz.TZDateTime.from(notificationTime, tz.local);
      print('TZ Time: $tzTime');

      // Create action buttons for snooze and dismiss
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Alarm notifications for medicine reminders',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(settings.alarmSound),
        enableVibration: settings.vibration,
        vibrationPattern: settings.vibration
            ? Int64List.fromList([0, 1000, 500, 1000, 500, 1000])
            : null,
        enableLights: true,
        color: const Color(0xFF009688), // Teal color
        ledColor: const Color(0xFF009688),
        ledOnMs: 1000,
        ledOffMs: 500,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        channelShowBadge: true,
        onlyAlertOnce: false,
        autoCancel: true, // Auto-dismiss when tapped
        ongoing: settings.persistentNotification, // Use settings
        ticker: 'Time to take your medicine!',
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true, // Show on lock screen
        // Audio attributes to make it sound like an alarm
        audioAttributesUsage: AudioAttributesUsage.alarm,
        // Action buttons
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'snooze',
            '⏰ Snooze ${settings.snoozeMinutes}min',
            titleColor: const Color(0xFFFF9800), // Orange
            contextual: false,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'dismiss',
            '✓ Mark Taken',
            titleColor: const Color(0xFF009688), // Teal
            contextual: false,
            showsUserInterface: true,
          ),
        ],
        additionalFlags: Int32List.fromList(
            [4, 16]), // FLAG_INSISTENT and FLAG_AUTO_CANCEL flags
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: id.toString(),
      );

      print('✓ Notification scheduled successfully');
      print('============================================');
    } catch (e, stackTrace) {
      print('ERROR scheduling notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static Future<void> cancelNotification(int id) async {
    print('🗑️  Cancelling notification ID: $id');
    await _notifications.cancel(id);
    print('✅ Successfully cancelled notification with ID: $id');
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('Cancelled all notifications');
  }

  // Snooze notification
  static Future<void> snoozeNotification({
    required int id,
    required String title,
    required String body,
    int? snoozeMinutes,
  }) async {
    try {
      // Load settings if snooze minutes not provided
      if (snoozeMinutes == null) {
        final settings = await SettingsService.getSettings();
        snoozeMinutes = settings.snoozeMinutes;
      }

      // Cancel the current notification
      await cancelNotification(id);

      // Schedule a new notification after snooze duration
      final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));

      print('========== Snoozing Notification ==========');
      print('ID: $id');
      print('Snooze for: $snoozeMinutes minutes');
      print('Will trigger at: $snoozeTime');

      await scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: snoozeTime,
      );

      print('✓ Notification snoozed successfully');
      print('============================================');
    } catch (e) {
      print('ERROR snoozing notification: $e');
    }
  }

  // Get list of pending notifications
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    print('========== Pending Notifications ==========');
    print('Total pending: ${pending.length}');
    for (var notification in pending) {
      print('ID: ${notification.id}, Title: ${notification.title}');
    }
    print('==========================================');
    return pending;
  }

  // Show immediate notification for testing
  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      if (!_initialized) {
        print('Notification service not initialized yet, initializing now...');
        await init();
      }

      // Load settings for test notification
      final settings = await SettingsService.getSettings();

      print('========== Showing Immediate Notification ==========');
      print('ID: $id');
      print('Title: $title');
      print('Body: $body');

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Alarm notifications for medicine reminders',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(settings.alarmSound),
        enableVibration: settings.vibration,
        vibrationPattern: settings.vibration
            ? Int64List.fromList([0, 1000, 500, 1000])
            : null,
        enableLights: true,
        color: const Color(0xFF009688),
        ledColor: const Color(0xFF009688),
        ledOnMs: 1000,
        ledOffMs: 500,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        channelShowBadge: true,
        onlyAlertOnce: false,
        autoCancel: true, // Auto-dismiss when tapped
        ongoing: settings.persistentNotification,
        ticker: 'Time to take your medicine!',
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true, // Show on lock screen
        audioAttributesUsage: AudioAttributesUsage.alarm,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'snooze',
            '⏰ Snooze ${settings.snoozeMinutes}min',
            titleColor: const Color(0xFFFF9800),
            contextual: false,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'dismiss',
            '✓ Mark Taken',
            titleColor: const Color(0xFF009688),
            contextual: false,
            showsUserInterface: true,
          ),
        ],
      );

      final NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: id.toString(),
      );

      print('✓ Notification shown successfully');
      print('Check your notification panel (swipe down from top)');
      print('================================================');
    } catch (e, stackTrace) {
      print('ERROR showing notification: $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  // Process any pending actions that occurred before callback was set
  static List<String> getPendingActions() {
    final actions = List<String>.from(_pendingActions);
    _pendingActions.clear();
    print('🔄 Retrieved ${actions.length} pending actions');
    return actions;
  }
}
