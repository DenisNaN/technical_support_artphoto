
class Trouble{
  static List troubleList = [];

  int? id;
  String photosalon = '';
  String dateTrouble = '';
  String employee = '';
  int? internalID;
  String trouble = '';
  String dateCheckFixTroubleEmployee = '';
  String employeeCheckFixTrouble = '';
  String dateCheckFixTroubleEngineer = '';
  String engineerCheckFixTrouble = '';
  String photoTrouble = '';

  Trouble(
      this.id,
      this.photosalon,
      this.dateTrouble,
      this.employee,
      this.internalID,
      this.trouble,
      this.dateCheckFixTroubleEmployee,
      this.employeeCheckFixTrouble,
      this.dateCheckFixTroubleEngineer,
      this.engineerCheckFixTrouble,
      this.photoTrouble);
}