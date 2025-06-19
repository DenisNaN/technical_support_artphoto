import 'package:intl/intl.dart';

extension DateForSQL on DateTime {
  String dateFormattedForSQL() {
    return DateFormat('yyyy.MM.dd').format(this);
  }
}

extension DateForInterface on DateTime{
  String dateFormattedForInterface(){
    return DateFormat("d MMMM yyyy", "ru_RU").format(this);
  }
}
