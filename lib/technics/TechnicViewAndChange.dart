import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import '../ConnectToDBMySQL.dart';
import '../history/History.dart';
import '../history/HistorySQFlite.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/utils.dart';
import 'Technic.dart';

class TechnicViewAndChange extends StatefulWidget {
  final Technic technic;
  const TechnicViewAndChange({super.key, required this.technic});

  @override
  State<TechnicViewAndChange> createState() => _TechnicViewAndChangeState();
}

class _TechnicViewAndChangeState extends State<TechnicViewAndChange> {
  final _nameTechnic = TextEditingController();
  final _costTechnic = TextEditingController();
  late DateTime _dateBuy;
  String _dateBuyTechnic = '';
  String _dateBuyForSQL = '';
  final _comment = TextEditingController();
  String _dateStartTestDrive = '';
  String _dateStartTestDriveForSQL = '';
  String _dateFinishTestDrive = '';
  String _dateFinishTestDriveForSQL = '';
  final _resultTestDrive = TextEditingController();
  String? _selectedDropdownNameTechnic;
  String? _selectedDropdownDislocation;
  String? _selectedDropdownStatus;
  bool _checkboxTestDrive = false;
  bool _switchTestDrive = false;
  late bool _isCategoryPhotocamera;
  late Technic _oldTechnicForHistory;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isEditCategory = false;
  bool _isEditName = false;
  bool _isEditCost = false;
  bool _isEditDateBuy = false;
  bool _isEditComment = false;
  bool _isEditStatusDislocation = false;
  bool _isEditTestDrive = false;
  bool _isEditSwitch = false;

  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _oldTechnicForHistory = Technic(
        widget.technic.id,
        widget.technic.internalID,
        widget.technic.name,
        widget.technic.category,
        widget.technic.cost,
        widget.technic.dateBuyTechnic,
        widget.technic.status,
        widget.technic.dislocation,
        widget.technic.comment,
        widget.technic.dateStartTestDrive,
        widget.technic.dateFinishTestDrive,
        widget.technic.resultTestDrive,
        widget.technic.checkboxTestDrive);

    _nameTechnic.text = widget.technic.name;
    _costTechnic.text = '${widget.technic.cost}';
    _selectedDropdownNameTechnic = widget.technic.category == '' ? null : widget.technic.category;
    _selectedDropdownStatus = widget.technic.status == '' ? null : widget.technic.status;
    _selectedDropdownDislocation = widget.technic.dislocation == '' ? null : widget.technic.dislocation;

