import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Getting Started Section
          _buildSectionHeader(context, 'Getting Started'),
          _buildHelpCard(
            context,
            icon: Icons.add_circle_outline,
            title: 'Adding Medicines',
            description:
                'Tap the "+" button on the home screen to add a new medicine. Fill in the medicine name, dosage, and set reminder times.',
            color: Colors.blue,
          ),
          _buildHelpCard(
            context,
            icon: Icons.schedule,
            title: 'Setting Reminders',
            description:
                'Choose the frequency (daily, weekly, or custom) and set specific times for your medicine reminders. You can add multiple reminders per day.',
            color: Colors.green,
          ),
          const SizedBox(height: 16),

          // Using Features Section
          _buildSectionHeader(context, 'Using Features'),
          _buildHelpCard(
            context,
            icon: Icons.notifications_active,
            title: 'Notifications',
            description:
                'When a medicine reminder is due, you\'ll receive a notification. On locked screens, it appears as a full-screen alert. On unlocked screens, it shows in the notification panel.',
            color: Colors.orange,
          ),
          _buildHelpCard(
            context,
            icon: Icons.snooze,
            title: 'Snooze Feature',
            description:
                'When an alarm rings, tap the "Snooze" button to delay the reminder by your chosen duration (default: 5 minutes).',
            color: Colors.amber,
          ),
          _buildHelpCard(
            context,
            icon: Icons.check_circle,
            title: 'Mark as Taken',
            description:
                'Tap "Mark as Taken" on the notification to confirm you\'ve taken your medicine. This will dismiss the reminder and update your statistics.',
            color: Colors.teal,
          ),
          const SizedBox(height: 16),

          // Tips & Tricks Section
          _buildSectionHeader(context, 'Tips & Tricks'),
          _buildHelpCard(
            context,
            icon: Icons.lightbulb_outline,
            title: 'Test Notifications',
            description:
                'Tap the bell icon (🔔) on the home screen to send a test notification. This helps verify your notification settings are working correctly.',
            color: Colors.purple,
          ),
          _buildHelpCard(
            context,
            icon: Icons.settings,
            title: 'Customize Alarms',
            description:
                'Go to Settings to adjust snooze duration and change the alarm sound. Choose from several built-in alarm sounds.',
            color: Colors.indigo,
          ),
          _buildHelpCard(
            context,
            icon: Icons.bar_chart,
            title: 'View Statistics',
            description:
                'Check the Statistics tab to see your medicine intake history and track which medicines you\'ve taken.',
            color: Colors.red,
          ),
          const SizedBox(height: 16),

          // Important Section
          _buildSectionHeader(context, 'Important'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              border: Border.all(color: Colors.amber, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.amber[800], size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Permissions Required',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Notification Permission: Required for medicine reminders\n'
                  '• Exact Alarm Permission: Required for precise alarm timing\n'
                  '• Battery Optimization: Disable battery optimization for this app to ensure reliable reminders',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Troubleshooting Section
          _buildSectionHeader(context, 'Troubleshooting'),
          _buildHelpCard(
            context,
            icon: Icons.help_outline,
            title: 'Reminders Not Working',
            description:
                'Check if notifications are enabled in your phone settings. Also ensure the app is not restricted by battery optimization. Restart your phone if issues persist.',
            color: Colors.red,
          ),
          _buildHelpCard(
            context,
            icon: Icons.volume_off,
            title: 'No Sound on Lock Screen',
            description:
                'Make sure your phone is not in silent mode. Check Settings > Alarm Sound is not set to silent. Increase your device\'s volume level.',
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 16),

          // Contact Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              border: Border.all(color: Colors.teal, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.teal, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Need More Help?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'If you encounter any issues or have suggestions, please contact our support team.',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'shivam091204@gmail.com',
                      query: 'subject=Medicine Reminder Support',
                    );
                    
                    try {
                      await launchUrl(
                        emailUri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open email app. Please email us at shivam091204@gmail.com'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildHelpCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
