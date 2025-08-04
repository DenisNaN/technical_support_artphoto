class TestDrive{
  int? id;
  final int idTechnic;
  final String categoryTechnic;
  final String dislocationTechnic;
  final DateTime dateStart;
  final DateTime dateFinish;
  final String result;
  final bool isCloseTestDrive;
  final String user;

  TestDrive({
    this.id,
    required this.idTechnic,
    required this.categoryTechnic,
    required this.dislocationTechnic,
    required this.dateStart,
    required this.dateFinish,
    required this.result,
    required this.isCloseTestDrive,
    required this.user});
}