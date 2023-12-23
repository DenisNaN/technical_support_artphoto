import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import '../ConnectToDBMySQL.dart';
import '../technics/Technic.dart';
import '../technics/TechnicViewAndChange.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/hasNetwork.dart';
import 'package:intl/intl.dart';
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
  String _nameTechnic = '';
  String _dislocationOld = '';
  String _status = '';
  late final _statusController;
  String _complaint = '';
  final _complaintController = TextEditingController();
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

  bool _isEditStatusOld = false;
  bool _isEditComplaint = false;
  bool _isEdit = false;
  int indexTechnic = 0;

  @override
  void initState() {
    for(int i = 0; i < Technic.technicList.length; i++){
      if(Technic.technicList[i].internalID == widget.repair.internalID){
        indexTechnic = i;
        break;
      }
    }

    _innerNumberTechnic = '${widget.repair.internalID}';
    _nameTechnic = widget.repair.category;
    _dislocationOld = widget.repair.dislocationOld;
    _status = widget.repair.status;
    _statusController = SingleValueDropDownController(data: DropDownValueModel(name: widget.repair.status, value: widget.repair.status));
    _complaint = widget.repair.complaint;
    _complaintController.text = widget.repair.complaint;
    _dateDeparture = widget.repair.dateDeparture;
    _dateDepartureForSQL = widget.repair.dateDeparture;
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
    return Scaffold(
        bottomNavigationBar: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child:Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Отмена")),
                  const Spacer(),
                  TextButton(
                      onPressed: HasNetwork.isConnecting ? () {
                        if(_statusController.dropDownValue?.name == null ||
                            _complaint == "" ||
                            _dateDepartureForSQL == "" ||
                            _serviceDislocation.dropDownValue?.name == null){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.bolt, size: 40, color: Colors.white),
                                  Text('Остались не заполненые поля'),
                                ],
                              ),
                              duration: Duration(seconds: 5),
                              showCloseIcon: true,
                            ),
                          );
                        }else{
                          int _costServ;
                          _costService.text != "" ? _costServ = int.parse(_costService.text.replaceAll(",", "")) : _costServ = -1;

                          Repair repair = Repair(
                              widget.repair.id,
                              widget.repair.internalID,
                              _nameTechnic,
                              _dislocationOld,
                              _statusController.dropDownValue!.name,
                              _complaint,
                              _dateDepartureForSQL,
                              _serviceDislocation.dropDownValue!.name,
                              _dateTransferForServiceForSQL,
                              _dateDepartureFromServiceForSQL,
                              _worksPerformed.text,
                              _costServ,
                              _diagnosisService.text,
                              _recommendationsNotes.text,
                              _newStatus.dropDownValue!.name,
                              _newDislocation.dropDownValue!.name,
                              _dateReceiptForSQL
                          );

                          _save(repair);

                          Navigator.pop(context, repair);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.add_task, size: 40, color: Colors.white),
                                  Text(' Изменения внесены'),
                                ],
                              ),
                              duration: Duration(seconds: 5),
                              showCloseIcon: true,
                            ),
                          );
                        }
                      } : null,
                      child: HasNetwork.isConnecting ? const Text("Сохранить") :
                      const Text("Сохранить", style: TextStyle(color:  Colors.grey),
                      ))
                ],
              ),
            )
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.fiber_new),
                title: widget.repair.internalID != -1 ?
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 0.0),
                          alignment: Alignment.centerLeft,
                          textStyle: const TextStyle(fontSize: 20)
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.technicList[indexTechnic]))).then(
                                  (value){
                                setState(() {
                                  if(value != null) Technic.technicList[indexTechnic] = value;
                                });
                              });
                        },
                        child: Text('№ - $_innerNumberTechnic'
                        )
                      )
                    // )
                    : const Text('БН'),
                ),

              ListTile(
                leading: const Icon(Icons.create),
                title: Text(_nameTechnic),
                subtitle: const Text('Наименование техники'),
              ),

              _isEditStatusOld ?
              ListTile(
                leading: const Icon(Icons.print),
                title: DropDownTextField(
                  controller: _statusController,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Выберите статус"),
                  dropDownItemCount: 4,
                  dropDownList: CategoryDropDownValueModel.statusForEquipment,
                ),
              ) :
              ListTile(
                leading: const Icon(Icons.print),
                title: Text(_status),
                subtitle: const Text('Статус техники'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: (){
                    setState(() {
                      _isEditStatusOld = true;
                    });
                  },
                ),
              ),

              _isEditComplaint ?
              ListTile(
                leading: const Icon(Icons.create),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Наименование техники"),
                  controller: _complaintController,
                ),
              ) :
              ListTile(
                leading: const Icon(Icons.create),
                title: Text(_complaint),
                subtitle: const Text('Жалоба'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: (){
                    setState(() {
                      _isEditComplaint = true;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.today),
                title: Text(DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateDeparture.replaceAll('.', '-')))),
                subtitle: const Text("Забрали с точки. Дата"),
                trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2099),
                          locale: const Locale("ru", "RU")
                      ).then((date) {
                        setState(() {
                          if(date != null) {
                            _dateDepartureForSQL = DateFormat('yyyy.MM.dd').format(date);
                            _dateDeparture = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                            _isEdit = true;
                          }
                        });
                      });
                    },
                    color: Colors.blue
                ),
              ),

              ListTile(
                leading: const Icon(Icons.copyright),
                title: DropDownTextField(
                  controller: _serviceDislocation,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Местонахождение техники"),
                  dropDownItemCount: 4,
                  dropDownList: CategoryDropDownValueModel.service,
                  onChanged: (value){
                    setState(() {
                      if(_serviceDislocation.dropDownValue!.name != widget.repair.serviceDislocation) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.today),
                title: Text(_dateTransferForService == '' ? 'Выберите дату' : DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateTransferForService.replaceAll('.', '-')))),
                subtitle: const Text("Дата сдачи в ремонт"),
                trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2099),
                          locale: const Locale("ru", "RU")
                      ).then((date) {
                        setState(() {
                          if(date != null) {
                            _dateTransferForServiceForSQL = DateFormat('yyyy.MM.dd').format(date);
                            _dateTransferForService = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                            _isEdit = true;
                          }
                        });
                      });
                    },
                    color: Colors.blue
                ),
              ),

              ListTile(
                leading: const Icon(Icons.today),
                title: Text(_dateDepartureFromService == '' ? 'Выберите дату' : DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateDepartureFromService.replaceAll('.', '-')))),
                subtitle: const Text("Забрали из ремонта. Дата"),
                trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2099),
                          locale: const Locale("ru", "RU")
                      ).then((date) {
                        setState(() {
                          if(date != null) {
                            _dateDepartureFromServiceForSQL = DateFormat('yyyy.MM.dd').format(date);
                            _dateDepartureFromService = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                            _isEdit = true;
                          }
                        });
                      });
                    },
                    color: Colors.blue
                ),
              ),

              ListTile(
                leading: const Icon(Icons.comment),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Произведенные работы"),
                  controller: _worksPerformed,
                  // initialValue: _worksPerformed.text,
                  onChanged: (value){
                    setState(() {
                      if(_worksPerformed.text != widget.repair.worksPerformed) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                  leading: const Icon(Icons.shopify),
                  title: TextFormField(
                    decoration: const InputDecoration(
                        hintText: "Стоимость ремонта",
                        prefix: Text('₽ ')),
                    controller: _costService,
                    // initialValue: _costService.text,
                    inputFormatters: [IntegerCurrencyInputFormatter()],
                    keyboardType: TextInputType.number,
                  )
              ),

              ListTile(
                leading: const Icon(Icons.comment),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Диагноз мастерской"),
                  controller: _diagnosisService,
                  // initialValue: _diagnosisService.text,
                  onChanged: (value){
                    setState(() {
                      if(_diagnosisService.text != widget.repair.diagnosisService) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.comment),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Рекомендации/примечания"),
                  controller: _recommendationsNotes,
                  // initialValue: _recommendationsNotes.text,
                  onChanged: (value){
                    setState(() {
                      if(_recommendationsNotes.text != widget.repair.recommendationsNotes) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.copyright),
                title: DropDownTextField(
                  controller: _newStatus,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Новый статус"),
                  dropDownItemCount: 4,
                  dropDownList: CategoryDropDownValueModel.statusForEquipment,
                  onChanged: (value){
                    setState(() {
                      if(_newStatus.dropDownValue!.name != widget.repair.newStatus) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.copyright),
                title: DropDownTextField(
                  controller: _newDislocation,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Куда уехал"),
                  dropDownItemCount: 4,
                  dropDownList: CategoryDropDownValueModel.statusForEquipment,
                  onChanged: (value){
                    setState(() {
                      if(_newDislocation.dropDownValue!.name != widget.repair.newDislocation) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.today),
                title: Text(_dateReceipt == '' ? 'Выберите дату' : DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateReceipt.replaceAll('.', '-')))),
                subtitle: const Text("Дата поступления"),
                trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2099),
                          locale: const Locale("ru", "RU")
                      ).then((date) {
                        setState(() {
                          if(date != null) {
                            _dateReceiptForSQL = DateFormat('yyyy.MM.dd').format(date);
                            _dateReceipt = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                            _isEdit = true;
                          }
                        });
                      });
                    },
                    color: Colors.blue
                ),
              ),

            ],
          ),
        )
    );
  }

  void _save (Repair repair) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    // if(_isEditCategory || _isEditName || _isEditCost || _isEditDateBuy || _isEditComment) {
    //   ConnectToDBMySQL.connDB.updateTechnicInDB(technic);
    // }
    // if(_isEditStatusDislocation){
    //   ConnectToDBMySQL.connDB.insertStatusInDB(technic);
    // }
    // if(_isEditTestDrive || _isEditSwitch){
    //   ConnectToDBMySQL.connDB.insertTestDriveInDB(technic);
    // }
    //
    // if(_isEditCategory || _isEditName || _isEditCost || _isEditDateBuy || _isEditComment || _isEditStatusDislocation || _isEditTestDrive || _isEditSwitch) {
    //   TechnicSQFlite.db.updateTechnic(technic);
    // }
  }
}

