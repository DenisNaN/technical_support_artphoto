import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final numberFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[0-9]'),
);

String getDateFormatForInterface(DateTime date) {
  return DateFormat("d MMMM yyyy", "ru_RU").format(date);
}
