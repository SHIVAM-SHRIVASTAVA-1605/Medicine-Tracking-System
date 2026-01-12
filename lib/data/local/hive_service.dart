import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine_model.dart';

class HiveService {
  static const String _medicineBoxName = 'medicines';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicineModelAdapter());
    await Hive.openBox<MedicineModel>(_medicineBoxName);
  }

  static Box<MedicineModel> getMedicineBox() {
    return Hive.box<MedicineModel>(_medicineBoxName);
  }
}
