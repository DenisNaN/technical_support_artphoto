import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'Repair.dart';

class RepairViewAndChange extends StatefulWidget {
  final Repair repair;
  const RepairViewAndChange({super.key, required this.repair});

  @override
  State<RepairViewAndChange> createState() => _RepairViewAndChangeState();
}

class _RepairViewAndChangeState extends State<RepairViewAndChange> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _innerNumberTechnic = '';
  final String _innerNumberTechnicBN = 'БН';
  // final _focusInnerNumberTechnic = FocusNode();
  String _nameTechnic = '';
  String _dislocationOld = '';
  String _status = '';
  late final _statusController;
  String _complaint = '';
  String _dateDeparture = '';
  String _dateDepartureForSQL = '';
  late final _serviceDislocation;
  String _dateTransferForService = '';
  String _dateTransferForServiceForSQL = '';
  String _dateDepartureFromService = '';
  String _dateDepartureFromServiceForSQL = '';
  final _worksPerformed = TextEditingController();
  final _costService = TextEditingController();
  final _diagnosisService = TextEditingController();
  final _recommendationsNotes = TextEditingController();
  late final _newStatus;
  late final _newDislocation;
  String _dateReceipt = '';
  String _dateReceiptForSQL = '';
  bool _isBN = false;


  @override
  void initState() {
    _innerNumberTechnic = '${widget.repair.internalID}';
    _nameTechnic = widget.repair.category;
    _dislocationOld = widget.repair.dislocationOld;
    _status = widget.repair.status;
    _statusController = SingleValueDropDownController(data: DropDownValueModel(name: widget.repair.status, value: widget.repair.status));
    _complaint = widget.repair.complaint;
    _dateDeparture = widget.repair.dateDeparture;
    _serviceDislocation = SingleValueDropDownController(data: DropDownValueModel(name: widget.repair.serviceDislocation, value: widget.repair.serviceDislocation));
    _dateTransferForService = widget.repair.dateTransferForService;
    _dateDepartureFromService = widget.repair.dateDepartureFromService;
    _worksPerformed.text = widget.repair.worksPerformed;
    _costService.text = '${widget.repair.costService}';
    _diagnosisService.text = widget.repair.diagnosisService;
    _recommendationsNotes.text = widget.repair.recommendationsNotes;
    _newStatus = SingleValueDropDownController(data: DropDownValueModel(name: widget.repair.newStatus, value: widget.repair.newStatus));
    _newDislocation = SingleValueDropDownController(data: DropDownValueModel(name: widget.repair.newDislocation, value: widget.repair.newDislocation));
    _dateReceipt = widget.repair.dateReceipt;
    _dateReceiptForSQL = widget.repair.dateReceipt;
  }

  @override
  void dispose() {
    _statusController.dispose();
    _serviceDislocation.dispose();
    _worksPerformed.dispose();
    _costService.dispose();
    _diagnosisService.dispose();
    _recommendationsNotes.dispose();
    _newStatus.dispose();
    _newDislocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
