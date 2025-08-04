import 'package:technical_support_artphoto/features/test_drive/models/test_drive.dart';

class Technic{
  int id;
  int number;
  String category;
  String name;
  String status;
  String dislocation;
  DateTime dateBuyTechnic;
  int cost;
  String? comment;
  TestDrive? testDrive;

  Technic(this.id, this.number, this.category, this.name, this.status, this.dislocation, this.dateBuyTechnic, this.cost, this.comment);

  Technic copyWith(){
    Technic technic = Technic(id, number, category, name, status, dislocation, dateBuyTechnic, cost, comment);
    if(testDrive != null){
      technic.testDrive = testDrive;
    }
    return technic;
  }
}