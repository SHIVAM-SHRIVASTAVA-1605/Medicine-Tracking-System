# 🔔 Alarm Features Documentation

## New Alarm-Style Notifications

Your medicine reminder app now includes full alarm functionality with the following features:

### ✨ Features

#### 1. **Alarm-Style Notifications**
- High-priority notifications that work like alarm apps
- Custom alarm sound (`alarm_sound.mp3`)
- Vibration pattern for attention
- LED light notifications (on supported devices)
- Full-screen intent on Android (pops up even on lock screen)
- Persistent notification (harder to dismiss accidentally)

#### 2. **Snooze Functionality** ⏰
- **Snooze button** on every notification
- Automatically reschedules for 10 minutes later
- Tap "⏰ Snooze 10min" to delay the reminder
- Perfect for when you're busy and need a reminder later

#### 3. **Quick Actions**
Two action buttons on each notification:
- **⏰ Snooze 10min** - Delays reminder for 10 minutes
- **✓ Mark Taken** - Marks medicine as taken and dismisses notification

#### 4. **Visual Feedback**
- Teal color theme for notifications
- Orange snooze button
- Teal "Mark Taken" button
- Matches app design

### 📱 How to Use

#### Testing the Alarm
1. Open the app
2. Tap the **bell icon (🔔)** in the top-right corner
3. You'll see an immediate test notification with:
   - Alarm sound playing
   - Vibration
   - Two action buttons (Snooze & Mark Taken)

#### Adding Medicine Reminders
1. Tap the **+ (FAB)** button
2. Enter medicine name and dose
3. Set the time
4. Save
5. At the scheduled time, you'll get a full alarm notification

#### Responding to Alarms
When a notification appears:
- **Tap "⏰ Snooze 10min"** to reschedule for 10 minutes later
- **Tap "✓ Mark Taken"** to mark as taken and dismiss
- You'll see a confirmation message in the app

### 🔊 Custom Alarm Sound

The app uses a custom alarm sound located at:
```
android/app/src/main/res/raw/alarm_sound.mp3
```

To change the alarm sound:
1. Get a new alarm sound file (MP3, OGG, or WAV)
2. Rename it to `alarm_sound.mp3`
3. Replace the file in `android/app/src/main/res/raw/`
4. Rebuild the app:
   ```bash
   flutter clean
   flutter run
   ```

### 🛠️ Technical Details

#### Notification Channel
- **Channel ID**: `medicine_reminders`
- **Importance**: Maximum
- **Sound**: Custom (`alarm_sound`)
- **Vibration**: Enabled with pattern
- **LED**: Teal color

#### Permissions
The app requires these permissions for full functionality:
- `POST_NOTIFICATIONS` - Show notifications
- `SCHEDULE_EXACT_ALARM` - Schedule precise alarms
- `USE_EXACT_ALARM` - Use exact alarm timing
- `VIBRATE` - Vibration
- `WAKE_LOCK` - Wake device
- `USE_FULL_SCREEN_INTENT` - Show on lock screen
- `RECEIVE_BOOT_COMPLETED` - Persist after device restart

#### Notification Features
- **Auto-cancel**: Disabled (stays until user acts)
- **Ongoing**: True (persistent notification)
- **Full-screen intent**: Shows even on lock screen
- **Audio attributes**: Alarm category (highest priority)
- **Category**: ALARM
- **Visibility**: Public (shows on lock screen)

### 🎯 Best Practices

1. **Test First**: Use the bell icon to test notifications before relying on scheduled reminders
2. **Check Volume**: Ensure alarm volume is turned up on your device
3. **Battery Settings**: Add app to battery optimization whitelist for reliable alarms
4. **Permissions**: Grant all requested permissions for full functionality

### ⚠️ Troubleshooting

#### Sound Not Playing?
1. Check if `alarm_sound.mp3` exists in `android/app/src/main/res/raw/`
2. Verify alarm volume is not muted on your device
3. Rebuild app: `flutter clean && flutter run`
4. Check notification channel settings in Android settings

#### Notifications Not Showing?
1. Grant notification permission
2. Grant exact alarm permission (Android 12+)
3. Disable battery optimization for the app
4. Check Do Not Disturb settings

#### Full-Screen Not Working?
1. Grant "Display over other apps" permission in Android settings
2. On some devices, this requires manual activation in settings

### 🔄 How Snooze Works

1. User taps "⏰ Snooze 10min"
2. App cancels current notification
3. Creates new notification scheduled for +10 minutes
4. Shows confirmation in app
5. After 10 minutes, alarm rings again with same options

### 📊 State Management

Notification actions are handled through:
- `NotificationService.onNotificationAction` callback
- Integrates with Provider state management
- Updates UI when medicines are marked as taken
- Shows SnackBar feedback for user actions
