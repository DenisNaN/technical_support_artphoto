import 'package:flutter/foundation.dart';

class Trouble{
  final int id;
  final String photosalon;
  final DateTime dateTrouble;
  final String employee;
  final int numberTechnic;
  final String trouble;
  final DateTime dateFixTroubleEmployee;
  final String fixTroubleEmployee;
  final DateTime dateFixTroubleEngineer;
  final String fixTroubleEngineer;
  final Uint8List photoTrouble;

  Trouble({required this.id,
    required this.photosalon,
    required this.dateTrouble,
    required this.employee,
    required this.numberTechnic,
    required this.trouble,
    required this.dateFixTroubleEmployee,
    required this.fixTroubleEmployee,
    required this.dateFixTroubleEngineer,
    required this.fixTroubleEngineer,
    required this.photoTrouble});
}