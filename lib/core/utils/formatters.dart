import 'package:flutter/services.dart';

final numberFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[0-9]'),
);


