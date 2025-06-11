import 'package:flutter/foundation.dart';

class Trouble{
  final int? id;
  final String photosalon;
  final DateTime dateTrouble;
  final String employee;
  final int numberTechnic;
  final String trouble;
  DateTime? dateFixTroubleEmployee;
  String? fixTroubleEmployee;
  DateTime? dateFixTroubleEngineer;
  String? fixTroubleEngineer;
  Uint8List? photoTrouble;

  Trouble({
    required this.id,
    required this.photosalon,
    required this.dateTrouble,
    required this.employee,
    required this.numberTechnic,
    required this.trouble});
}