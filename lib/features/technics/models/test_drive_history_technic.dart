class TestDriveHistoryTechnic implements Comparable {
  final int id;
  final String category;
  final String dislocation;
  final DateTime dateStart;
  final DateTime dateFinish;
  String? result;
  bool isTestDriveClosed = false;
  final String user;

  TestDriveHistoryTechnic(
      {required this.id,
      required this.category,
      required this.dislocation,
      required this.dateStart,
      required this.dateFinish,
      required this.user});

  @override
  int compareTo(other) {
    return other.id.compareTo(id);
  }
}
