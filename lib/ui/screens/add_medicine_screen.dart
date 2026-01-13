import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/medicine_provider.dart';
import '../../data/models/medicine_model.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _intervalController = TextEditingController(text: '1');
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _recurrenceType = 'none';
  int _customInterval = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveMedicine() {
    final name = _nameController.text.trim();
    final dose = _doseController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name')),
      );
      return;
    }

    if (dose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter dose')),
      );
      return;
    }

    if (_recurrenceType == 'custom' && _customInterval < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid interval')),
      );
      return;
    }

    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If the scheduled time is in the past, schedule for next occurrence
    DateTime nextScheduled = scheduledTime;
    if (scheduledTime.isBefore(now)) {
      if (_recurrenceType == 'daily') {
        nextScheduled = scheduledTime.add(const Duration(days: 1));
      } else if (_recurrenceType == 'custom') {
        nextScheduled = scheduledTime.add(Duration(days: _customInterval));
      } else {
        // For one-time, schedule for tomorrow
        nextScheduled = scheduledTime.add(const Duration(days: 1));
      }
    }

    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    final medicine = MedicineModel(
      name: name,
      dose: dose,
      time: scheduledTime,
      notificationId: notificationId,
      recurrenceType: _recurrenceType,
      recurrenceInterval: _recurrenceType == 'custom' ? _customInterval : 1,
      nextScheduledDate: nextScheduled,
    );

    context.read<MedicineProvider>().addMedicine(medicine);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: 'Dose',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_pharmacy),
                hintText: 'e.g., 1 tablet, 5ml',
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _recurrenceType,
              decoration: const InputDecoration(
                labelText: 'Recurrence',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('One-time only')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'custom', child: Text('Custom interval')),
              ],
              onChanged: (value) {
                setState(() {
                  _recurrenceType = value!;
                });
              },
            ),
            if (_recurrenceType == 'custom') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _intervalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Every',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _customInterval = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('days', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Weekly (7 days)'),
                    selected: _customInterval == 7,
                    onSelected: (selected) {
                      setState(() {
                        _customInterval = selected ? 7 : 1;
                        _intervalController.text = '${_customInterval}';
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('10 days'),
                    selected: _customInterval == 10,
                    onSelected: (selected) {
                      setState(() {
                        _customInterval = selected ? 10 : 1;
                        _intervalController.text = '${_customInterval}';
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('15 days'),
                    selected: _customInterval == 15,
                    onSelected: (selected) {
                      setState(() {
                        _customInterval = selected ? 15 : 1;
                        _intervalController.text = '${_customInterval}';
                      });
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveMedicine,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Save Medicine',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