    _dateBuy = DateTime.parse(widget.technic.dateBuyTechnic.replaceAll('.', '-'));
    _dateBuyTechnic = DateFormat('d MMMM yyyy', "ru_RU").format(_dateBuy);
    _dateBuyForSQL = DateFormat('yyyy.MM.dd').format(_dateBuy);
    _comment.text = widget.technic.comment;
    if(widget.technic.dateStartTestDrive != ''){
      _switchTestDrive = true;
      _dateStartTestDrive = widget.technic.dateStartTestDrive;
      _dateStartTestDriveForSQL = widget.technic.dateStartTestDrive;
      _resultTestDrive.text = widget.technic.resultTestDrive;
      _checkboxTestDrive = widget.technic.checkboxTestDrive;
    }
    if(widget.technic.dateFinishTestDrive != ''){
      _dateFinishTestDrive = widget.technic.dateFinishTestDrive;
      _dateFinishTestDriveForSQL = widget.technic.dateFinishTestDrive;
    } else{
      _dateFinishTestDrive = '';
      _dateFinishTestDriveForSQL = '';
    }
    widget.technic.category == 'Фотоаппарат' ? _isCategoryPhotocamera = true : _isCategoryPhotocamera = false;
  }

  @override
  void dispose() {
    _nameTechnic.dispose();
    _costTechnic.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isEdit = validateButtonSaveView();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Внесение изменений в технику'),
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
                      onPressed: HasNetwork.isConnecting && _isEdit ? () {
                        if(_selectedDropdownNameTechnic == null ||
                            _nameTechnic.text == "" ||
                            _costTechnic.text == "" ||
                            _selectedDropdownStatus == null ||
                            _selectedDropdownDislocation == null){
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
                          Technic technic = Technic(
                              widget.technic.id,
                              widget.technic.internalID,
                              _nameTechnic.text,
                              _selectedDropdownNameTechnic!,
                              int.parse(_costTechnic.text.replaceAll(",", "")),
                              _dateBuyForSQL,
                              _selectedDropdownStatus!,
                              _selectedDropdownDislocation!,
                              _comment.text,
                              _dateStartTestDriveForSQL,
                              _dateFinishTestDriveForSQL,
                              _resultTestDrive.text,
                              _checkboxTestDrive
                          );

                          _save(technic);
                          Navigator.pop(context, technic);

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
                      child: HasNetwork.isConnecting && _isEdit ?
                        Container(padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(7)),
                          child: const Text("Сохранить", style: TextStyle(color: Colors.white))) :
                        const SizedBox(),
                      )
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
                _buildCategory(),
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

   ListTile _buildInternalID() {
    return  ListTile(
      leading: const Icon(Icons.fiber_new),
      title: Text(widget.technic.internalID == null ? 'БН' : '${widget.technic.internalID}'),
      subtitle: const Text('Номер техники'),
    );
  }

  ListTile _buildCategory() {
    return _isEditCategory ?
    ListTile(
      leading: const Icon(Icons.print),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        isExpanded: true,
        hint: const Text('Выберите категорию'),
        icon: _selectedDropdownNameTechnic != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _selectedDropdownNameTechnic = null;
              });}) : null,
        value: _selectedDropdownNameTechnic,
        items: CategoryDropDownValueModel.nameEquipment.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _selectedDropdownNameTechnic = value!;
            _isEditCategory = true;
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
    ) :
    ListTile(
      leading: const Icon(Icons.print),
      title: Text(widget.technic.category),
      subtitle: const Text('Категория'),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: (){
          setState(() {
            _isEditCategory = true;
          });
        },
      ),
    );
  }

  ListTile _buildNameTechnic() {
   return _isEditName ?
    ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Наименование техники"),
        controller: _nameTechnic,
      ),
    ) :
    ListTile(
      leading: const Icon(Icons.create),
      title: Text(widget.technic.name),
      subtitle: const Text('Наименование техники'),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: (){
          setState(() {
            _isEditName = true;
          });
        },
      ),
    );
  }

  ListTile _buildCostTechnic() {
   return _isEditCost ?
    ListTile(
        leading: const Icon(Icons.shopify),
        title: TextFormField(
          decoration: const InputDecoration(
              hintText: "Стоимость техники",
              prefix: Text('₽ ')),
          controller: _costTechnic,
          inputFormatters: [IntegerCurrencyInputFormatter()],
          keyboardType: TextInputType.number,
        )
    ) :
    ListTile(
      leading: const Icon(Icons.shopify),
      title: Text('${widget.technic.cost} руб.'),
      subtitle: const Text('Стоимость'),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: (){
          setState(() {
            _isEditCost = true;
          });
        },
      ),
    );
  }

  ListTile _buildDateBuyTechnic() {
    return ListTile(
      leading: const Icon(Icons.today),
      title: Text(_dateBuyTechnic == "" ? DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.now()) : _dateBuyTechnic),
      subtitle: const Text("Дата покупки техники"),
      trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            showDatePicker(
                context: context,
                initialDate: _dateBuy,
                firstDate: DateTime(2000),
                lastDate: DateTime(2099),
                locale: const Locale("ru", "RU")
            ).then((date) {
              setState(() {
                if(date != null) {
                  _dateBuyForSQL = DateFormat('yyyy.MM.dd').format(date);
                  _dateBuyTechnic = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                  _isEditDateBuy = true;
                }
              });
            });
          },
          color: Colors.blue
      ),
    );
  }

  ListTile _buildStatus() {
    return ListTile(
      leading: const Icon(Icons.copyright),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
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
            _isEditStatusDislocation = true;
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
            _isEditStatusDislocation = true;
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
        onChanged: (value){
          setState(() {
            if(_comment.text != widget.technic.comment) _isEditComment = true;
          });
        },
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
                    _isEditSwitch = true;
                    if(!_switchTestDrive){
                      _dateStartTestDriveForSQL = '';
                      _dateFinishTestDriveForSQL = '';
                      _resultTestDrive.text = '';
                      _checkboxTestDrive = false;
                    }else{
                      _dateStartTestDrive = DateFormat('yyyy.MM.dd').format(DateTime.now());
                      _dateStartTestDriveForSQL = DateFormat('yyyy.MM.dd').format(DateTime.now());
                    }
                    if(_switchTestDrive && !_checkboxTestDrive && _dateFinishTestDriveForSQL == '' && !_isCategoryPhotocamera){
                      DateTime finishTestDrive = DateFormat('yyyy.MM.dd').parse(_dateStartTestDrive).add(const Duration(days: 14));
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
          leading: const Icon(Icons.today),
          title: const Text("Дата начала тест-драйва"),
          subtitle: Text(DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateStartTestDriveForSQL.replaceAll('.', '-')))),
          trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDatePicker(
                    context: context,
                    initialDate: DateTime.parse(widget.technic.dateStartTestDrive.replaceAll('.', '-')),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2099),
                    locale: const Locale("ru", "RU")
                ).then((date) {
                  setState(() {
                    if(date != null) {
                      _dateStartTestDriveForSQL = DateFormat('yyyy.MM.dd').format(date);
                      _dateStartTestDrive = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                      if(_dateStartTestDriveForSQL != widget.technic.dateStartTestDrive) _isEditTestDrive = true;
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
                    initialDate: DateTime.parse(widget.technic.dateFinishTestDrive.replaceAll('.', '-')),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2099),
                    locale: const Locale("ru", "RU")
                ).then((date) {
                  setState(() {
                    if(date != null) {
                      _dateFinishTestDriveForSQL = DateFormat('yyyy.MM.dd').format(date);
                      _dateFinishTestDrive = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                      if(_dateFinishTestDriveForSQL != widget.technic.dateFinishTestDrive) _isEditTestDrive = true;
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
            onChanged: (value){
              if(value != widget.technic.resultTestDrive) _isEditTestDrive = true;
            },
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
                _isEditTestDrive = true;
              });
            }
        )
      ],
      ),
    );
  }

  void _save (Technic technic) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    if(_isEditCategory || _isEditName || _isEditCost || _isEditDateBuy || _isEditComment) {
      ConnectToDBMySQL.connDB.updateTechnicInDB(technic);
    }
    if(_isEditStatusDislocation){
      ConnectToDBMySQL.connDB.insertStatusInDB(technic.id!, technic.status, technic.dislocation);
    }
    if(_isEditTestDrive || _isEditSwitch){
      ConnectToDBMySQL.connDB.insertTestDriveInDB(technic);
    }

    if(_isEditCategory || _isEditName || _isEditCost || _isEditDateBuy || _isEditComment || _isEditStatusDislocation || _isEditTestDrive || _isEditSwitch) {
      TechnicSQFlite.db.updateTechnic(technic);
    }
    addHistory(technic);
  }

  bool validateButtonSaveView(){
    bool result = false;
    if(_isEditCategory || _isEditName || _isEditCost || _isEditDateBuy ||
        _isEditComment || _isEditStatusDislocation || _isEditTestDrive ||
        _isEditSwitch){
      result = true;
    }
    return result;
  }

  Future addHistory(Technic technic) async{
    String descForHistory = descriptionForHistory(_oldTechnicForHistory, technic);
    History historyForSQL = History(
        History.historyList.last.id + 1,
        'Technic',
        technic.id!,
        'edit',
        descForHistory,
        LoginPassword.login,
        DateFormat('yyyy.MM.dd').format(DateTime.now())
    );

    ConnectToDBMySQL.connDB.insertHistory(historyForSQL);
    HistorySQFlite.db.insertHistory(historyForSQL);
    History.historyList.insert(0, historyForSQL);
  }

  String descriptionForHistory(Technic technicOld, Technic technicNew){
    String internalID = technicOld.internalID == -1 ? 'БН' : '№${technicOld.internalID}';
    String result = 'Техника $internalID изменена:';

    if(technicOld.category != technicNew.category){
      result = '$result\n Категория изменена:\n'
          '  Было: ${technicOld.category}\n'
          '  Стало: ${technicNew.category}';
    }
    if(technicOld.name != technicNew.name){
      result = '$result\n Наименование техники изменено:\n'
          '  Было: ${technicOld.name}\n'
          '  Стало: ${technicNew.name}';
    }
    if(technicOld.cost != technicNew.cost){
      result = '$result\n Стоимость техники изменена:\n'
          '  Было: ${technicOld.cost}\n'
          '  Стало: ${technicNew.cost}';
    }
    if(technicOld.dateBuyTechnic != technicNew.dateBuyTechnic){
      result = '$result\n Дата покупки изменена:\n'
          '  Было: ${getDateFormat(technicOld.dateBuyTechnic)}\n'
          '  Стало: ${getDateFormat(technicNew.dateBuyTechnic)}';
    }
    if(technicOld.status != technicNew.status){
        result = '$result\n Статус изменён:\n'
          '  Было: ${technicOld.status}\n'
          '  Стало: ${technicNew.status}';
    }
    if(technicOld.dislocation != technicNew.dislocation){
        result = '$result\n Местонахождение изменено:\n'
          '  Было: ${technicOld.dislocation}\n'
          '  Стало: ${technicNew.dislocation}';
    }
    if(technicOld.comment != technicNew.comment){
      if(technicOld.comment == ''){
        result = '$result\n Комментарий внесён: '
            '${technicNew.comment}';
      }else {
        result = '$result\n Комментарий изменён:\n'
            '  Было: ${technicOld.comment}\n'
            '  Стало: ${technicNew.comment}';
      }
    }
    if(technicOld.dateStartTestDrive != technicNew.dateStartTestDrive){
      if(technicOld.dateStartTestDrive == ''){
        result = '$result\n Внесена дата начала тест-драйва: '
            '${getDateFormat(technicNew.dateStartTestDrive)}';
      }else {
        result = '$result\n Дата начала тест-драйва изменена:\n'
            '  Было: ${getDateFormat(technicOld.dateStartTestDrive)}\n'
            '  Стало: ${getDateFormat(technicNew.dateStartTestDrive)}';
      }
    }
    if(technicOld.dateFinishTestDrive != technicNew.dateFinishTestDrive){
      if(technicOld.dateFinishTestDrive == ''){
        result = '$result\n Внесена дата конца тест-драйва: '
            '${getDateFormat(technicNew.dateFinishTestDrive)}';
      }else {
        result = '$result\n Дата конца тест-драйва изменена:\n'
            '  Было: ${getDateFormat(technicOld.dateFinishTestDrive)}\n'
            '  Стало: ${getDateFormat(technicNew.dateFinishTestDrive)}';
      }
    }
    if(technicOld.resultTestDrive != technicNew.resultTestDrive){
      if(technicOld.resultTestDrive == ''){
        result = '$result\n Внесён результат тест-драйва: '
            '${technicNew.resultTestDrive}';
      }else {
        result = '$result\n Результат тест-драйва изменён:\n'
            '  Было: ${technicOld.resultTestDrive}\n'
            '  Стало: ${technicNew.resultTestDrive}';
      }
    }
    if(technicOld.checkboxTestDrive != technicNew.checkboxTestDrive){
      if(technicOld.checkboxTestDrive == true){
        result = '$result\n Тест-драйв завершён';
      }else {
        result = '$result\n Тест-драйв отменён:\n';
      }
    }
    return result;
  }

  String getDateFormat(String date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
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
