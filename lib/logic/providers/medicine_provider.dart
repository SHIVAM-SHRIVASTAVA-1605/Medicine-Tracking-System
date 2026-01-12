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

    await NotificationService.scheduleNotification(
      id: medicine.notificationId,
      title: 'Medicine Reminder',
      body: 'Time to take ${medicine.name} - ${medicine.dose}',
      scheduledTime: medicine.time,
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
