
class Repair{
  static List repairList = [];
  static List<TotalSumRepairs> totalSumRepairs = [];

  int? id;
  int? internalID;
  String category = "";
  String dislocationOld = "";
  String status = "";
  String complaint = "";
  String dateDeparture = "";
  String serviceDislocation = "";
  String dateTransferInService = "";
  String dateDepartureFromService = "";
  String worksPerformed = "";
  int? costService;
  String diagnosisService = "";
  String recommendationsNotes = "";
  String newStatus = "";
  String newDislocation = "";
  String dateReceipt = "";
  int? idTestDrive;

  Repair(
      this.id,
      this.internalID,
      this.category,
      this.dislocationOld,
      this.status,
      this.complaint,
      this.dateDeparture,
      this.serviceDislocation,
      this.dateTransferInService,
      this.dateDepartureFromService,
      this.worksPerformed,
      this.costService,
      this.diagnosisService,
      this.recommendationsNotes,
      this.newStatus,
      this.newDislocation,
      this.dateReceipt);

  @override
  String toString() {
    return "{ id=$id, internalID=$internalID, name=$category, category=$status, coast=$serviceDislocation, dateCoast=$complaint}";
  }
}

class TotalSumRepairs{
  late int idRepair;
  late int idTechnic;
  late int sumRepair;

  TotalSumRepairs(this.idRepair, this.idTechnic, this.sumRepair);
}