
class Technic implements Comparable{
  static List technicList = [];

  int? id;
  int? internalID;
  String name = "";
  String category = "";
  int? cost;
  String dateBuyTechnic = "";
  String status = "";
  String dislocation = "";
  String comment = "";
  String dateStartTestDrive = '';
  String dateFinishTestDrive = '';
  String resultTestDrive = '';
  bool checkboxTestDrive = false;

  Technic(this.id, this.internalID, this.name, this.category,
      this.cost, this.dateBuyTechnic, this.status, this.dislocation,
      this.comment, this.dateStartTestDrive, this.dateFinishTestDrive,
      this.resultTestDrive, this.checkboxTestDrive);

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