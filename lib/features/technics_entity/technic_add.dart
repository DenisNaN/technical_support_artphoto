import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/data/connect_db_my_sql.dart';
import 'package:technical_support_artphoto/core/domain/models/providerModel.dart';
import 'package:technical_support_artphoto/core/utils/utils.dart';
import 'package:technical_support_artphoto/features/history/History.dart';
import 'technic_entity.dart';

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
  final _comment = TextEditingController();
  late final String _dateStartTestDrive;
  String _dateFinishTestDrive = '';
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
    print(DateFormat('d MMMM yyyy', 'ru_RU').format(DateTime.now()));
    _dateStartTestDrive = DateFormat('d MMMM yyyy', 'ru_RU').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    String nameUser = providerModel.user.keys.first;
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: MyColor().appBar(),
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
                      onPressed: () async{
                        // checking the unique number of the equipment
                        if (_formKey.currentState!.validate()) {
                          String validationEmptyFields = validateEmptyFields();
                          if (validationEmptyFields != '') {
                                _viewSnackBar(validationEmptyFields);
                          } else {
                            List tmpListTechnic = TechnicEntity.technicList;
                            tmpListTechnic.sort((technic1, technic2) => technic1.id.compareTo(technic2.id));
                            TechnicEntity technicLast = TechnicEntity.technicList.last;

                            TechnicEntity technic = TechnicEntity(
                                technicLast.id! + 1,
                                int.parse(_innerNumberTechnic.text),
                                _nameTechnic.text,
                                _selectedDropdownCategory!,
                                int.parse(_costTechnic.text.replaceAll(",", "")),
                                _dateBuyTechnic,
                                _selectedDropdownStatus!,
                                _selectedDropdownDislocation!,
                                DateFormat('yyyy.MM.dd').format(DateTime.now()),
                                _comment.text,
                                _selectedDropdownTestDriveDislocation ??= '',
                                _dateStartTestDrive,
                                _dateFinishTestDrive,
                                _resultTestDrive.text,
                                _checkboxTestDrive
                            );

                            String result = await save(technic, nameUser);
                            _viewSnackBar(' $result');
                            // TechnicEntity.technicList.sort();
                            Navigator.pop(context);
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
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(child: _buildInternalID()),
                    _buildButtonChenckNumberTechnic()
                  ],
                ),
                _buildNameCategory(providerModel),
                _buildNameTechnic(),
                _buildCostTechnic(),
                _buildDateBuyTechnic(),
                _buildStatus(providerModel),
                _buildDislocation(providerModel),
                _buildComment(),
                _buildSwitchTestDrive(),
                _buildTestDrive(providerModel)
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
      // leading: const Icon(Icons.fiber_new),
      title: TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
            labelText: 'Номер техники'),
        controller: _innerNumberTechnic,
        validator: (value) {
          List listInternalID = [];
          for (var element in TechnicEntity.technicList) {listInternalID.add(element.internalID.toString());}
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

  Padding _buildButtonChenckNumberTechnic(){
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 30),
      child: ElevatedButton(
          onPressed: () async{
            if(_innerNumberTechnic.text != ''){
              bool b = await ConnectDbMySQL.connDB.checkNumberTechnic(_innerNumberTechnic.text);
              _viewSnackBar(b ? 'Техника с таким номером есть.' : 'Номер свободен');
            }
          },
          child: Text('Проверить номер')),
    );
  }

  ListTile _buildNameCategory(ProviderModel providerModel) {
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
        items: providerModel.namesEquipments.map<DropdownMenuItem<String>>((String value) {
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
            }
            else {
              _isCategoryPhotocamera = false;
              if(_dateFinishTestDrive == '' && _dateStartTestDrive != ''){
                DateTime finishTestDrive = DateFormat('yyyy.MM.dd').parse(_dateStartTestDrive).add(const Duration(days: 14));
                _dateFinishTestDrive = DateFormat('yyyy.MM.dd').format(finishTestDrive);
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
                  _dateBuyTechnic = '';
                });
              },
              icon: const Icon(Icons.clear))
        ],
      ),
    );
  }

  ListTile _buildStatus(ProviderModel providerModel) {
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
        items: providerModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
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

  ListTile _buildDislocation(ProviderModel providerModel) {
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
        items: providerModel.namesPhotosalons.map<DropdownMenuItem<String>>((String value) {
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
                      _dateStartTestDrive = '';
                      _dateFinishTestDrive = '';
                      _resultTestDrive.text = '';
                      _checkboxTestDrive = false;
                    } else{
                      _dateStartTestDrive = DateFormat('yyyy.MM.dd').format(DateTime.now());
                    }
                    if(_switchTestDrive && !_checkboxTestDrive && _dateFinishTestDrive == '' && !_isCategoryPhotocamera){
                      DateTime finishTestDrive = DateFormat('yyyy.MM.dd').parse(_dateStartTestDrive).add(const Duration(days: 14));
                      _dateFinishTestDrive = DateFormat('yyyy.MM.dd').format(finishTestDrive);
                    }
                  });
                }
            ),
          ]
      ),
    );
  }

  ListTile _buildTestDrive(ProviderModel providerModel) {
   return ListTile(title:
  _switchTestDrive ? _buildTestDriveListTile(providerModel) : const Text('Тест-драйв не проводился')
  );
  }

  Padding _buildTestDriveListTile(ProviderModel providerModel){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                offset: Offset(2, 4), // Shadow position
              ),
            ]),
        child: ListTile(
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
                items: providerModel.namesPhotosalons.map<DropdownMenuItem<String>>((String value) {
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
              subtitle: Text(DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateFinishTestDrive.replaceAll('.', '-')))),
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
        ),
      ),
    );
  }

  Future save(TechnicEntity technic, String nameUser) async{
    int id = -1;
    id = await ConnectDbMySQL.connDB.insertTechnicInDB(technic, nameUser);
    technic.id = id;
    var result = await addHistory(technic, nameUser);
    return result;
  }

  Future addHistory(TechnicEntity technic, String nameUser) async{
    String descForHistory = descriptionForHistory(technic);
    History history = History(
        History.historyList.last.id + 1,
        'Technic',
        technic.id!,
        'create',
        descForHistory,
        nameUser,
        DateFormat('yyyy.MM.dd').format(DateTime.now())
    );

    ConnectDbMySQL.connDB.insertHistory(history);
    History.historyList.insert(0, history);
  }

  String descriptionForHistory(TechnicEntity technic){
    String internalID = technic.internalID == -1 ? 'БН' : '№${technic.internalID}';
    String result = 'Новая техника $internalID добавленна';

    return result;
  }

  String getDateFormat(String date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }

  void _viewSnackBar(String text) {
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
      result += '$tmpResult.';
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
