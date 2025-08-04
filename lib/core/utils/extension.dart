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

extension DateFromSQL on String{
  DateTime dateFormattedFromSQL(){
    return DateTime.parse(this);
  }
}

extension SymbolUppercase on String{
  String firstSymbolUppercase(){
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
