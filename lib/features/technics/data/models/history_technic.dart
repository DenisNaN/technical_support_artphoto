import 'package:technical_support_artphoto/core/api/data/models/location.dart';
import 'package:technical_support_artphoto/features/technics/data/models/trouble_technic_on_period.dart';

class HistoryTechnic implements Comparable{
  final int id;
  final DateTime date;
  final Location location;
  DateTime? dateDepartureFromService;
  String? worksPerformed;
  int? costService;
  String? employee;
  String? trouble;
  List<TroubleTechnicOnPeriod> listTrouble = [];

  HistoryTechnic({required this.id, required this.date, required this.location});

  @override
  int compareTo(other) {
    int dateTimeComp = other.date.compareTo(date);
    if(dateTimeComp == 0){
      return other.id.compareTo(id);
    }
    return dateTimeComp;
  }
}