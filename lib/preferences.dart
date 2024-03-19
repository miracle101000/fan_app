import 'package:hive_flutter/hive_flutter.dart';
import 'user_data.dart';

class Preferences {
  static const boxName = 'vdee-box';
  static late Box vdeeBox;

  static Future<void> initialize() async {
    vdeeBox = await Hive.openBox(boxName);
    await UserData.initialize();
  }

  static Future<void> closeBox() async {
    await vdeeBox.close();
  }

  static Future<int> clearBox() async {
    return await vdeeBox.clear();
  }

  static Future<void> deleteData(String key) async {
    await vdeeBox.delete(key);
  }

  static Future<void> deleteMultiple(List<String> keys) async {
    await vdeeBox.deleteAll(keys);
  }

  static bool containsKey(String key) {
    return vdeeBox.containsKey(key);
  }

  static bool isBoxOpen() {
    return vdeeBox.isOpen;
  }

  static Future<dynamic> getData(String key) async {
    return await vdeeBox.get(key);
  }

  static Future<void> saveData(String key, dynamic value) async {
    await vdeeBox.put(key, value);
  }

  static Future<void> saveMultipleData(Map<String, dynamic> entries) async {
    await vdeeBox.putAll(entries);
  }
}
