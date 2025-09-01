import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_todo/core/config/app_strings.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/extensions/date_time_extensions.dart';
import 'package:simple_todo/core/utils/logger_utils.dart';

class FileManagerService {
  // Export tasks to CSV file
  static Future<bool> exportTasksToCSV(List<Task> tasks) async {
    try {
      // Get app-specific directory (no permissions needed)
      final Directory directory = await getApplicationDocumentsDirectory();

      // Create CSV content
      String csvContent = 'ID,Title,Description,Status,CreatedAt\n';
      for (final Task task in tasks) {
        csvContent +=
            '"${task.id}",'
            '"${task.title.replaceAll('"', '""')}",'
            '"${task.description.replaceAll('"', '""')}",'
            '"${task.status.name}",'
            '"${task.createdAt?.smartDate}"\n';
      }

      // Create file
      final String fileName = 'To Do List_${DateTime.now().compactTime}.csv';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles(<XFile>[XFile(file.path)], text: AppStrings.myToDoList.tr);

      return true;
    } catch (e) {
      LoggerUtils.debug('Error exporting CSV: $e');
      return false;
    }
  }

  // Unified import method for both CSV and JSON
  static Future<List<Task>?> importTasks() async {
    try {
      // Pick file with both CSV and JSON extensions
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['csv', 'json'],
        dialogTitle: 'Select CSV or JSON file to import',
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        final String contents = await file.readAsString();
        final String fileName = result.files.single.name.toLowerCase();

        // Determine file type and parse accordingly
        if (fileName.endsWith('.csv')) {
          LoggerUtils.debug('Importing CSV file: $fileName');
          return _parseCSVContent(contents);
        } else if (fileName.endsWith('.json')) {
          LoggerUtils.debug('Importing JSON file: $fileName');
          return _parseJSONContent(contents);
        } else {
          // Fallback: Try to detect content type by structure
          return _parseByContent(contents);
        }
      }
      return null;
    } catch (e) {
      LoggerUtils.debug('Error importing file: $e');
      return null;
    }
  }

  // Fallback method to detect content type by analyzing structure
  static List<Task>? _parseByContent(String content) {
    try {
      final String trimmedContent = content.trim();

      // Try JSON first (starts with [ or {)
      if (trimmedContent.startsWith('[') || trimmedContent.startsWith('{')) {
        LoggerUtils.debug('Content appears to be JSON, attempting JSON parse');
        return _parseJSONContent(content);
      }

      if (trimmedContent.contains(',') && trimmedContent.contains('\n')) {
        LoggerUtils.debug('Content appears to be CSV, attempting CSV parse');
        return _parseCSVContent(content);
      }

      // If neither format is detected clearly, try JSON first then CSV
      try {
        return _parseJSONContent(content);
      } catch (jsonError) {
        LoggerUtils.debug('JSON parse failed, trying CSV: $jsonError');
        return _parseCSVContent(content);
      }
    } catch (e) {
      LoggerUtils.debug('Error in content type detection: $e');
      return null;
    }
  }

  static List<Task> _parseCSVContent(String csvContent) {
    final List<Task> tasks = <Task>[];
    final List<String> lines = csvContent.split('\n');

    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      final String line = lines[i].trim();
      if (line.isEmpty) {
        continue;
      }

      try {
        final List<String> fields = _parseCSVRow(line);
        if (fields.length >= 4) {
          final TaskStatus status = TaskStatus.values.firstWhere(
            (TaskStatus s) => s.name == fields[3],
            orElse: () => TaskStatus.pending,
          );

          // Parse timestamp to DateTime
          final int timestamp = int.tryParse(fields[4]) ?? DateTime.now().millisecondsSinceEpoch;

          tasks.add(
            Task(
              title: fields[1],
              description: fields[2],
              status: status,
              createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
            ),
          );
        }
      } catch (e) {
        LoggerUtils.debug('Error parsing CSV row: $line, Error: $e');
      }
    }

    return tasks;
  }

  static List<String> _parseCSVRow(String row) {
    final List<String> fields = <String>[];
    bool inQuotes = false;
    String currentField = '';

    for (int i = 0; i < row.length; i++) {
      final String char = row[i];

      if (char == '"') {
        if (i + 1 < row.length && row[i + 1] == '"') {
          // Escaped quote
          currentField += '"';
          i++; // Skip next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Field separator
        fields.add(currentField);
        currentField = '';
      } else {
        currentField += char;
      }
    }

    // Add last field
    fields.add(currentField);
    return fields;
  }

  static List<Task> _parseJSONContent(String jsonContent) {
    try {
      final dynamic jsonData = json.decode(jsonContent);
      final List<Task> tasks = <Task>[];

      if (jsonData is List) {
        // Array of tasks
        for (final dynamic taskData in jsonData) {
          final Task? task = _createTaskFromJson(taskData);
          if (task != null) {
            tasks.add(task);
          }
        }
      } else if (jsonData is Map<String, dynamic>) {
        // Single task or object with tasks array
        if (jsonData.containsKey('tasks') && jsonData['tasks'] is List) {
          // Object with tasks array
          for (final dynamic taskData in jsonData['tasks']) {
            final Task? task = _createTaskFromJson(taskData);
            if (task != null) {
              tasks.add(task);
            }
          }
        } else {
          // Single task object
          final Task? task = _createTaskFromJson(jsonData);
          if (task != null) {
            tasks.add(task);
          }
        }
      }

      return tasks;
    } catch (e) {
      LoggerUtils.debug('Error parsing JSON: $e');
      return <Task>[];
    }
  }

  static Task? _createTaskFromJson(dynamic taskData) {
    try {
      if (taskData is! Map<String, dynamic>) {
        return null;
      }

      final String title = taskData['title']?.toString() ?? '';
      final String description = taskData['description']?.toString() ?? '';

      if (title.isEmpty) {
        return null;
      }

      // Parse status
      TaskStatus status = TaskStatus.pending;
      if (taskData['status'] != null) {
        final String statusStr = taskData['status'].toString().toLowerCase();
        status = TaskStatus.values.firstWhere(
          (TaskStatus s) => s.name.toLowerCase() == statusStr,
          orElse: () => TaskStatus.pending,
        );
      }

      // Parse created date - handle multiple formats
      DateTime createdAt = DateTime.now();

      if (taskData['createdAt'] != null) {
        if (taskData['createdAt'] is int) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(taskData['createdAt']);
        } else if (taskData['createdAt'] is String) {
          final String dateStr = taskData['createdAt'];
          final DateTime? parsedDate = DateTime.tryParse(dateStr);
          if (parsedDate != null) {
            createdAt = parsedDate;
          } else {
            createdAt = DateTime.now();
          }
        }
      }

      return Task(title: title, description: description, status: status, createdAt: createdAt);
    } catch (e) {
      LoggerUtils.debug('Error creating task from JSON: $e');
      return null;
    }
  }
}
