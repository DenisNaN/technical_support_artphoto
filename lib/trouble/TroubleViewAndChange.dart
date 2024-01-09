import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technical_support_artphoto/repair/RepairSQFlite.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import '../ConnectToDBMySQL.dart';
import '../technics/Technic.dart';
import '../technics/TechnicViewAndChange.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/hasNetwork.dart';
import 'package:intl/intl.dart';
import 'Trouble.dart';

class TroubleViewAndChange extends StatefulWidget {
  final Trouble trouble;
  const TroubleViewAndChange({super.key, required this.trouble});

  @override
  State<TroubleViewAndChange> createState() => _TroubleViewAndChangeState();
}

class _TroubleViewAndChangeState extends State<TroubleViewAndChange> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _innerNumberTechnic = '';
  String? _photosalon;
  String _dateTrouble = '';
  String _dateTroubleForSQL = '';
  String _categoryController = '';
  String _trouble = '';
  String _dateCheckFixTroubleEmployee = '';
  String _employeeCheckFixTrouble = '';
  String _dateCheckFixTroubleEngineer = '';
  String _engineerCheckFixTrouble = '';
  File? _imageFile;
  late Uint8List _photoTrouble;

  late TransformationController transformationController;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  TapDownDetails? tapDownDetails;

  // bool _isEditComplaint = false;
  // bool _isEdit = false;
  // bool _isEditNewStatusDislocation = false;
  int indexTechnic = 0;

  @override
  void initState() {
    for(int i = 0; i < Technic.technicList.length; i++){
      if(Technic.technicList[i].internalID == widget.trouble.internalID){
        indexTechnic = i;
        break;
      }
    }
    _innerNumberTechnic = '${widget.trouble.internalID}';
    _photosalon = widget.trouble.photosalon;
    _dateTrouble = widget.trouble.dateTrouble;
    indexTechnic != 0 ? _categoryController = Technic.technicList[indexTechnic].category : _categoryController = '';
    _trouble = widget.trouble.trouble;
    _dateCheckFixTroubleEmployee = widget.trouble.dateCheckFixTroubleEmployee;
    _employeeCheckFixTrouble = widget.trouble.employeeCheckFixTrouble;
    _dateCheckFixTroubleEngineer = widget.trouble.dateCheckFixTroubleEngineer;
    _engineerCheckFixTrouble = widget.trouble.engineerCheckFixTrouble;
    if(widget.trouble.photoTrouble != null) _photoTrouble = widget.trouble.photoTrouble!;

    transformationController = TransformationController();
    animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300)
    )..addListener(() {
      transformationController.value = animation!.value;
    });

    super.initState();
  }

  @override
  void dispose() {
    transformationController.dispose();
    animationController.dispose();
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
                            _selectedDropdownService == null){
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
                          if(isValidationNewStatusDislocation()){
                            Future<Repair> repair = _save();
                            Navigator.pop(context, repair);

                            if(_isEdit){
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
                          }
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
                              if(value != null) {
                                Technic.technicList[indexTechnic] = value;
                              }
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
                leading: const Icon(Icons.medical_information),
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
                leading: const Icon(Icons.comment),
                title: Text(_complaintController.text),
                subtitle: const Text('Жалоба'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: (){
                    setState(() {
                      _isEditComplaint = true;
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
                  leading: const Icon(Icons.miscellaneous_services),
                  subtitle: _selectedDropdownService != null ? const Text('Местонахождение техники') : null,
                  title: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(10.0),
                    isExpanded: true,
                    hint: const Text('Местонахождение техники'),
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
                        _isEdit = true;
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
                subtitle: _worksPerformed.text != '' ? const Text('Произведенные работы') : null,
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Произведенные работы"),
                  controller: _worksPerformed,
                  onChanged: (value){
                    setState(() {
                      if(value != widget.repair.worksPerformed) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                  leading: const Icon(Icons.shopify),
                  subtitle: _costService.text != '' ? const Text('Стоимость ремонта') : null,
                  title: TextFormField(
                    decoration: const InputDecoration(
                        hintText: 'Стоимость ремонта',
                        prefix: Text('₽ ')),
                    controller: _costService,
                    onChanged: (value){
                      setState(() {
                        if(value != '${widget.repair.costService}') _isEdit = true;
                      });
                    },
                    inputFormatters: [IntegerCurrencyInputFormatter()],
                    keyboardType: TextInputType.number,
                  )
              ),

              ListTile(
                leading: const Icon(Icons.comment),
                subtitle: _diagnosisService.text != '' ? const Text('Диагноз мастерской') : null,
                title: TextFormField(
                  decoration: const InputDecoration(hintText: 'Диагноз мастерской'),
                  controller: _diagnosisService,
                  onChanged: (value){
                    setState(() {
                      if(_diagnosisService.text != widget.repair.diagnosisService) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.comment),
                subtitle: _recommendationsNotes.text != '' ? const Text('Рекомендации/примечания') : null,
                title: TextFormField(
                  decoration: const InputDecoration(hintText: 'Рекомендации/примечания (необязательно)'),
                  controller: _recommendationsNotes,
                  onChanged: (value){
                    setState(() {
                      if(_recommendationsNotes.text != widget.repair.recommendationsNotes) _isEdit = true;
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.copyright),
                subtitle: _selectedDropdownStatusNew != null ? const Text('Новый статус') : null,
                title: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(10.0),
                  isExpanded: true,
                  hint: const Text('Новый статус'),
                  icon: _selectedDropdownStatusNew != null ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: (){
                        setState(() {
                          _selectedDropdownStatusNew = null;
                        });}) : null,
                  value: _selectedDropdownStatusNew,
                  items: CategoryDropDownValueModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value){
                    setState(() {
                      _selectedDropdownStatusNew = value!;
                      if(_selectedDropdownStatusNew != widget.repair.newStatus) {
                        _isEdit = true;
                        _isEditNewStatusDislocation = true;
                      }
                    });
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.local_shipping),
                subtitle: _selectedDropdownDislocationNew != null ? const Text('Куда уехал') : null,
                title: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(10.0),
                  isExpanded: true,
                  hint: const Text('Куда уехал'),
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
                      if(_selectedDropdownDislocationNew != widget.repair.newDislocation) {
                        _isEdit = true;
                        _isEditNewStatusDislocation = true;
                      }
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

  Future<Repair> _save() async{
    int costServ = -1;
    _costService.text != "" ? costServ = int.parse(_costService.text.replaceAll(",", "")) : costServ = -1;
    _selectedDropdownStatusNew = _selectedDropdownStatusNew ?? '';
    _selectedDropdownDislocationNew = _selectedDropdownDislocationNew ?? '';

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

    await ConnectToDBMySQL.connDB.connDatabase();
    if(_isEdit) {
      ConnectToDBMySQL.connDB.updateRepairInDB(repair);
      RepairSQFlite.db.update(repair);

      if(widget.repair.internalID != -1 && _isEditNewStatusDislocation){
        repair.dateReceipt = DateFormat('yyyy.MM.dd').format(DateTime.now());
        ConnectToDBMySQL.connDB.insertStatusInDB(Technic.technicList[indexTechnic].id!, repair.newStatus, repair.newDislocation);
        TechnicSQFlite.db.updateStatusDislocationTechnic(Technic.technicList[indexTechnic].id, repair.newStatus, repair.newDislocation);
        Technic.technicList[indexTechnic].status = repair.newStatus;
        Technic.technicList[indexTechnic].dislocation = repair.newDislocation;
      }
    }
    return repair;
  }

  bool isValidationNewStatusDislocation(){
    bool result = true;

    if(_selectedDropdownStatusNew != null && _selectedDropdownDislocationNew == null){
      result = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.add_task, size: 40, color: Colors.white),
              Text(' Заполните поле "Куда уехал"'),
            ],
          ),
          duration: Duration(seconds: 5),
          showCloseIcon: true,
        ),
      );
    }
    if(_selectedDropdownStatusNew == null && _selectedDropdownDislocationNew != null){
      result = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.add_task, size: 40, color: Colors.white),
              Text(' Заполните поле "Новый статус"'),
            ],
          ),
          duration: Duration(seconds: 5),
          showCloseIcon: true,
        ),
      );
    }
    return result;
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
