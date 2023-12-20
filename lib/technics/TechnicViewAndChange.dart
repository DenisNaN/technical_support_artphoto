import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import '../ConnectToDBMySQL.dart';
import '../utils/categoryDropDownValueModel.dart';
import 'Technic.dart';

class TechnicViewAndChange extends StatefulWidget {
  final Technic technic;
  const TechnicViewAndChange({super.key, required this.technic});

  @override
  State<TechnicViewAndChange> createState() => _TechnicViewAndChangeState();
}

class _TechnicViewAndChangeState extends State<TechnicViewAndChange> {
  late final _categoryTechnic;
  final _nameTechnic = TextEditingController();
  final _costTechnic = TextEditingController();
  late final _statusTechnic;
  late final _dislocationTechnic;
  late DateTime _dateBuy;
  String _dateBuyTechnic = '';
  String _dateBuyForSQL = '';
  final _comment = TextEditingController();
  String _dateStartTestDrive = '';
  String _dateStartTestDriveForSQL = '';
  String _dateFinishTestDrive = '';
  String _dateFinishTestDriveForSQL = '';
  final _resultTestDrive = TextEditingController();
  bool _checkboxTestDrive = false;
  bool _switchTestDrive = false;
  late bool _isCategoryPhotocamera;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isEditCategory = false;
  bool _isEditName = false;
  bool _isEditCost = false;
  bool _isEditDateBuy = false;
  bool _isEditComment = false;
  bool _isEditStatusDislocation = false;
  bool _isEditTestDrive = false;
  bool _isEditSwitch = false;

  @override
  void initState() {
    _nameTechnic.text = widget.technic.name;
    _costTechnic.text = '${widget.technic.cost}';
    _categoryTechnic = SingleValueDropDownController(data: DropDownValueModel(name: widget.technic.category, value: widget.technic.category));
    _statusTechnic = SingleValueDropDownController(data: DropDownValueModel(name: widget.technic.status, value: widget.technic.status));
    _dislocationTechnic = SingleValueDropDownController(data: DropDownValueModel(name: widget.technic.dislocation, value: widget.technic.dislocation));

    _dateBuy = DateTime.parse(widget.technic.dateBuyTechnic.replaceAll('.', '-'));
    _dateBuyTechnic = DateFormat('d MMMM yyyy', "ru_RU").format(_dateBuy);
    _dateBuyForSQL = DateFormat('yyyy.MM.dd').format(_dateBuy);
    _comment.text = widget.technic.comment;
    if(widget.technic.dateStartTestDrive != ''){
      _switchTestDrive = true;
      _dateStartTestDrive = widget.technic.dateStartTestDrive;
      _dateStartTestDriveForSQL = widget.technic.dateStartTestDrive;
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
    _categoryTechnic.dispose();
    _nameTechnic.dispose();
    _costTechnic.dispose();
    _statusTechnic.dispose();
    _dislocationTechnic.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormatter = FilteringTextInputFormatter.allow(
      RegExp(r'[0-9]'),
    );

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
                        if(_categoryTechnic.dropDownValue?.name == null ||
                            _nameTechnic.text == "" ||
                            _costTechnic.text == "" ||
                            _statusTechnic.dropDownValue?.name == null ||
                            _dislocationTechnic.dropDownValue?.name == null){
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
                              _categoryTechnic.dropDownValue!.name,
                              int.parse(_costTechnic.text.replaceAll(",", "")),
                              _dateBuyForSQL,
                              _statusTechnic.dropDownValue!.name,
                              _dislocationTechnic.dropDownValue!.name,
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
                title: Text(widget.technic.internalID == null ? 'БН' : '${widget.technic.internalID}'),
                subtitle: const Text('Номер техники'),
              ),

              _isEditCategory ?
              ListTile(
                leading: const Icon(Icons.print),
                title: DropDownTextField(
                  controller: _categoryTechnic,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Выберите категорию"),
                  dropDownItemCount: 8,
                  dropDownList: CategoryDropDownValueModel.nameEquipment,
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
              ),

              _isEditName ?
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
              ),

              _isEditCost ?
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
              ),

              ListTile(
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
              ),
              ListTile(
                leading: const Icon(Icons.copyright),
                title: DropDownTextField(
                  controller: _statusTechnic,
                  // initialValue: widget.technic.status,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Статус техники"),
                  dropDownItemCount: 4,
                  dropDownList: CategoryDropDownValueModel.statusForEquipment,
                  onChanged: (value){
                    setState(() {
                      if(_statusTechnic.dropDownValue!.name != widget.technic.status) _isEditStatusDislocation = true;
                    });
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.airport_shuttle),
                title: DropDownTextField(
                  controller: _dislocationTechnic,
                  // initialValue: widget.technic.dislocation,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Дислокация техники"),
                  dropDownItemCount: 4,
                  dropDownList: CategoryDropDownValueModel.photosalons,
                  onChanged: (value){
                    setState(() {
                      if(_dislocationTechnic.dropDownValue!.name != widget.technic.dislocation) _isEditStatusDislocation = true;
                    });
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.comment),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Комментарий (необязательно)"),
                  // controller: _comment,
                  initialValue: widget.technic.comment,
                  onChanged: (value){
                    setState(() {
                      if(_comment.text != widget.technic.comment) _isEditComment = true;
                    });
                  },
                ),
              ),
              ListTile(
                title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _switchTestDrive ? Text('Выключить тест-драйв ') : Text('Включить тест-драйв '),
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
              ),
              ListTile(title:
              _switchTestDrive ? !_isCategoryPhotocamera ? _buildTestDriveListTile() : _buildTestDriveListTilePhotocamera() : Text('Тест-драйв не проводился')
              )
            ],
          ),
        )
    );
  }

  ListTile _buildTestDriveListTile(){
    return ListTile(
      // leading: const Icon(Icons.create),
      title: Column(children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
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
        ListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
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
        ),
        ListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          leading: const Icon(Icons.create),
          title: TextFormField(
            decoration: const InputDecoration(hintText: "Результат проверки-тестирования"),
            // controller: _resultTestDrive,
            initialValue: widget.technic.resultTestDrive,
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

  ListTile _buildTestDriveListTilePhotocamera(){
    return ListTile(
      // leading: const Icon(Icons.create),
      title: Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
          leading: const Icon(Icons.today),
          title: const Text("Дата проверки"),
          subtitle: Text(DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateStartTestDrive.replaceAll('.', '-')))),
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
        ListTile(
          contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
          leading: const Icon(Icons.create),
          title: TextFormField(
            decoration: const InputDecoration(hintText: "Результат проверки-тестирования"),
            controller: _resultTestDrive,
            initialValue: widget.technic.resultTestDrive,
            onChanged: (value){
              if(value != widget.technic.resultTestDrive) _isEditTestDrive = true;
            },
          ),
        ),
        CheckboxListTile(
            contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
            title: const Text('Проверка выполнена'),
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
      ConnectToDBMySQL.connDB.insertStatusInDB(technic);
    }
    if(_isEditTestDrive || _isEditSwitch){
      ConnectToDBMySQL.connDB.insertTestDriveInDB(technic);
    }

    if(_isEditCategory || _isEditName || _isEditCost || _isEditDateBuy || _isEditComment || _isEditStatusDislocation || _isEditTestDrive || _isEditSwitch) {
      TechnicSQFlite.db.updateTechnic(technic);
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
