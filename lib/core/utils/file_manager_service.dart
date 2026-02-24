import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:simple_todo/core/config/app_strings.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/utils/logger_utils.dart';

class FileManagerService {
  // ─── CSV Export ────────────────────────────────────────────────────────────

  /// Writes CSV to the system temp directory then opens the OS share sheet.
  ///
  /// Using [getTemporaryDirectory] + [Share.shareXFiles] means:
  /// • The file has the correct .csv extension and text/csv MIME type.
  /// • The OS share sheet opens immediately — user decides where it goes
  ///   (Downloads, Drive, WhatsApp, email, etc.).
  /// • Temp files are cleaned up by the OS automatically.
  /// • No silent background save, no misleading toast needed.
  static Future<bool> exportTasksToCSV(List<Task> tasks) async {
    try {
      final String fileName =
          'To_Do_List_${DateTime.now().millisecondsSinceEpoch}.csv';
      final Directory dir = await getTemporaryDirectory();
      final File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(_buildCsvBytes(tasks));

      await Share.shareXFiles(
        <XFile>[XFile(file.path, mimeType: 'text/csv')],
        text: AppStrings.myToDoList,
      );
      return true;
    } catch (e) {
      LoggerUtils.debug('Error exporting CSV: $e');
      return false;
    }
  }

  // ─── PDF Export ────────────────────────────────────────────────────────────

