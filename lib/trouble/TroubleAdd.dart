import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../ConnectToDBMySQL.dart';
import '../technics/Technic.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/utils.dart';

class TroubleAdd extends StatefulWidget {
  const TroubleAdd({super.key});

  @override
  State<TroubleAdd> createState() => _TroubleAddState();
}

class _TroubleAddState extends State<TroubleAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _photosalon;
  String _dateTrouble = '';
  String _dateTroubleForSQL = '';
  String? _employee;
  final _innerNumberTechnic = TextEditingController();
  final _focusInnerNumberTechnic = FocusNode();
  String _category = "";
  final _categoryController = TextEditingController();
  final _trouble = TextEditingController();
  String dateCheckFixTroubleEmployee = '';
  String employeeCheckFixTrouble = '';
  String dateCheckFixTroubleEngineer = '';
  String engineerCheckFixTrouble = '';
  String photoTrouble = '';
  bool _isBN = false;

  Technic technicFind = Technic(-1, -1, 'name', 'category', -1, 'dateBuyTechnic', 'status',
      'dislocation', 'comment', 'dateStartTestDrive', 'dateFinishTestDrive', 'resultTestDrive', false);

  @override
  void initState() {
    _focusInnerNumberTechnic.addListener(() {
      if (!_focusInnerNumberTechnic.hasFocus) {
        technicFind =
            Technic.technicList.firstWhere((item) => item.internalID
                .toString() == _innerNumberTechnic.text,
                orElse: () =>
                    Technic(-1, -1, 'name', 'category', -1, 'dateBuyTechnic', 'status', 'dislocation',
                        'comment', 'dateStartTestDrive', 'dateFinishTestDrive', 'resultTestDrive', false));
        _category = technicFind.name;
        if (technicFind.id == -1) {
          setState(() {
            _innerNumberTechnic.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.bolt, size: 40, color: Colors.white),
                  Text(
                      'Teхника с этим номером\nв базе не найдена.'),
                ],
              ),
              duration: Duration(seconds: 5),
              showCloseIcon: true,
            ),
          );
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _innerNumberTechnic.dispose();
    _focusInnerNumberTechnic.dispose();
    _trouble.dispose();
    _categoryController.dispose();
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
                      onPressed: () {
                        if(_isValidateToSave() == false){
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
                          _save();
                        }
                      },
                      child: const Text("Сохранить"))
                ],
              ),
            )
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
            child: Column(children:[
              SizedBox(key: _formKey, height: 20),
              _buildInnerNumberTechnicListTile(),
              _buildCategoryListTile(),
              _buildDislocationOldListTile(),
              _buildStatusListTile(),
              _buildComplaintListTile(),
              _buildDateDepartureListTile(),
              _buildServiceDislocationListTile(),
              _buildDateTransferForServiceListTile(),
              _buildDateDepartureFromServiceListTile(),
              _buildWorksPerformedListTile(),
              _buildCostServiceListTile(),
              _buildDiagnosisServiceListTile(),
              _buildRecommendationsNotesListTile(),
              _buildNewStatusListTile(),
              _buildNewDislocationListTile(),
              _buildDateReceiptListTile(),
            ]),
          ),
        )
    );
  }

  ListTile _buildInnerNumberTechnicListTile(){
    final numberFormatter = FilteringTextInputFormatter.allow(
      RegExp(r'[0-9]'),
    );

    return ListTile(
        leading: const Icon(Icons.fiber_new),
        title: !_isBN ? TextFormField(
          decoration: const InputDecoration(hintText: "Номер техники"),
          focusNode: _focusInnerNumberTechnic,
          controller: _innerNumberTechnic,
          inputFormatters: [numberFormatter],
          keyboardType: TextInputType.number,
        ) :
        const Text('БН'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Без номера '),
            Switch(
                value: _isBN,
                onChanged: (value){
                  setState(() {
                    _isBN = value;
                  });
                }
            ),
          ],)
    );
  }

  ListTile _buildCategoryListTile(){
    return _isBN ? ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Наименование техники"),
        controller: _categoryController,
      ),
    ) : ListTile(
      leading: const Icon(Icons.print),
      title: technicFind.id == -1 ? const Text('Введите номер техники') : Text('Наименование: ${technicFind.name}'),
    );
  }

  ListTile _buildDislocationOldListTile(){
    return _isBN ? ListTile(
      leading: const Icon(Icons.copyright),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        isExpanded: true,
        hint: const Text('Фотосалон'),
        icon: _photosalon != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _photosalon = null;
              });}) : null,
        value: _photosalon,
        items: CategoryDropDownValueModel.photosalons.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _photosalon = value!;
          });
        },
      ),
    ) : ListTile(
      leading: const Icon(Icons.print),
      title: technicFind.id == -1 ? const Text('Введите номер техники') : Text('Последний фотосалон: ${technicFind.dislocation}'),
    );
  }

  ListTile _buildDateDepartureListTile(){
    return ListTile(
      leading: const Icon(Icons.today),
      title: const Text("Дата проблемы"),
      subtitle: Text(_dateTrouble == "" ? "Выберите дату" : _dateTrouble),
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
                  _dateTroubleForSQL = DateFormat('yyyy.MM.dd').format(date);
                  _dateTrouble = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                }
              });
            });
          },
          color: Colors.blue
      ),
    );
  }

  ListTile _buildServiceDislocationListTile(){
    Iterable<String> employee = LoginPassword.loginPassword.values;
    return ListTile(
      leading: const Icon(Icons.copyright),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        isExpanded: true,
        hint: const Text('Сотрудник'),
        icon: _employee != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _employee = null;
              });}) : null,
        value: _employee,
        items: employee.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _employee = value!;
          });
        },
      ),
    );
  }

  ListTile _buildComplaintListTile(){
    return ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Жалоба"),
        controller: _trouble,
      ),
    );
  }

  ListTile _buildDateReceiptListTile(){
    return ListTile(
      leading: const Icon(Icons.today),
      title: const Text("Дата поступления"),
      subtitle: Text(_dateReceipt == "" ? "Выберите дату" : _dateReceipt),
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
                }
              });
            });
          },
          color: Colors.blue
      ),
    );
  }

  bool _isValidateToSave(){
    bool validate = false;
    if((!_isBN ? _innerNumberTechnic.text != "" : _innerNumberTechnicBN == "БН") &&
        (!_isBN ? _category != "" : _categoryController.text != "") &&
        (!_isBN ? _selectedDropdownDislocationOld != "" : _selectedDropdownDislocationOld != null) &&
        _selectedDropdownStatusOld != null &&
        _complaint.text != "" &&
        _dateDeparture != "" &&
        _selectedDropdownService != null) {
      validate = true;
    }
    return validate;
  }

  void _save(){
    int costServ;
    if(_isBN) _innerNumberTechnic.text = '-1';
    String newStatusStr;
    String newDislocationStr;
    _costService.text != "" ? costServ = int.parse(_costService.text.replaceAll(",", "")) : costServ = 0;
    _selectedDropdownStatusNew != null ? newStatusStr = _selectedDropdownStatusNew! : newStatusStr = "";
    _selectedDropdownDislocationNew != null ? newDislocationStr = _selectedDropdownDislocationNew! : newDislocationStr = "";

    Repair repairLast = Repair.repairList.first;
    Repair repair = Repair(
        repairLast.id! + 1,
        int.parse(_innerNumberTechnic.text),
        _isBN ? _categoryController.text : _category,
        _isBN ? _selectedDropdownDislocationOld! : _dislocationOld,
        _selectedDropdownStatusOld!,
        _complaint.text,
        _dateDepartureForSQL,
        _selectedDropdownService!,
        _dateTransferForServiceForSQL,
        _dateDepartureFromServiceForSQL,
        _worksPerformed.text,
        costServ,
        _diagnosisService.text,
        _recommendationsNotes.text,
        newStatusStr,
        newDislocationStr,
        _dateReceiptForSQL
    );

    ConnectToDBMySQL.connDB.insertRepairInDB(repair);

    Navigator.pop(context, repair);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.add_task, size: 40, color: Colors.white),
            Text(' Техника в ремонт добавлена'),
          ],
        ),
        duration: Duration(seconds: 5),
        showCloseIcon: true,
      ),
    );
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