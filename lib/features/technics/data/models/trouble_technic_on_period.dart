import 'package:technical_support_artphoto/core/api/data/models/location.dart';

class TroubleTechnicOnPeriod implements Comparable{
  final int id;
  final DateTime date;
  final Location location;
  String? employee;
  String? trouble;

  TroubleTechnicOnPeriod({required this.id, required this.date, required this.location});

  @override
  int compareTo(other) {
    int dateTimeComp = other.date.compareTo(date);
    if(dateTimeComp == 0){
      return other.id.compareTo(id);
    }
    return dateTimeComp;
  }
}