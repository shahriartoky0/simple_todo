import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_todo/core/utils/logger_utils.dart';
import 'collection/task.dart';

class DatabaseManager {
  static late Isar isar;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      final Directory dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open(<CollectionSchema>[TaskSchema], directory: dir.path);
      _initialized = true;
      LoggerUtils.info('Task Database initialized');
    }
  }
}


