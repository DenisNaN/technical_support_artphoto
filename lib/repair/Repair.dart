
class Repair{
  static List repairList = [];

  int? id;
  int? internalID;
  String category = "";
  String dislocationOld = "";
  String status = "";
  String complaint = "";
  String dateDeparture = "";
  String serviceDislocation = "";
  String dateTransferForService = "";
  String dateDepartureFromService = "";
  String worksPerformed = "";
  int? costService;
  String diagnosisService = "";
  String recommendationsNotes = "";
  String newStatus = "";
  String newDislocation = "";
  String dateReceipt = "";

  Repair(
      this.id,
      this.internalID,
      this.category,
      this.dislocationOld,
      this.status,
      this.complaint,
      this.dateDeparture,
      this.serviceDislocation,
      this.dateTransferForService,
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