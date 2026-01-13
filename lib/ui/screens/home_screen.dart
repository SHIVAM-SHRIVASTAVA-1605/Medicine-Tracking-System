import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/medicine_provider.dart';
import '../../logic/services/notification_service.dart';
import '../../data/models/medicine_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _testNotification(BuildContext context) async {
    // Show immediate test notification with actions
    await NotificationService.showImmediateNotification(
      id: 99999,
      title: '💊 Medicine Reminder Test',
      body: 'This is a test alarm notification with snooze option',
    );

    // Check pending scheduled notifications
    final pending = await NotificationService.getPendingNotifications();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Test alarm sent!\n${pending.length} scheduled notifications pending'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistics',
            onPressed: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notification',
            onPressed: () {
              _testNotification(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          final medicinesMap = provider.medicinesMap;
          final medicines = medicinesMap.values.toList();
          medicines.sort((a, b) => a.time.compareTo(b.time));

          if (medicines.isEmpty) {
            return const Center(
              child: Text(
                'No medicines added yet.\nTap + to add your first reminder.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              // Find the key for this medicine
              final key = medicinesMap.keys.firstWhere(
                (k) => medicinesMap[k] == medicine,
              );
              return _MedicineCard(
                medicine: medicine,
                medicineKey: key,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-medicine');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final dynamic medicineKey;

  const _MedicineCard({
    required this.medicine,
    required this.medicineKey,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final formattedTime = timeFormat.format(medicine.time);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: medicine.isTaken ? 1 : 3,
      color: medicine.isTaken ? Colors.grey[100] : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            Checkbox(
              value: medicine.isTaken,
              onChanged: (value) {
                context.read<MedicineProvider>().toggleMedicineTaken(medicineKey);
              },
              shape: const CircleBorder(),
            ),
            const SizedBox(width: 8),
            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine name
                  Text(
                    medicine.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: medicine.isTaken ? TextDecoration.lineThrough : null,
                      color: medicine.isTaken ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Dose
                  Text(
                    'Dose: ${medicine.dose}',
                    style: TextStyle(
                      fontSize: 14,
                      color: medicine.isTaken ? Colors.grey : Colors.grey[700],
                    ),
                  ),
                  // Last taken (if recurring)
                  if (medicine.isRecurring && medicine.lastTakenDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Last: ${DateFormat('MMM dd, hh:mm a').format(medicine.lastTakenDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Next scheduled (if recurring)
                  if (medicine.isRecurring && medicine.nextScheduledDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Next: ${dateFormat.format(medicine.nextScheduledDate!)} at $formattedTime',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right side - Time, badge, and delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Recurrence badge (if recurring)
                if (medicine.isRecurring)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.repeat,
                          size: 12,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medicine.recurrenceDescription,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Time
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: medicine.isTaken ? Colors.grey : null,
                  ),
                ),
                const SizedBox(height: 4),
                // Delete button
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    _showDeleteDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<MedicineProvider>().deleteMedicineByKey(medicineKey);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${medicine.name} deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting medicine: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