class IntegerCurrencyInputFormatter extends TextInputFormatter {

  final validationRegex = RegExp(r'^[\d,]*$');
  final replaceRegex = RegExp(r'[^\d]+');
  static const thousandSeparator = ',';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue
      ) {
    if (!validationRegex.hasMatch(newValue.text)) {
      return oldValue;
    }

    final newValueNumber = newValue.text.replaceAll(replaceRegex, '');

    var formattedText = newValueNumber;

    /// Add thousand separators.
    var index = newValueNumber.length;

    while (index > 0) {
      index -= 3;

      if (index > 0) {
        formattedText = formattedText.substring(0, index)
            + thousandSeparator
            + formattedText.substring(index, formattedText.length);
      }
    }

    /// Check whether the text is unmodified.
    if (oldValue.text == formattedText) {
      return oldValue;
    }

    /// Handle moving cursor.
    final initialNumberOfPrecedingSeparators = oldValue.text.characters
        .where((e) => e == thousandSeparator)
        .length;
    final newNumberOfPrecedingSeparators = formattedText.characters
        .where((e) => e == thousandSeparator)
        .length;
    final additionalOffset = newNumberOfPrecedingSeparators - initialNumberOfPrecedingSeparators;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newValue.selection.baseOffset + additionalOffset),
    );
  }
}
