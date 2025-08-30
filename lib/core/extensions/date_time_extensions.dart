import 'package:intl/intl.dart';


extension DateTimeExtensions on DateTime {
  String toFormattedString() => "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year";

  int get age => DateTime.now().year - year;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(this);

  String get formattedTime => DateFormat('HH:mm:ss').format(this);

  String get formattedMonthYear => DateFormat('MMM yyyy').format(this);

  String get formattedDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  String get formattedDateTime12 => DateFormat('MMM d, yyyy  h:mm a').format(this);

  bool get isExpired => isBefore(DateTime.now().toUtc());


  bool get isValid => !isExpired;


}
