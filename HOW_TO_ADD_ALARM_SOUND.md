# How to Add a Proper Alarm Sound

Your medicine reminder notifications are working! To make them sound like a proper alarm, follow these steps:

## Step 1: Download an Alarm Sound

Download an alarm sound file in **MP3** or **OGG** format. Here are some free sources:

- **Pixabay**: https://pixabay.com/sound-effects/search/alarm/
- **Zapsplat**: https://www.zapsplat.com/sound-effect-category/alarms-and-sirens/
- **Freesound**: https://freesound.org/search/?q=alarm

Look for:
- Continuous ringing/beeping sounds
- Duration: 10-30 seconds
- File format: MP3 or OGG

## Step 2: Prepare the Sound File

1. Download your chosen alarm sound
2. **Rename it to: `alarm_sound.mp3`** (or `alarm_sound.ogg`)
3. Important: The name must be **exactly** `alarm_sound` (lowercase, underscore, no spaces)

## Step 3: Place the File

Copy the sound file to this location:
```
android/app/src/main/res/raw/alarm_sound.mp3
```

The `raw` folder already exists in your project.

## Step 4: Rebuild the App

```bash
flutter clean
flutter run
```

## What Will Happen

- Your medicine reminders will now play the custom alarm sound
- The sound will be louder and more noticeable than the default notification sound
- The notification will show as a high-priority alert

## Testing

After rebuilding:
1. Add a medicine with a time 1-2 minutes in the future
2. Wait for the notification
3. You should hear your custom alarm sound!

## Troubleshooting

**Sound not playing?**
- Make sure the file name is exactly `alarm_sound.mp3` (lowercase)
- File must be in MP3 or OGG format
- Run `flutter clean` before rebuilding
- Check phone volume and Do Not Disturb settings

**Want to use the default system alarm?**
- Go to phone Settings > Apps > Medicine Reminder > Notifications
- Tap on "Medicine Reminders" channel
- Change the sound to your preferred system alarm

## Current Configuration

The app is already configured to use:
- **Maximum importance** (shows as heads-up notification)
- **Full-screen intent** (can wake up the screen)
- **Vibration** enabled
- **LED lights** enabled
- **Custom alarm sound** (once you add the file)
- **60-second timeout** (notification auto-dismisses after 1 minute)
