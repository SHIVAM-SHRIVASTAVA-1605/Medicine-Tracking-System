import 'package:flutter/foundation.dart';
import '../../data/models/medicine_model.dart';
import '../../data/local/hive_service.dart';
import '../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  Map<dynamic, MedicineModel> get medicinesMap {
    final box = HiveService.getMedicineBox();
    return box.toMap();
  }

  List<MedicineModel> get medicines {
    final box = HiveService.getMedicineBox();
    final medicineList = box.values.toList();
    medicineList.sort((a, b) => a.time.compareTo(b.time));
    return medicineList;
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    final box = HiveService.getMedicineBox();
    await box.add(medicine);

    // Schedule notification for next scheduled date (or initial time if not set)
    final scheduledTime = medicine.nextScheduledDate ?? medicine.time;
    
    await NotificationService.scheduleNotification(
      id: medicine.notificationId,
      title: 'Medicine Reminder',
      body: 'Time to take ${medicine.name} - ${medicine.dose}',
      scheduledTime: scheduledTime,
    );

    notifyListeners();
  }

  Future<void> deleteMedicine(int index) async {
    final box = HiveService.getMedicineBox();
    final medicine = box.getAt(index);

    if (medicine != null) {
      await NotificationService.cancelNotification(medicine.notificationId);
      await box.deleteAt(index);
      notifyListeners();
    }
  }

  Future<void> deleteMedicineByKey(dynamic key) async {
    final box = HiveService.getMedicineBox();
    final medicine = box.get(key);

    if (medicine != null) {
      await NotificationService.cancelNotification(medicine.notificationId);
      await box.delete(key);
      notifyListeners();
    }
  }

  Future<void> toggleMedicineTaken(dynamic key) async {
    final box = HiveService.getMedicineBox();
    final medicine = box.get(key);

    if (medicine != null) {
      medicine.isTaken = !medicine.isTaken;

      // If marking as taken
      if (medicine.isTaken) {
        // Add to history
        medicine.takenHistory.add(DateTime.now());
        medicine.lastTakenDate = DateTime.now();

        // If it's a recurring medicine, schedule next occurrence
        if (medicine.isRecurring) {
          // Calculate next scheduled date
          DateTime nextDate;
          if (medicine.recurrenceType == 'daily') {
            nextDate = DateTime.now().add(const Duration(days: 1));
          } else {
            // custom interval
            nextDate = DateTime.now().add(Duration(days: medicine.recurrenceInterval));
          }

          // Set time to the scheduled time of day
          medicine.nextScheduledDate = DateTime(
            nextDate.year,
            nextDate.month,
            nextDate.day,
            medicine.time.hour,
            medicine.time.minute,
          );

          // Schedule the next notification
          await NotificationService.scheduleNotification(
            id: medicine.notificationId,
            title: 'Medicine Reminder',
            body: 'Time to take ${medicine.name} - ${medicine.dose}',
            scheduledTime: medicine.nextScheduledDate!,
          );

          // Mark as not taken for next occurrence
          medicine.isTaken = false;
        }
      } else {
        // If unmarking as taken, remove the last entry from history
        if (medicine.takenHistory.isNotEmpty) {
          medicine.takenHistory.removeLast();
          medicine.lastTakenDate = medicine.takenHistory.isNotEmpty 
              ? medicine.takenHistory.last 
              : null;
        }
      }

      await box.put(key, medicine);
      notifyListeners();
    }
  }

  Future<void> deleteAllMedicines() async {
    final box = HiveService.getMedicineBox();
    await NotificationService.cancelAllNotifications();
    await box.clear();
    notifyListeners();
  }
}
