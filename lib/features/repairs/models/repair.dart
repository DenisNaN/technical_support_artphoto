class Repair implements Comparable {
  int? id;
  final int numberTechnic;
  final String category;
  final String dislocationOld;
  final String status;
  final String complaint;
  final DateTime dateDeparture;
  final String whoTook;
  int idTrouble = 0;
  String? serviceDislocation;
  DateTime? dateTransferInService;
  DateTime? dateDepartureFromService;
  String? worksPerformed;
  int? costService;
  String? diagnosisService;
  String? recommendationsNotes;
  String? newStatus;
  String? newDislocation;
  DateTime? dateReceipt;
  int? idTestDrive;

  Repair(
      this.numberTechnic,
      this.category,
      this.dislocationOld,
      this.status,
      this.complaint,
      this.dateDeparture,
      this.whoTook,
      );

  Repair.fullRepair(
      this.id,
      this.numberTechnic,
      this.category,
      this.dislocationOld,
      this.status,
      this.complaint,
      this.dateDeparture,
      this.whoTook,
      this.serviceDislocation,
      this.dateTransferInService,
      this.dateDepartureFromService,
      this.worksPerformed,
      this.costService,
      this.diagnosisService,
      this.recommendationsNotes,
      this.newStatus,
      this.newDislocation,
      this.dateReceipt,
      );

  @override
  int compareTo(other) {
    if(id != null){
      return id!.compareTo(other.id);
    }
    return 0;
  }
}
