# How to Add Custom Alarm Sound

## Steps to add a custom alarm sound:

1. **Get an alarm sound file** (MP3, OGG, or WAV format)
   - You can download from: https://mixkit.co/free-sound-effects/alarm/
   - Or use any alarm sound you prefer

2. **Rename the file to `alarm.mp3`** (or `alarm.ogg`)

3. **Place it in the raw directory:**
   ```
   android/app/src/main/res/raw/alarm.mp3
   ```
   (The directory already exists)

4. **Rebuild the app:**
   ```bash
   flutter clean
   flutter run
   ```

## Default System Alarm

If you don't add a custom sound file, the app will use the system's default notification sound. To use the system alarm sound instead, you can also place a file named `alarm.mp3` in the raw folder.

## Testing

Use the bell icon (🔔) in the app bar to test notifications immediately and verify the sound is working.
