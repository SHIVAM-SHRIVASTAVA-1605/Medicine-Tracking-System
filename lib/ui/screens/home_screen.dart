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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: medicine.isTaken ? 1 : 3,
      color: medicine.isTaken ? Colors.grey[100] : null,
      child: ListTile(
        leading: Checkbox(
          value: medicine.isTaken,
          onChanged: (value) {
            context.read<MedicineProvider>().toggleMedicineTaken(medicineKey);
          },
          shape: const CircleBorder(),
        ),
        title: Text(
          medicine.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: medicine.isTaken ? TextDecoration.lineThrough : null,
            color: medicine.isTaken ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          'Dose: ${medicine.dose}',
          style: TextStyle(
            color: medicine.isTaken ? Colors.grey : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedTime,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: medicine.isTaken ? Colors.grey : null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(context);
              },
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
            onPressed: () {
              context.read<MedicineProvider>().deleteMedicineByKey(medicineKey);
              Navigator.pop(context);
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
