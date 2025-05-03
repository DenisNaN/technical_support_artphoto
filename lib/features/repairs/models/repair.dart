class Repair {
  final int id;
  final int number;
  final String category;
  final String dislocationOld;
  final String status;
  final String complaint;
  final String dateDeparture;
  final String serviceDislocation;
  final String dateTransferInService;
  final String dateDepartureFromService;
  final String worksPerformed;
  final int costService;
  final String diagnosisService;
  final String recommendationsNotes;
  final String newStatus;
  final String newDislocation;
  final String dateReceipt;
  final int idTestDrive;

  Repair(
      this.id,
      this.number,
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
      this.dateReceipt,
      this.idTestDrive);
}