  /// Writes PDF to the system temp directory then opens the OS share sheet.
  /// Identical flow to [exportTasksToCSV] — same share sheet, same UX.
  static Future<bool> exportTasksToPDF(List<Task> tasks) async {
    try {
      final String fileName =
          'To_Do_List_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final Directory dir = await getTemporaryDirectory();
      final File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await _buildPdfBytes(tasks));

      await Share.shareXFiles(
        <XFile>[XFile(file.path, mimeType: 'application/pdf')],
        text: AppStrings.myToDoList,
      );
      return true;
    } catch (e) {
      LoggerUtils.debug('Error exporting PDF: $e');
      return false;
    }
  }

  // ─── Import ────────────────────────────────────────────────────────────────

  // Returned values:
  //   null              → user cancelled (no toast needed)
  //   []  (empty list)  → file was valid format but contained no tasks
  //   throws _ImportException → show the message as an error toast
  static Future<List<Task>?> importTasks() async {
    try {
      // FIX: Use FileType.any instead of FileType.custom with allowedExtensions.
      // On Android, CSV files are often served by file managers with a
      // 'text/plain' MIME type, which makes FileType.custom's OS-level extension
      // filter hide them entirely. FileType.any shows everything; we validate
      // the format ourselves after the user picks a file.
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        dialogTitle: 'Select a CSV, XLSX or JSON file to import',
      );

      // User tapped Cancel — return null silently.
      if (result == null || result.files.isEmpty) return null;

      final PlatformFile picked = result.files.single;
      final String? path = picked.path;

      if (path == null) {
        throw _ImportException('Could not access the selected file.');
      }

      // ── Extension check ───────────────────────────────────────────────────
      final String name = picked.name.toLowerCase();
      final bool isCsv  = name.endsWith('.csv');
      final bool isJson = name.endsWith('.json');
      final bool isXlsx = name.endsWith('.xlsx');

      if (!isCsv && !isJson && !isXlsx) {
        throw _ImportException(
          'Invalid file type "${picked.name}".\nOnly .csv, .xlsx and .json files are supported.',
        );
      }

      // ── File existence check ──────────────────────────────────────────────
      final File file = File(path);
      if (!file.existsSync()) {
        throw _ImportException('File not found. Please try again.');
      }

      // ── Parse ─────────────────────────────────────────────────────────────
      try {
        List<Task> tasks = <Task>[];

        if (isXlsx) {
          // XLSX is binary — read as bytes, never as a string.
          final Uint8List bytes = await file.readAsBytes();
          tasks = _parseXLSXContent(bytes);
        } else {
          // CSV and JSON are text files.
          final String contents;
          try {
            contents = await file.readAsString(encoding: utf8);
          } catch (_) {
            throw _ImportException(
              'Could not read the file. Make sure it is a valid text file.',
            );
          }

          if (contents.trim().isEmpty) {
            throw _ImportException('The selected file is empty.');
          }

          tasks = isCsv
              ? _parseCSVContent(contents)
              : _parseJSONContent(contents);
        }

        if (tasks.isEmpty) {
          throw _ImportException(
            'No valid tasks found in the file.\n'
                'Make sure it was exported from this app.',
          );
        }

        return tasks;
      } on _ImportException {
        rethrow;
      } catch (e) {
        throw _ImportException(
          'Failed to parse the file. It may be corrupted or in the wrong format.',
        );
      }
    } on _ImportException {
      rethrow; // controller catches this and shows the message
    } catch (e) {
      LoggerUtils.debug('Unexpected import error: $e');
      throw _ImportException('An unexpected error occurred. Please try again.');
    }
  }

  // ─── CSV builder ───────────────────────────────────────────────────────────

  static Uint8List _buildCsvBytes(List<Task> tasks) {
    final StringBuffer buffer =
    StringBuffer('ID,Title,Description,Status,CreatedAt\n');
    for (final Task task in tasks) {
      final String createdAt =
      (task.createdAt ?? DateTime.now()).toIso8601String();
      buffer
        ..write('"${task.id}",')
        ..write('"${_escapeCsv(task.title)}",')
        ..write('"${_escapeCsv(task.description)}",')
        ..write('"${task.status.name}",')
        ..write('"$createdAt"\n');
    }
    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  // ─── PDF builder ───────────────────────────────────────────────────────────

  static Future<Uint8List> _buildPdfBytes(List<Task> tasks) async {
    final pw.Document pdf = pw.Document();

    const Map<TaskStatus, PdfColor> statusColors = <TaskStatus, PdfColor>{
      TaskStatus.completed: PdfColors.green700,
      TaskStatus.pending: PdfColors.orange700,
      TaskStatus.ready: PdfColors.blue700,
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Text(
              AppStrings.myToDoList,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Exported on ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
            pw.Divider(thickness: 1.5),
            pw.SizedBox(height: 4),
          ],
        ),
        build: (_) => tasks
            .asMap()
            .entries
            .map(
              (MapEntry<int, Task> e) => _buildPdfTaskCard(
            index: e.key + 1,
            task: e.value,
            statusColors: statusColors,
          ),
        )
            .toList(),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfTaskCard({
    required int index,
    required Task task,
    required Map<TaskStatus, PdfColor> statusColors,
  }) {
    final PdfColor badgeColor = statusColors[task.status] ?? PdfColors.grey600;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Expanded(
                child: pw.Text(
                  '$index.  ${task.title}',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: pw.BoxDecoration(
                  color: badgeColor,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  task.status.name.toUpperCase(),
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 6),
            pw.Text(
              task.description,
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey800,
              ),
            ),
          ],
          pw.SizedBox(height: 6),
          pw.Text(
            'Created: ${_formatDate(task.createdAt ?? DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  static String _escapeCsv(String value) => value.replaceAll('"', '""');

  static String _formatDate(DateTime dt) {
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final String day = dt.day.toString().padLeft(2, '0');
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} $day, ${dt.year} – $hour:$min';
  }

  // ─── XLSX parser ───────────────────────────────────────────────────────────

  /// Parses a .xlsx file exported from this app or created manually in Excel /
  /// Google Sheets. Expected column order (row 1 = header, skipped):
  ///   A: ID  |  B: Title  |  C: Description  |  D: Status  |  E: CreatedAt
  ///
  /// Columns A and E are optional — if missing or unparseable the task is still
  /// created with an auto-id and DateTime.now() respectively.
  static List<Task> _parseXLSXContent(Uint8List bytes) {
    final Excel excel = Excel.decodeBytes(bytes);
    final List<Task> tasks = <Task>[];

    // Use the first sheet that has data.
    for (final String sheetName in excel.tables.keys) {
      final Sheet? sheet = excel.tables[sheetName];
      if (sheet == null || sheet.maxRows < 2) continue;

      // Row 0 is the header — start from row 1.
      for (int r = 1; r < sheet.maxRows; r++) {
        try {
          final List<Data?> row = sheet.row(r);

          // Helper: safely read a cell as a trimmed string.
          String cell(int col) =>
              col < row.length ? (row[col]?.value?.toString().trim() ?? '') : '';

          final String title       = cell(1); // column B
          final String description = cell(2); // column C
          final String statusStr   = cell(3); // column D
          final String dateStr     = cell(4); // column E

          if (title.isEmpty) continue; // skip blank rows

          final TaskStatus status = TaskStatus.values.firstWhere(
                (TaskStatus s) => s.name.toLowerCase() == statusStr.toLowerCase(),
            orElse: () => TaskStatus.pending,
          );

          DateTime createdAt = DateTime.now();
          if (dateStr.isNotEmpty) {
            final int? epoch = int.tryParse(dateStr);
            createdAt = epoch != null
                ? DateTime.fromMillisecondsSinceEpoch(epoch)
                : (DateTime.tryParse(dateStr) ?? DateTime.now());
          }

          tasks.add(Task(
            title: title,
            description: description,
            status: status,
            createdAt: createdAt,
          ));
        } catch (e) {
          LoggerUtils.debug('Error parsing XLSX row [$r]: $e');
        }
      }

      // Only read the first non-empty sheet.
      if (tasks.isNotEmpty) break;
    }

    return tasks;
  }

  static List<Task>? _parseByContent(String content) {
    final String t = content.trim();
    if (t.startsWith('[') || t.startsWith('{')) return _parseJSONContent(t);
    if (t.contains(',') && t.contains('\n')) return _parseCSVContent(t);
    try {
      return _parseJSONContent(t);
    } catch (_) {
      return _parseCSVContent(t);
    }
  }

  static List<Task> _parseCSVContent(String csvContent) {
    final List<Task> tasks = <Task>[];
    final List<String> lines = csvContent.split('\n');

    for (int i = 1; i < lines.length; i++) {
      final String line = lines[i].trim();
      if (line.isEmpty) continue;
      try {
        final List<String> fields = _parseCSVRow(line);
        if (fields.length < 4) continue;

        final TaskStatus status = TaskStatus.values.firstWhere(
              (TaskStatus s) => s.name == fields[3].trim(),
          orElse: () => TaskStatus.pending,
        );

        DateTime createdAt = DateTime.now();
        if (fields.length >= 5 && fields[4].trim().isNotEmpty) {
          final String raw = fields[4].trim();
          final int? epoch = int.tryParse(raw);
          createdAt = epoch != null
              ? DateTime.fromMillisecondsSinceEpoch(epoch)
              : (DateTime.tryParse(raw) ?? DateTime.now());
        }

        tasks.add(Task(
          title: fields[1],
          description: fields[2],
          status: status,
          createdAt: createdAt,
        ));
      } catch (e) {
        LoggerUtils.debug('Error parsing CSV row [$i]: $e');
      }
    }
    return tasks;
  }

  static List<String> _parseCSVRow(String row) {
    final List<String> fields = <String>[];
    bool inQuotes = false;
    final StringBuffer current = StringBuffer();

    for (int i = 0; i < row.length; i++) {
      final String ch = row[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < row.length && row[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(current.toString());
        current.clear();
      } else {
        current.write(ch);
      }
    }
    fields.add(current.toString());
    return fields;
  }

  static List<Task> _parseJSONContent(String jsonContent) {
    try {
      final dynamic data = json.decode(jsonContent);
      final List<Task> tasks = <Task>[];

      if (data is List) {
        for (final dynamic item in data) {
          final Task? t = _createTaskFromJson(item);
          if (t != null) tasks.add(t);
        }
      } else if (data is Map<String, dynamic>) {
        if (data['tasks'] is List) {
          for (final dynamic item in data['tasks'] as List<dynamic>) {
            final Task? t = _createTaskFromJson(item);
            if (t != null) tasks.add(t);
          }
        } else {
          final Task? t = _createTaskFromJson(data);
          if (t != null) tasks.add(t);
        }
      }
      return tasks;
    } catch (e) {
      LoggerUtils.debug('Error parsing JSON: $e');
      return <Task>[];
    }
  }

  static Task? _createTaskFromJson(dynamic data) {
    try {
      if (data is! Map<String, dynamic>) return null;
      final String title = data['title']?.toString() ?? '';
      if (title.isEmpty) return null;

      final String description = data['description']?.toString() ?? '';

      TaskStatus status = TaskStatus.pending;
      if (data['status'] != null) {
        final String s = data['status'].toString().toLowerCase();
        status = TaskStatus.values.firstWhere(
              (TaskStatus e) => e.name.toLowerCase() == s,
          orElse: () => TaskStatus.pending,
        );
      }

      DateTime createdAt = DateTime.now();
      final dynamic rawDate = data['createdAt'];
      if (rawDate is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
      } else if (rawDate is String && rawDate.isNotEmpty) {
        final int? epoch = int.tryParse(rawDate);
        createdAt = epoch != null
            ? DateTime.fromMillisecondsSinceEpoch(epoch)
            : (DateTime.tryParse(rawDate) ?? DateTime.now());
      }

      return Task(
        title: title,
        description: description,
        status: status,
        createdAt: createdAt,
      );
    } catch (e) {
      LoggerUtils.debug('Error creating task from JSON: $e');
      return null;
    }
  }
}

/// Internal exception used to carry user-readable import error messages
/// from [FileManagerService.importTasks] back to the controller.
class _ImportException implements Exception {
  _ImportException(this.message);
  final String message;
  @override
  String toString() => message;
}