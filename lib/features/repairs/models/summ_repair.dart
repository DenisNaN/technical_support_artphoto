class SumRepair {
  final int idRepair;
  final String repairmen;
  final int sumRepair;
  final String complaint;
  final String worksPerformed;
  DateTime? dateTransferInService;
  DateTime? dateReceipt;

  SumRepair(
      {required this.idRepair,
      required this.repairmen,
      required this.sumRepair,
      required this.complaint,
      required this.worksPerformed,
      required this.dateTransferInService,
      required this.dateReceipt});
}
