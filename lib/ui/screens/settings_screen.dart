import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;

          return ListView(
            children: [
              // Snooze Settings
              _buildSectionHeader('Alarm Settings'),
              ListTile(
                leading: const Icon(Icons.snooze, color: Colors.orange),
                title: const Text('Snooze Duration'),
                subtitle: Text('${settings.snoozeMinutes} minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSnoozePicker(context, settingsProvider),
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.teal),
                title: const Text('Alarm Sound'),
                subtitle: Text(_getSoundName(settings.alarmSound)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSoundPicker(context, settingsProvider),
              ),
              const Divider(),

              // App Information
              _buildSectionHeader('About'),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.teal),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.orange),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/help-support'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  String _getSoundName(String sound) {
    final sounds = {
      'alarm_sound': 'Default Alarm',
      'soft_alarm': 'Soft Alarm',
      'gentle_bell': 'Gentle Bell',
      'classic_alarm': 'Classic Alarm',
    };
    return sounds[sound] ?? 'Default Alarm';
  }

  void _showSnoozePicker(
      BuildContext context, SettingsProvider settingsProvider) {
    final snoozeOptions = [2, 5, 10, 15, 20, 30];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Snooze Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: snoozeOptions.map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes minutes'),
              value: minutes,
              groupValue: settingsProvider.settings.snoozeMinutes,
              activeColor: Colors.teal,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.updateSnoozeTime(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSoundPicker(
      BuildContext context, SettingsProvider settingsProvider) {
    final sounds = {
      'alarm_sound': 'Default Alarm',
      'soft_alarm': 'Soft Alarm',
      'gentle_bell': 'Gentle Bell',
      'classic_alarm': 'Classic Alarm',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alarm Sound'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sounds.entries.map((entry) {
            final isAvailable = entry.key == 'alarm_sound';
            return ListTile(
              leading: Radio<String>(
                value: entry.key,
                groupValue: settingsProvider.settings.alarmSound,
                activeColor: Colors.teal,
                onChanged: isAvailable
                    ? (value) {
                        if (value != null) {
                          settingsProvider.updateAlarmSound(value);
                          Navigator.pop(context);
                        }
                      }
                    : null,
              ),
              title: Text(
                entry.value,
                style: TextStyle(
                  color: isAvailable ? null : Colors.grey,
                ),
              ),
              subtitle: Text(
                entry.key == 'alarm_sound'
                    ? 'Currently installed'
                    : 'Not available yet',
                style: TextStyle(
                  color: isAvailable ? null : Colors.grey,
                ),
              ),
              enabled: isAvailable,
              onTap: isAvailable
                  ? () {
                      settingsProvider.updateAlarmSound(entry.key);
                      Navigator.pop(context);
                    }
                  : null,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
