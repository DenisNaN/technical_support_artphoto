import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import '../ConnectToDBMySQL.dart';
import '../history/History.dart';
import '../history/HistorySQFlite.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/utils.dart';
import 'Technic.dart';

class TechnicAdd extends StatefulWidget {
  const TechnicAdd({super.key});

  @override
  State<TechnicAdd> createState() => _TechnicAddState();
}

class _TechnicAddState extends State<TechnicAdd> {
  final _innerNumberTechnic = TextEditingController();
  final _nameTechnic = TextEditingController();
  final _costTechnic = TextEditingController();
  String _dateBuyTechnic = '';
  String _dateForSQL = DateFormat('yyyy.MM.dd').format(DateTime.now());
  final _comment = TextEditingController();
  String _dateStartTestDrive = DateFormat('d MMMM yyyy', 'ru_RU').format(DateTime.now());
  String _dateStartTestDriveForSQL = '';
  String _dateFinishTestDrive = '';
  String _dateFinishTestDriveForSQL = '';
  final _resultTestDrive = TextEditingController();
  String? _selectedDropdownCategory;
  String? _selectedDropdownDislocation;
  String? _selectedDropdownStatus;
  String? _selectedDropdownTestDriveDislocation;
  bool _switchTestDrive = false;
  bool _checkboxTestDrive = false;
  bool _isCategoryPhotocamera = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _innerNumberTechnic.dispose();
    _nameTechnic.dispose();
    _costTechnic.dispose();
    _comment.dispose();
    _resultTestDrive.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameTechnic.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
            ),
          ),
          title: const Text('Добавление техники'),
        ),
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
                        // checking the unique number of the equipment
                        if (_formKey.currentState!.validate()) {
                          String validationEmptyFields = validateEmptyFields();
                          if (validationEmptyFields != '') {
                                viewSnackBar(validationEmptyFields);
                          } else {
                            List tmpListTechnic = Technic.technicList;
                            tmpListTechnic.sort((technic1, technic2) => technic1.id.compareTo(technic2.id));
                            Technic technicLast = Technic.technicList.last;

                            Technic technic = Technic(
                                technicLast.id! + 1,
                                int.parse(_innerNumberTechnic.text),
                                _nameTechnic.text,
                                _selectedDropdownCategory!,
                                int.parse(_costTechnic.text.replaceAll(",", "")),
                                _dateForSQL,
                                _selectedDropdownStatus!,
                                _selectedDropdownDislocation!,
                                _comment.text,
                                _selectedDropdownTestDriveDislocation ??= '',
                                _dateStartTestDriveForSQL,
                                _dateFinishTestDriveForSQL,
                                _resultTestDrive.text,
                                _checkboxTestDrive
                            );

                            save(technic);
                            Technic.technicList.sort();
                            Navigator.pop(context, technic);
                            viewSnackBar(' Техника добавлена');
                          }
                        }
                      },
                      child: const Text("Сохранить"))
                ],
              ),
            )
        ),
        body: Form(
          key: _formKey,
          child:
            ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildInternalID(),
                _buildNameCategory(),
                _buildNameTechnic(),
                _buildCostTechnic(),
                _buildDateBuyTechnic(),
                _buildStatus(),
                _buildDislocation(),
                _buildComment(),
                _buildSwitchTestDrive(),
                _buildTestDrive()
              ],
            )
        )
    );
  }

  final numberFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9]'),
  );

  ListTile _buildInternalID() {
    return ListTile(
      leading: const Icon(Icons.fiber_new),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Номер техники"),
        controller: _innerNumberTechnic,
        validator: (value) {
          List listInternalID = [];
          Technic.technicList.forEach((element) {listInternalID.add(element.internalID.toString());});
          if (listInternalID.contains(value)) {
            return 'Техника с таким номером уже есть';
          }
          return null;
        },
        inputFormatters: [numberFormatter],
        keyboardType: TextInputType.number,
      ),
    );
  }

  ListTile _buildNameCategory() {
    return ListTile(
      leading: const Icon(Icons.print),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        isExpanded: true,
        hint: const Text('Наименование техники'),
        icon: _selectedDropdownCategory != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _selectedDropdownCategory = null;
              });}) : null,
        value: _selectedDropdownCategory,
        items: CategoryDropDownValueModel.nameEquipment.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _selectedDropdownCategory = value!;
            if(value == 'Фотоаппарат') {
              _isCategoryPhotocamera = true;
              _dateFinishTestDriveForSQL = '';
            }
            else {
              _isCategoryPhotocamera = false;
              if(_dateFinishTestDriveForSQL == '' && _dateStartTestDriveForSQL != ''){
                DateTime finishTestDrive = DateFormat('yyyy.MM.dd').parse(_dateStartTestDriveForSQL).add(const Duration(days: 14));
                _dateFinishTestDriveForSQL = DateFormat('yyyy.MM.dd').format(finishTestDrive);
              }
            }
          });
        },
      ),
    );
  }

  ListTile _buildNameTechnic() {
    return ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Модель техники"),
        controller: _nameTechnic,
      ),
    );
  }

  ListTile _buildCostTechnic() {
    return ListTile(
      leading: const Icon(Icons.shopify),
      title: TextFormField(
        decoration: const InputDecoration(
            hintText: "Стоимость техники",
            prefix: Text('₽ ')),
        controller: _costTechnic,
        inputFormatters: [IntegerCurrencyInputFormatter()],
        keyboardType: TextInputType.number,
      )
    );
  }

  ListTile _buildDateBuyTechnic() {
    return ListTile(
      leading: const Icon(Icons.today),
      title: const Text("Дата покупки техники"),
      subtitle: Text(_dateBuyTechnic == "" ? 'Выберите дату' : _dateBuyTechnic),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
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
                      _dateForSQL = DateFormat('yyyy.MM.dd').format(date);
                      _dateBuyTechnic = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                    }
                  });
                });
              },
              color: Colors.blue
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  _dateForSQL = '';
                  _dateBuyTechnic = '';
                });
              },
              icon: const Icon(Icons.clear))
        ],
      ),
    );
  }

  ListTile _buildStatus() {
    return ListTile(
      leading: const Icon(Icons.copyright),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        isExpanded: true,
        hint: const Text('Статус техники'),
        icon: _selectedDropdownStatus != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _selectedDropdownStatus = null;
              });}) : null,
        value: _selectedDropdownStatus,
        items: CategoryDropDownValueModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _selectedDropdownStatus = value!;
          });
        },
      ),
    );
  }

  ListTile _buildDislocation() {
    return ListTile(
      leading: const Icon(Icons.airport_shuttle),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        isExpanded: true,
        hint: const Text('Дислокация техники'),
        icon: _selectedDropdownDislocation != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _selectedDropdownDislocation = null;
              });}) : null,
        value: _selectedDropdownDislocation,
        items: CategoryDropDownValueModel.photosalons.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _selectedDropdownDislocation = value!;
          });
        },
      ),
    );
  }

  ListTile _buildComment() {
    return ListTile(
      leading: const Icon(Icons.comment),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Комментарий (необязательно)"),
        controller: _comment,
      ),
    );
  }

  ListTile _buildSwitchTestDrive() {
    return ListTile(
      title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _switchTestDrive ? const Text('Выключить тест-драйв ') : const Text('Включить тест-драйв '),
            Switch(
                value: _switchTestDrive,
                onChanged: (value){
                  setState(() {
                    _switchTestDrive = value;
                    if(!_switchTestDrive){
                      _dateStartTestDriveForSQL = '';
                      _dateFinishTestDriveForSQL = '';
                      _resultTestDrive.text = '';
                      _checkboxTestDrive = false;
                    } else{
                      _dateStartTestDriveForSQL = DateFormat('yyyy.MM.dd').format(DateTime.now());
                    }
                    if(_switchTestDrive && !_checkboxTestDrive && _dateFinishTestDriveForSQL == '' && !_isCategoryPhotocamera){
                      DateTime finishTestDrive = DateFormat('yyyy.MM.dd').parse(_dateStartTestDriveForSQL).add(const Duration(days: 14));
                      _dateFinishTestDriveForSQL = DateFormat('yyyy.MM.dd').format(finishTestDrive);
                    }
                  });
                }
            ),
          ]
      ),
    );
  }

  ListTile _buildTestDrive() {
   return ListTile(title:
  _switchTestDrive ? _buildTestDriveListTile() : const Text('Тест-драйв не проводился')
  );
  }

  ListTile _buildTestDriveListTile(){
    return ListTile(
      title: Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
          leading: const Icon(Icons.airport_shuttle),
          title: DropdownButton<String>(
            isExpanded: true,
            hint: const Text('Место тест-драйва'),
            icon: _selectedDropdownTestDriveDislocation != null ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: (){
                  setState(() {
                    _selectedDropdownTestDriveDislocation = null;
                  }
                  );
                }) : null,
            value: _selectedDropdownTestDriveDislocation,
            items: CategoryDropDownValueModel.photosalons.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value){
              setState(() {
                _selectedDropdownTestDriveDislocation = value!;
              });
            },
          ),
        ),
      ListTile(
        contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
        leading: const Icon(Icons.today),
        title: const Text("Дата начала тест-драйва"),
        subtitle: Text(_dateStartTestDrive),
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
                    _dateStartTestDriveForSQL = DateFormat('yyyy.MM.dd').format(date);
                    _dateStartTestDrive = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                  }
                });
              });
            },
            color: Colors.blue
            ),
          ),
        !_isCategoryPhotocamera ? ListTile(
          contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
          leading: const Icon(Icons.today),
          title: const Text("Дата конца тест-драйва"),
          subtitle: Text(DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateFinishTestDriveForSQL.replaceAll('.', '-')))),
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
                      _dateFinishTestDriveForSQL = DateFormat('yyyy.MM.dd').format(date);
                      _dateFinishTestDrive = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                    }
                  });
                });
              },
              color: Colors.blue
          ),
        ) : const SizedBox.shrink(),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
          leading: const Icon(Icons.create),
          title: TextFormField(
            decoration: const InputDecoration(hintText: "Результат проверки-тестирования"),
            controller: _resultTestDrive,
          ),
        ),
        CheckboxListTile(
          contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
          title: const Text('Тест-драйв выполнен'),
          secondary: const Icon(Icons.check),
          value: _checkboxTestDrive,
          onChanged: (bool? value) {
            setState(() {
              _checkboxTestDrive = value!;
            });
          }
        )
      ],
      ),
    );
  }

  void save(Technic technic) async{
    int id = -1;
    id = await ConnectToDBMySQL.connDB.insertTechnicInDB(technic);
    technic.id = id;
    await TechnicSQFlite.db.insertEquipment(technic);
    await addHistory(technic);
  }

  Future addHistory(Technic technic) async{
    String descForHistory = descriptionForHistory(technic);
    History historyForSQL = History(
        History.historyList.last.id + 1,
        'Technic',
        technic.id!,
        'create',
        descForHistory,
        LoginPassword.login,
        DateFormat('yyyy.MM.dd').format(DateTime.now())
    );

    ConnectToDBMySQL.connDB.insertHistory(historyForSQL);
    HistorySQFlite.db.insertHistory(historyForSQL);
    History.historyList.insert(0, historyForSQL);
  }

  String descriptionForHistory(Technic technic){
    String internalID = technic.internalID == -1 ? 'БН' : '№${technic.internalID}';
    String result = 'Новая техника $internalID добавленна';

    return result;
  }

  String getDateFormat(String date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }

  void viewSnackBar(String text){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Icon(Icons.bolt, size: 40, color: Colors.white),
            Flexible(child: Text(text)),
          ],
        ),
        duration: const Duration(seconds: 5),
        showCloseIcon: true,
      ),
    );
  }

  String validateEmptyFields(){
    String result = '';
    String tmpResult = '';
    int countEmptyFields = 0;

    if(_innerNumberTechnic.text == ""){
      tmpResult += 'Номер техники, ';
      countEmptyFields++;
    }
    if(_selectedDropdownCategory == null){
      tmpResult += 'Наименование техники, ';
      countEmptyFields++;
    }
    if(_costTechnic.text == ""){
      tmpResult += 'Стоимость техники, ';
      countEmptyFields++;
    }
    if(_dateBuyTechnic == ""){
      tmpResult += 'Дата покупки техники, ';
      countEmptyFields++;
    }
    if(_selectedDropdownStatus == null){
      tmpResult += 'Статус техники, ';
      countEmptyFields++;
    }
    if(_selectedDropdownDislocation == null){
      tmpResult += 'Дислокация техники, ';
      countEmptyFields++;
    }
    if(_switchTestDrive &&
        _selectedDropdownTestDriveDislocation == null){
      tmpResult += 'Место тест-драйва, ';
      countEmptyFields++;
    }

    if(countEmptyFields > 0){
      tmpResult = tmpResult.trim().replaceFirst(',', '', tmpResult.length-5);
      result = getFieldAddition(countEmptyFields);
      result += '${tmpResult}.';
    }
    return result;
  }

  String getFieldAddition(int num) {
    double preLastDigit = num % 100 / 10;
    if (preLastDigit.round() == 1) {
      return "Не заполнено $num полей: ";
    }
    switch (num % 10) {
      case 1:
        return "Не заполнено $num поле: ";
      case 2:
      case 3:
      case 4:
        return "Не заполнены $num поля: ";
      default:
        return "Не заполнено $num полей: ";
    }
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
