import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Trouble extends Equatable implements Comparable {
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

  Trouble(
      {required this.id,
      required this.photosalon,
      required this.dateTrouble,
      required this.employee,
      required this.numberTechnic,
      required this.trouble});

  @override
  int compareTo(other) {
    return other.id.compareTo(id!);
  }

  @override
  List<Object> get props => [photosalon, dateTrouble, employee, numberTechnic, trouble];

  Trouble copyWith() {
    Trouble newTrouble = Trouble(id: id, photosalon: photosalon, dateTrouble: dateTrouble, employee: employee, numberTechnic: numberTechnic, trouble: trouble);
    newTrouble.dateFixTroubleEmployee = dateFixTroubleEmployee;
    newTrouble.fixTroubleEmployee = fixTroubleEmployee;
    newTrouble.dateFixTroubleEngineer = dateFixTroubleEngineer;
    newTrouble.fixTroubleEngineer = fixTroubleEngineer;
    newTrouble.photoTrouble = photoTrouble;
    return newTrouble;
  }
}
