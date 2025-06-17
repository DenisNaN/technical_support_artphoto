class TestDrive{
  int? id;
  final int idTechnic;
  final String categoryTechnic;
  final String dislocationTechnic;
  final DateTime dateStart;
  DateTime? dateFinish;
  String? result;
  bool? isCloseTestDrive;
  final String user;

  TestDrive({required this.idTechnic, required this.categoryTechnic, required this.dislocationTechnic, required this.dateStart, required this.user});
}