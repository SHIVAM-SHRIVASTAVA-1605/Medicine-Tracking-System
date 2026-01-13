import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/medicine_model.dart';
import '../../logic/providers/medicine_provider.dart';
import '../../logic/services/notification_service.dart';

class AlarmScreen extends StatefulWidget {
  final String medicineName;
  final String dose;
  final int notificationId;

  const AlarmScreen({
    super.key,
    required this.medicineName,
    required this.dose,
    required this.notificationId,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Set lockscreen flags for this screen only
    _setLockscreenFlags(true);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Clear lockscreen flags when leaving alarm screen
    _setLockscreenFlags(false);
    super.dispose();
  }

  // Set or clear lockscreen flags using platform channel
  Future<void> _setLockscreenFlags(bool enable) async {
    try {
      const platform =
          MethodChannel('com.example.medicine_reminder/lockscreen');
      await platform
          .invokeMethod(enable ? 'enableLockscreen' : 'disableLockscreen');
    } catch (e) {
      print('Error setting lockscreen flags: $e');
    }
  }

  // Close the app completely
  Future<void> _closeApp() async {
    try {
      await SystemNavigator.pop();
    } catch (e) {
      print('Error closing app: $e');
    }
  }

  Future<void> _handleMarkTaken() async {
    try {
      final provider = Provider.of<MedicineProvider>(context, listen: false);
      final medicines = provider.medicinesMap;

      // Find the medicine by notification ID
      dynamic medicineKey;
      MedicineModel? medicine;
      for (var entry in medicines.entries) {
        if (entry.value.notificationId == widget.notificationId) {
          medicineKey = entry.key;
          medicine = entry.value;
          break;
        }
      }

      if (medicine != null && medicineKey != null) {
        // Cancel notification
        await NotificationService.cancelNotification(widget.notificationId);

        // Mark as taken using toggleMedicineTaken
        if (!medicine.isTaken) {
          await provider.toggleMedicineTaken(medicineKey);
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.medicineName} marked as taken'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // Close the alarm screen and app
      if (mounted) {
        await _closeApp();
      }
    } catch (e) {
      print('Error marking medicine as taken: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error marking medicine as taken'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSnooze() async {
    try {
      // Cancel notification and snooze
      await NotificationService.snoozeNotification(
        id: widget.notificationId,
        title: widget.medicineName,
        body: 'Dose: ${widget.dose}',
      );

      // Show snooze message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder snoozed'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        // Close the alarm screen and app
        await _closeApp();
      }
    } catch (e) {
      print('Error snoozing notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error snoozing reminder'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false, // Prevent back button from dismissing
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated alarm icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication_rounded,
                      size: 100,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Time to take medicine text
                Text(
                  'Time to take your medicine!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Medicine name card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Medicine name
                      Text(
                        widget.medicineName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Container(
                        height: 2,
                        width: 60,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dose information
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_hospital_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dose: ${widget.dose}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Mark as taken button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _handleMarkTaken,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Mark as Taken',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Snooze button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: _handleSnooze,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.snooze, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Snooze',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dismiss button
                      TextButton(
                        onPressed: () async {
                          await NotificationService.cancelNotification(
                              widget.notificationId);
                          if (mounted) {
                            await _closeApp();
                          }
                        },
                        child: Text(
                          'Dismiss',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ), // PopScope
    ); // Scaffold is wrapped by PopScope
  } // build method
}
