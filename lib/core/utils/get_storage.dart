import 'package:get_storage/get_storage.dart';

class GetStorageModel {
  final GetStorage _storage = GetStorage();

  // Generic method to save an object (string, int, bool, list, etc.)
  Future<void> create(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  // Generic method to read an object
  dynamic read(String key) {
    return _storage.read(key);
  }

  // Method to update an object
  Future<void> update(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  // Method to delete an object
  Future<void> delete(String key) async {
    await _storage.remove(key);
  }

  // Method to check if key exists
  bool exists(String key) {
    return _storage.hasData(key);
  }

  // Method to store a List
  Future<void> saveList(String key, List<dynamic> list) async {
    await _storage.write(key, list);
  }

  // Method to retrieve a List
  List<dynamic>? getList(String key) {
    return _storage.read(key)?.cast<dynamic>();
  }

  // Method to store a Map (or complex object)
  Future<void> saveMap(String key, Map<String, dynamic> map) async {
    await _storage.write(key, map);
  }

  // Method to retrieve a Map
  Map<String, dynamic>? getMap(String key) {
    return _storage.read(key);
  }

  // Store and retrieve a specific String
  Future<void> saveString(String key, String value) async {
    await _storage.write(key, value);
  }

  String? getString(String key) {
    return _storage.read(key);
  }

  // Store and retrieve a specific integer
  Future<void> saveInt(String key, int value) async {
    await _storage.write(key, value);
  }

  int? getInt(String key) {
    return _storage.read(key);
  }

  // Store and retrieve a specific boolean
  Future<void> saveBool(String key, bool value) async {
    await _storage.write(key, value);
  }

  bool? getBool(String key) {
    return _storage.read(key);
  }

  // Store and retrieve a specific double
  Future<void> saveDouble(String key, double value) async {
    await _storage.write(key, value);
  }

  double? getDouble(String key) {
    return _storage.read(key);
  }

  // Store and retrieve a specific DateTime (as a String)
  Future<void> saveDateTime(String key, DateTime value) async {
    await _storage.write(key, value.toIso8601String());
  }

  DateTime? getDateTime(String key) {
    final String? dateStr = _storage.read(key);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  // Store and retrieve a List of Strings
  Future<void> saveStringList(String key, List<String> list) async {
    await _storage.write(key, list);
  }

  List<String>? getStringList(String key) {
    return _storage.read(key)?.cast<String>();
  }

  // Store and retrieve a Map of String to dynamic
  Future<void> saveStringMap(String key, Map<String, dynamic> map) async {
    await _storage.write(key, map);
  }

  Map<String, dynamic>? getStringMap(String key) {
    return _storage.read(key);
  }
}
