import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import '../ConnectToDBMySQL.dart';
import 'Technic.dart';

class TechnicViewAndChange extends StatefulWidget {
  final Technic technic;
  const TechnicViewAndChange({super.key, required this.technic});

  @override
  State<TechnicViewAndChange> createState() => _TechnicViewAndChangeState();
}

class _TechnicViewAndChangeState extends State<TechnicViewAndChange> {
  final _innerNumberTechnic = TextEditingController();
  final _categoryTechnic = SingleValueDropDownController();
  final _nameTechnic = TextEditingController();
  final _costTechnic = TextEditingController();
  final _statusTechnic = SingleValueDropDownController();
  final _dislocationTechnic = SingleValueDropDownController();
  String _dateBuyTechnic = "";
  String _dateForSQL = DateFormat('yyyy.MM.dd').format(DateTime.now());
  final _comment = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isEditNumber = false;
  bool isEditCategory = false;
  bool isEditName = false;
  bool isEditCost = false;
  bool isEditDateBuy = false;

  @override
  void initState() {
    _innerNumberTechnic.text = '${widget.technic.internalID}';
    _categoryTechnic.dropDownValue = DropDownValueModel(name: widget.technic.category, value: widget.technic.category);
    _nameTechnic.text = widget.technic.name;
    _costTechnic.text = '${widget.technic.cost}';
    _statusTechnic.dropDownValue = DropDownValueModel(name: widget.technic.status, value: widget.technic.status);
    _dislocationTechnic.dropDownValue = DropDownValueModel(name: widget.technic.dislocation, value: widget.technic.dislocation);
    _dateBuyTechnic = widget.technic.dateBuyTechnic;
    _comment.text = widget.technic.comment;
  }

  @override
  void dispose() {
    _innerNumberTechnic.dispose();
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
                        if(_innerNumberTechnic.text == "" ||
                            _categoryTechnic.dropDownValue?.name == null ||
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
                          Technic technicLast = Technic.technicList.first;
                          Technic technic = Technic(
                              technicLast.id! + 1,
                              int.parse(_innerNumberTechnic.text),
                              _nameTechnic.text,
                              _categoryTechnic.dropDownValue!.name,
                              int.parse(_costTechnic.text.replaceAll(",", "")),
                              _dateForSQL,
                              _statusTechnic.dropDownValue!.name,
                              _dislocationTechnic.dropDownValue!.name,
                              _comment.text);

                          SaveEntity()._save(technic);

                          Navigator.pop(context, technic);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.add_task, size: 40, color: Colors.white),
                                  Text(' Техника добавлена'),
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

              isEditNumber ?
              ListTile(
                leading: const Icon(Icons.fiber_new),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Номер техники"),
                  controller: _innerNumberTechnic,
                  inputFormatters: [numberFormatter],
                  keyboardType: TextInputType.number,
                ),
              ) :
              ListTile(
                leading: const Icon(Icons.fiber_new),
                title: Text(widget.technic.internalID == null ? 'БН' : '${widget.technic.internalID}'),
                subtitle: const Text('Номер техники'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: (){
                    setState(() {
                      isEditNumber = !isEditNumber;
                    });
                  },
                ),
              ),

              isEditCategory ?
              ListTile(
                leading: const Icon(Icons.print),
                title: DropDownTextField(
                  // controller: _categoryTechnic,
                  initialValue: widget.technic.category,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Выберите категорию"),
                  dropDownItemCount: 8,
                  dropDownList: const [
                    DropDownValueModel(name: 'Принтер', value: "Принтер"),
                    DropDownValueModel(name: 'Копир', value: "Копир"),
                    DropDownValueModel(name: 'Большой Копир', value: "Большой Копир"),
                    DropDownValueModel(name: 'Фотоаппарат', value: "Фотоаппарат"),
                    DropDownValueModel(name: 'Сканер', value: "Сканер"),
                    DropDownValueModel(name: 'Вспышка', value: "Вспышка"),
                    DropDownValueModel(name: 'Ламинатор', value: "Ламинатор"),
                    DropDownValueModel(name: 'Телевизор', value: "Телевизор"),
                  ],
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
                      isEditCategory = !isEditCategory;
                    });
                  },
                ),
              ),

              isEditName ?
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
                subtitle: const Text('Наименование'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: (){
                    setState(() {
                      isEditName = !isEditName;
                    });
                  },
                ),
              ),

              isEditCost ?
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
                      isEditCost = !isEditCost;
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
                  initialValue: widget.technic.status,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Статус техники"),
                  dropDownItemCount: 4,
                  dropDownList: const [
                    DropDownValueModel(name: 'Активна', value: "Активна"),
                    DropDownValueModel(name: 'Неисправна', value: "Неисправна"),
                    DropDownValueModel(name: 'В ремонте', value: "В ремонте"),
                    DropDownValueModel(name: 'Тест-драйв', value: "Тест-драйв"),
                    DropDownValueModel(name: 'На хранении', value: "На хранении"),
                    DropDownValueModel(name: 'Донор', value: "Донор"),
                    DropDownValueModel(name: 'Списана', value: "Списана"),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.airport_shuttle),
                title: DropDownTextField(
                  initialValue: widget.technic.dislocation,
                  clearOption: true,
                  textFieldDecoration: const InputDecoration(hintText: "Дислокация техники"),
                  dropDownItemCount: 4,
                  dropDownList: const [
                    DropDownValueModel(name: 'Кузьминки', value: "Кузьминки"),
                    DropDownValueModel(name: 'Текстильщики', value: "Текстильщики"),
                    DropDownValueModel(name: 'Жулебино', value: "Жулебино"),
                    DropDownValueModel(name: 'Рязанка', value: "Рязанка"),
                    DropDownValueModel(name: 'Ключевая', value: "Ключевая"),
                    DropDownValueModel(name: 'Паромная', value: "Паромная"),
                    DropDownValueModel(name: 'Склад', value: "Склад"),
                    DropDownValueModel(name: 'Офис', value: "Офис"),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.comment),
                title: TextFormField(
                  decoration: const InputDecoration(hintText: "Комментарий (необязательно)"),
                  controller: _comment,
                ),
              ),
            ],
          ),
        )
    );
  }
}

class SaveEntity{
  void _save(Technic technic){
    // ConnectToDBMySQL.connDB.insertTechnicInDB(technic);
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
