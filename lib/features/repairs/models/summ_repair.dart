class SummRepair {
  final int idRepair;
  final String repairmen;
  final int summRepair;
  final String complaint;
  final String worksPerformed;
  DateTime? dateTransferInService;
  DateTime? dateReceipt;

  SummRepair(
      {required this.idRepair,
      required this.repairmen,
      required this.summRepair,
      required this.complaint,
      required this.worksPerformed,
      required this.dateTransferInService,
      required this.dateReceipt});
}
