import 'package:hive/hive.dart';

part 'medicine_model.g.dart';

@HiveType(typeId: 0)
class MedicineModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String dose;

  @HiveField(2)
  final DateTime time;

  @HiveField(3)
  final int notificationId;

  @HiveField(4)
  bool isTaken;

  @HiveField(5)
  final String recurrenceType; // 'none', 'daily', 'custom'

  @HiveField(6)
  final int recurrenceInterval; // days between doses (for custom)

  @HiveField(7)
  DateTime? lastTakenDate; // Track when last taken

  @HiveField(8)
  DateTime? nextScheduledDate; // Next scheduled date

  @HiveField(9)
  List<DateTime> takenHistory; // History of when medicine was taken

  MedicineModel({
    required this.name,
    required this.dose,
    required this.time,
    required this.notificationId,
    this.isTaken = false,
    this.recurrenceType = 'none',
    this.recurrenceInterval = 1,
    this.lastTakenDate,
    this.nextScheduledDate,
    List<DateTime>? takenHistory,
  }) : takenHistory = takenHistory ?? [];

  // Helper method to check if medicine is recurring
  bool get isRecurring => recurrenceType != 'none';

  // Helper method to get recurrence description
  String get recurrenceDescription {
    switch (recurrenceType) {
      case 'daily':
        return 'Daily';
      case 'custom':
        if (recurrenceInterval == 7) return 'Weekly';
        if (recurrenceInterval == 14) return 'Bi-weekly';
        return 'Every $recurrenceInterval days';
      default:
        return 'One-time';
    }
  }
}
