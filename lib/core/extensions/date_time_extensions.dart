import 'package:intl/intl.dart';


extension DateTimeExtensions on DateTime {
  // Your existing extensions...
  String toFormattedString() => "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year";
  int get age => DateTime.now().year - year;
  String get formattedDate => DateFormat('yyyy-MM-dd').format(this);
  String get formattedTime => DateFormat('HH:mm:ss').format(this);
  String get formattedMonthYear => DateFormat('MMM yyyy').format(this);
  String get formattedDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  String get formattedDateTime12 => DateFormat('MMM d, yyyy  h:mm a').format(this);
  bool get isExpired => isBefore(DateTime.now().toUtc());
  bool get isValid => !isExpired;

  //  to-do specific extensions:
  String get taskTime {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(this);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(this);
    }
  }

  String get smartDate {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime taskDate = DateTime(year, month, day);

    if (taskDate == today) {
      return 'Today, ${DateFormat('hh:mm a').format(this)}';
    } else if (taskDate == yesterday) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(this)}';
    } else if (now.difference(this).inDays < 7) {
      return '${DateFormat('EEEE').format(this)}, ${DateFormat('hh:mm a').format(this)}';
    } else {
      return DateFormat('MMM dd, hh:mm a').format(this);
    }
  }

  String get compactTime {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(this);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(this);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(this);
    } else {
      return DateFormat('MM/dd').format(this);
    }
  }
}
