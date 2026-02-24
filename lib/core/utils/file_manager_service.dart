import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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

  static Future<List<Task>?> importTasks() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['csv', 'json'],
        dialogTitle: 'Select CSV or JSON file to import',
      );

      if (result == null || result.files.single.path == null) return null;

      final File file = File(result.files.single.path!);
      if (!file.existsSync()) {
        LoggerUtils.debug('Import file does not exist: ${file.path}');
        return null;
      }

      final String contents = await file.readAsString(encoding: utf8);
      if (contents.trim().isEmpty) return <Task>[];

      final String name = result.files.single.name.toLowerCase();
      if (name.endsWith('.csv')) return _parseCSVContent(contents);
      if (name.endsWith('.json')) return _parseJSONContent(contents);
      return _parseByContent(contents);
    } catch (e) {
      LoggerUtils.debug('Error importing file: $e');
      return null;
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