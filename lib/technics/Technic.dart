
class Technic implements Comparable{
  static List technicList = [];
  static List testDriveList = [];

  int? id;
  int? internalID;
  String name = "";
  String category = "";
  int? cost;
  String dateBuyTechnic = "";
  String status = "";
  String dislocation = "";
  String dateChangeStatus = '';
  String comment = "";
  String testDriveDislocation = "";
  String dateStartTestDrive = '';
  String dateFinishTestDrive = '';
  String resultTestDrive = '';
  bool checkboxTestDrive = false;
  String userTestDrive = '';
  int? idTestDrive;

  Technic(this.id, this.internalID, this.name, this.category, this.cost,
      this.dateBuyTechnic, this.status, this.dislocation, this.comment,
      this.testDriveDislocation, this.dateChangeStatus, this.dateStartTestDrive,
      this.dateFinishTestDrive, this.resultTestDrive, this.checkboxTestDrive);

  Technic.testDrive(this.internalID, this.category, this.testDriveDislocation,
      this.dateStartTestDrive, this.dateFinishTestDrive, this.resultTestDrive,
      this.checkboxTestDrive, this.userTestDrive);

  @override
  String toString() {
    return "{ id=$id, internalID=$internalID, name=$name, category=$category, coast=$cost, dateCoast=$dateBuyTechnic, status=$status, dislocation=$dislocation, comment=$comment }";
  }

  @override
  int compareTo(other) {
    int dislocationDiference = dislocation.compareTo(other.dislocation);
    return dislocationDiference != 0 ? dislocationDiference : category.compareTo(other.category);
  }
}