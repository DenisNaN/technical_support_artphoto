import 'package:intl/intl.dart';

extension DateForSQL on DateTime {
  String dateFormattedForSQL() {
    return DateFormat('yyyy.MM.dd').format(this);
  }
}
