import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import '../ConnectToDBMySQL.dart';
import '../utils/categoryDropDownValueModel.dart';
import 'Technic.dart';

class TechnicAdd extends StatefulWidget {
  const TechnicAdd({super.key});

  @override
  State<TechnicAdd> createState() => _TechnicAddState();
}

class _TechnicAddState extends State<TechnicAdd> {
  final _innerNumberTechnic = TextEditingController();
  final _categoryTechnic = SingleValueDropDownController();
  final _nameTechnic = TextEditingController();
  final _costTechnic = TextEditingController();
  final _statusTechnic = SingleValueDropDownController();
  final _dislocationTechnic = SingleValueDropDownController();
  String _dateBuyTechnic = "";
  String _dateForSQL = DateFormat('yyyy.MM.dd').format(DateTime.now());
  final _comment = TextEditingController();
  String _dateStartTestDrive = DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.now());
  String _dateStartTestDriveForSQL = DateFormat('yyyy.MM.dd').format(DateTime.now());
  String _dateFinishTestDrive = "Нет даты";
  String _dateFinishTestDriveForSQL = "";
  final _resultTestDrive = TextEditingController();
  bool _switchTestDrive = false;
  bool _checkboxTestDrive = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _innerNumberTechnic.dispose();
    _categoryTechnic.dispose();
    _nameTechnic.dispose();
    _costTechnic.dispose();
    _statusTechnic.dispose();
    _dislocationTechnic.dispose();
    _comment.dispose();
    _resultTestDrive.dispose();
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
                      onPressed: () {
                        // checking the unique number of the equipment
                        if (_formKey.currentState!.validate()) {
                          if (_innerNumberTechnic.text == "" ||
                              _categoryTechnic.dropDownValue?.name ==
                                  null ||
                              _nameTechnic.text == "" ||
                              _costTechnic.text == "" ||
                              _statusTechnic.dropDownValue?.name ==
                                  null ||
                              _dislocationTechnic.dropDownValue
                                  ?.name == null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.bolt, size: 40,
                                        color: Colors.white),
                                    Text(
                                        'Остались не заполненые поля'),
                                  ],
                                ),
                                duration: Duration(seconds: 5),
                                showCloseIcon: true,
                              ),
                            );
                          } else {
                            Technic technicLast = Technic.technicList
                                .first;
                            Technic technic = Technic(
                                technicLast.id! + 1,
                                int.parse(_innerNumberTechnic.text),
                                _nameTechnic.text,
                                _categoryTechnic.dropDownValue!.name,
                                int.parse(_costTechnic.text
                                    .replaceAll(",", "")),
                                _dateForSQL,
                                _statusTechnic.dropDownValue!.name,
                                _dislocationTechnic.dropDownValue!
                                    .name,
                                _comment.text);

                            SaveEntity()._save(technic);

                            Navigator.pop(context, technic);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.add_task, size: 40,
                                        color: Colors.white),
                                    Text(' Техника добавлена'),
                                  ],
                                ),
                                duration: Duration(seconds: 5),
                                showCloseIcon: true,
                              ),
                            );
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
          child: ListView(
            children: [
              ListTile(
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
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: DropDownTextField(
                  controller: _categoryTechnic,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Наименование техники"),
                  dropDownItemCount: 8,
                  dropDownList: CategoryDropDownValueModel.nameEquipment,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.create),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Модель техники"),
                  controller: _nameTechnic,
                ),
              ),
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
              ),
              ListTile(
                leading: const Icon(Icons.today),
                title: const Text("Дата покупки техники"),
                subtitle: Text(_dateBuyTechnic == "" ? DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.now()) : _dateBuyTechnic),
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
                            _dateForSQL = DateFormat('yyyy.MM.dd').format(date);
                            _dateBuyTechnic = DateFormat('d MMMM yyyy', "ru_RU").format(date);
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
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Статус техники"),
                  dropDownItemCount: 4,
                  dropDownList: CategoryDropDownValueModel.statusForEquipment,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.airport_shuttle),
                title: DropDownTextField(
                  controller: _dislocationTechnic,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Дислокация техники"),
                  dropDownItemCount: 4,
                  dropDownList: CategoryDropDownValueModel.photosalons,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.comment),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Комментарий (необязательно)"),
                  controller: _comment,
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
                            });
                          }
                      ),
                    ]
                ),
              ),
              ListTile(title:
              _switchTestDrive ? _buildTestDriveListTile() : Text('Тест-драйв не проводился')
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
        ListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          leading: const Icon(Icons.today),
          title: const Text("Дата конца тест-драйва"),
          subtitle: Text(_dateFinishTestDrive == "Нет даты" ? "Выберите дату" : _dateFinishTestDrive),
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
        ),
        ListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          leading: const Icon(Icons.create),
          title: TextFormField(
            decoration: const InputDecoration(hintText: "Результат проверки-тестирования"),
            controller: _resultTestDrive,
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: Text('Тест-драйв выполнен'),
          secondary: Icon(Icons.check),
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
}

class SaveEntity{
  void _save(Technic technic) async{
    await ConnectToDBMySQL.connDB.connDatabase();
    ConnectToDBMySQL.connDB.insertTechnicInDB(technic);
    TechnicSQFlite.db.create(technic);
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
