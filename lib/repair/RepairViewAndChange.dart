import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _statusOld = '';
  final _complaintController = TextEditingController();
  String _dateDeparture = '';
  late final _serviceDislocation;
  String _dateTransferForService = '';
  String _dateDepartureFromService = '';
  final _worksPerformed = TextEditingController();
  final _costService = TextEditingController();
  final _diagnosisService = TextEditingController();
  final _recommendationsNotes = TextEditingController();
  late final _newStatus;
  late final _newDislocation;
  String _dateReceipt = '';
  String? _selectedDropdownDislocationOld;
  String? _selectedDropdownStatusOld;
  String? _selectedDropdownService;
  String? _selectedDropdownStatusNew;
  String? _selectedDropdownDislocationNew;

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
    _selectedDropdownStatusOld = widget.repair.status;
    _selectedDropdownDislocationOld = widget.repair.dislocationOld;
    _complaintController.text = widget.repair.complaint;
    _dateDeparture = widget.repair.dateDeparture;
    _selectedDropdownService = widget.repair.serviceDislocation;
    _dateTransferForService = widget.repair.dateTransferForService;
    _dateDepartureFromService = widget.repair.dateDepartureFromService;
    _worksPerformed.text = widget.repair.worksPerformed;
    _costService.text = '${widget.repair.costService}';
    _diagnosisService.text = widget.repair.diagnosisService;
    _recommendationsNotes.text = widget.repair.recommendationsNotes;
    _selectedDropdownStatusNew = widget.repair.newStatus;
    _selectedDropdownDislocationNew = widget.repair.newDislocation;
    _dateReceipt = widget.repair.dateReceipt;
    super.initState();
  }

  @override
  void dispose() {
    _complaintController.dispose();
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
                        if(_complaintController.text == "" ||
                            _dateDeparture == "" ||
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
                          int costServ = -1;
                          _costService.text != "" ? costServ = int.parse(_costService.text.replaceAll(",", "")) : costServ = -1;

                          Repair repair = Repair(
                              widget.repair.id,
                              widget.repair.internalID,
                              _nameTechnic,
                              _selectedDropdownDislocationOld!,
                              _selectedDropdownStatusOld!,
                              _complaintController.text,
                              _dateDeparture,
                              _selectedDropdownService!,
                              _dateTransferForService,
                              _dateDepartureFromService,
                              _worksPerformed.text,
                              costServ,
                              _diagnosisService.text,
                              _recommendationsNotes.text,
                              _selectedDropdownStatusNew!,
                              _selectedDropdownDislocationNew!,
                              _dateReceipt
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
                title: Text('Наименование: $_nameTechnic\n'
                            'Статус: $_selectedDropdownStatusOld'),
                subtitle: Text('Откуда забрали: $_selectedDropdownDislocationOld'),
              ),

              _isEditComplaint ?
              ListTile(
                leading: const Icon(Icons.create),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Жалоба"),
                  controller: _complaintController,
                ),
              ) :
              ListTile(
                leading: const Icon(Icons.create),
                title: Text(_complaintController.text),
                subtitle: const Text('Жалоба'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: (){
                      setState(() {
                        _isEditComplaint = !_isEditComplaint;
                        _isEdit = true;
                      }
                    );
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
                            _dateDeparture = DateFormat('yyyy.MM.dd').format(date);
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
                  title: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(10.0),
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    isExpanded: true,
                    hint: Text('Местонахождение техники'),
                    icon: _selectedDropdownService != null ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: (){
                        setState(() {
                          _selectedDropdownService = null;
                        });}) : null,
                    value: _selectedDropdownService,
                    items: CategoryDropDownValueModel.service.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value){
                      setState(() {
                        _selectedDropdownService = value!;
                      });
                    },
                  )
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
                            _dateTransferForService = DateFormat('yyyy.MM.dd').format(date);
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
                            _dateDepartureFromService = DateFormat('yyyy.MM.dd').format(date);
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
                title: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(10.0),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  isExpanded: true,
                  hint: Text('Новый статус'),
                  icon: _selectedDropdownService != null ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: (){
                        setState(() {
                          _selectedDropdownService = null;
                        });}) : null,
                  value: _selectedDropdownService,
                  items: CategoryDropDownValueModel.service.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value){
                    setState(() {
                      _selectedDropdownService = value!;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.copyright),
                title: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(10.0),
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  isExpanded: true,
                  hint: Text('Куда уехал'),
                  icon: _selectedDropdownDislocationNew != null ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: (){
                        setState(() {
                          _selectedDropdownDislocationNew = null;
                        });}) : null,
                  value: _selectedDropdownDislocationNew,
                  items: CategoryDropDownValueModel.photosalons.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value){
                    setState(() {
                      _selectedDropdownDislocationNew = value!;
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
                            _dateReceipt = DateFormat('yyyy.MM.dd').format(date);
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
    if(_isEdit) {
      // ConnectToDBMySQL.connDB.updateTechnicInDB(repair);
    }
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
