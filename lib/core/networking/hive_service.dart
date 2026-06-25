import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static const String authBoxName = 'auth_box';
  static const String settingsBoxName = 'settings_box';
  static const String userBoxName = 'user_box';

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Open boxes
    await Hive.openBox(authBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(userBoxName);
  }

  static Box getBox(String boxName) => Hive.box(boxName);

  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
    await init();
  }
}
