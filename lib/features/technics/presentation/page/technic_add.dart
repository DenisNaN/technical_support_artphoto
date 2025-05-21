import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/datasources/connect_db_my_sql.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/shared/input_decoration/input_deroration.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/features/history/history.dart';

class TechnicAdd extends StatefulWidget {
  const TechnicAdd({super.key});

  @override
  State<TechnicAdd> createState() => _TechnicAddState();
}

class _TechnicAddState extends State<TechnicAdd> {
  final _innerNumberTechnic = TextEditingController();
  final _nameTechnic = TextEditingController();
  final _costTechnic = TextEditingController();
  DateTime? _dateBuyTechnic;
  final _comment = TextEditingController();

  // late final String _dateStartTestDrive;
  // String _dateFinishTestDrive = '';
  final _resultTestDrive = TextEditingController();
  String? _selectedDropdownCategory;
  String? _selectedDropdownDislocation;
  String? _selectedDropdownStatus;
  bool isBN = false;
  bool isExistNumber = false;

  // String? _selectedDropdownTestDriveDislocation;
  // bool _switchTestDrive = false;
  // bool _checkboxTestDrive = false;
  // bool _isCategoryPhotocamera = false;

  final GlobalKey<FormState> _formInnerNumberKey = GlobalKey<FormState>();

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
    _dateBuyTechnic = DateTime.now();
    // _dateStartTestDrive = DateFormat('d MMMM yyyy', 'ru_RU').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Scaffold(
        appBar: CustomAppBar(typePage: TypePage.add, location: null, technic: null),
        body: Form(
            key: _formInnerNumberKey,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // SizedBox(height: 20),
                _buildInternalID(),
                SizedBox(height: 20),
                _buildCategoryTechnic(providerModel),
                SizedBox(height: 20),
                _buildCostTechnic(),
                SizedBox(height: 20),
                _buildNameTechnic(),
                SizedBox(height: 20),
                _buildDateBuyTechnic(),
                SizedBox(height: 20),
                _buildStatus(providerModel),
                SizedBox(height: 20),
                _buildDislocation(providerModel),
                SizedBox(height: 20),
                _buildComment(),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey)),
                      child: Text("Отмена"),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_formInnerNumberKey.currentState!.validate()) {
                            Technic technic = Technic(
                                0,
                                !isBN ? int.parse(_innerNumberTechnic.text) : 0,
                                _selectedDropdownCategory!,
                                _nameTechnic.text,
                                _selectedDropdownStatus!,
                                _selectedDropdownDislocation!,
                                _dateBuyTechnic ?? DateTime.now(),
                                int.parse(_costTechnic.text.replaceAll(",", "")),
                                _comment.text);

                            _save(technic, providerModel).then((_) {
                              _viewSnackBar(Icons.save, true, 'Техника сохранена');
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Сохранить")),
                  ],
                ),
                SizedBox(
                  height: 20,
                )
              ],
            )));
  }

  final numberFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9]'),
  );

  Column _buildInternalID() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              Text(isBN ? 'Включить номер' : 'Выключить номер'),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                    value: isBN,
                    onChanged: (value) {
                      setState(() {
                        isBN = value;
                        if (value == true) _innerNumberTechnic.text = '';
                      });
                    }),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: TextFormField(
                  enabled: !isBN,
                  decoration: myDecorationTextFormField(!isBN ? 'Номер техники' : 'Без номера'),
                  controller: _innerNumberTechnic,
                  onChanged: (text) async{
                    if(text.isNotEmpty){
                      final check = await TechnicalSupportRepoImpl.downloadData.checkNumberTechnic(text);
                      setState(() => isExistNumber = check);
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty && !isBN) {
                      return 'Обязательное поле';
                    }
                    if (isExistNumber) {
                      return 'Номер занят';
                    }
                    return null;
                  },
                  inputFormatters: [numberFormatter],
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            _buildButtonChenckNumberTechnic(),
          ],
        ),
      ],
    );
  }

  Padding _buildButtonChenckNumberTechnic() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 30),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: !isBN ? Colors.blue : Colors.grey,
          ),
          onPressed: () async {
            if (_innerNumberTechnic.text != '' && !isBN) {
              TechnicalSupportRepoImpl.downloadData.checkNumberTechnic(_innerNumberTechnic.text).then((result) {
                _viewSnackBarCheckEmptyNumberTechnic(result ? 'Техника с таким номером есть.' : 'Номер свободен');
              });
            }
          },
          child: Text('Проверить номер')),
    );
  }

  Column _buildCategoryTechnic(ProviderModel providerModel) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Категория техники',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: DropdownButtonFormField<String>(
              decoration: myDecorationDropdown(),
              validator: (value) => value == null ? "Обязательное поле" : null,
              dropdownColor: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10.0),
              hint: const Text('Техника'),
              value: _selectedDropdownCategory,
              items: providerModel.namesEquipments.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedDropdownCategory = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Column _buildCostTechnic() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Стоимость техники',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
              title: TextFormField(
            decoration: myDecorationTextFormField(null, 'Цена', '₽ '),
            controller: _costTechnic,
            inputFormatters: [IntegerCurrencyInputFormatter()],
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Обязательное поле';
              }
              return null;
            },
          )),
        ),
      ],
    );
  }

  Column _buildNameTechnic() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Модель техники',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: TextFormField(
              decoration: myDecorationTextFormField(null, 'Модель'),
              controller: _nameTechnic,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Обязательное поле';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Column _buildDateBuyTechnic() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Дата покупки техники',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 55, right: 55, top: 6),
          child: ListTile(
            title: Text(
              DateFormat('d MMMM yyyy', 'ru_RU').format(_dateBuyTechnic ?? DateTime.now()),
              style: TextStyle(color: Colors.black54),
            ),
            tileColor: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onTap: () {
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099),
                      locale: const Locale("ru", "RU"))
                  .then((date) {
                setState(() {
                  if (date != null) {
                    _dateBuyTechnic = date;
                  }
                });
              });
            },
          ),
        ),
      ],
    );
  }

  Column _buildStatus(ProviderModel providerModel) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Статус техники',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: DropdownButtonFormField<String>(
              decoration: myDecorationDropdown(),
              borderRadius: BorderRadius.circular(10.0),
              hint: const Text('Статус техники'),
              validator: (value) => value == null ? "Обязательное поле" : null,
              dropdownColor: Colors.blue.shade50,
              value: _selectedDropdownStatus,
              items: providerModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedDropdownStatus = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Column _buildDislocation(ProviderModel providerModel) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Дислокация техники',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: DropdownButtonFormField<String>(
              decoration: myDecorationDropdown(),
              borderRadius: BorderRadius.circular(10.0),
              hint: const Text('Дислокация'),
              value: _selectedDropdownDislocation,
              validator: (value) => value == null ? "Обязательное поле" : null,
              items: providerModel.namesPhotosalons.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedDropdownDislocation = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Column _buildComment() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Комментарий',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Комментарий (необязательно)"),
              controller: _comment,
            ),
          ),
        ),
      ],
    );
  }

  // ListTile _buildSwitchTestDrive() {
  //   return ListTile(
  //     title: Row(mainAxisSize: MainAxisSize.min, children: [
  //       _switchTestDrive
  //           ? const Text('Выключить тест-драйв ')
  //           : const Text('Включить тест-драйв '),
  //       Switch(
  //           value: _switchTestDrive,
  //           onChanged: (value) {
  //             setState(() {
  //               _switchTestDrive = value;
  //               if (!_switchTestDrive) {
  //                 _dateStartTestDrive = '';
  //                 _dateFinishTestDrive = '';
  //                 _resultTestDrive.text = '';
  //                 _checkboxTestDrive = false;
  //               } else {
  //                 _dateStartTestDrive = DateFormat('yyyy.MM.dd').format(DateTime.now());
  //               }
  //               if (_switchTestDrive &&
  //                   !_checkboxTestDrive &&
  //                   _dateFinishTestDrive == '' &&
  //                   !_isCategoryPhotocamera) {
  //                 DateTime finishTestDrive = DateFormat('yyyy.MM.dd')
  //                     .parse(_dateStartTestDrive)
  //                     .add(const Duration(days: 14));
  //                 _dateFinishTestDrive = DateFormat('yyyy.MM.dd').format(finishTestDrive);
  //               }
  //             });
  //           }),
  //     ]),
  //   );
  // }
  //
  // ListTile _buildTestDrive(ProviderModel providerModel) {
  //   return ListTile(
  //       title: _switchTestDrive
  //           ? _buildTestDriveListTile(providerModel)
  //           : const Text('Тест-драйв не проводился'));
  // }
  //
  // Padding _buildTestDriveListTile(ProviderModel providerModel) {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  //     child: Container(
  //       decoration: BoxDecoration(
  //           color: Colors.blue.shade50,
  //           borderRadius: BorderRadius.circular(20),
  //           boxShadow: const [
  //             BoxShadow(
  //               color: Colors.grey,
  //               blurRadius: 4,
  //               offset: Offset(2, 4), // Shadow position
  //             ),
  //           ]),
  //       child: ListTile(
  //         title: Column(
  //           children: [
  //             ListTile(
  //               contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
  //               leading: const Icon(Icons.airport_shuttle),
  //               title: DropdownButton<String>(
  //                 isExpanded: true,
  //                 hint: const Text('Место тест-драйва'),
  //                 icon: _selectedDropdownTestDriveDislocation != null
  //                     ? IconButton(
  //                         icon: const Icon(Icons.clear, color: Colors.grey),
  //                         onPressed: () {
  //                           setState(() {
  //                             _selectedDropdownTestDriveDislocation = null;
  //                           });
  //                         })
  //                     : null,
  //                 value: _selectedDropdownTestDriveDislocation,
  //                 items: providerModel.namesPhotosalons
  //                     .map<DropdownMenuItem<String>>((String value) {
  //                   return DropdownMenuItem<String>(
  //                     value: value,
  //                     child: Text(value),
  //                   );
  //                 }).toList(),
  //                 onChanged: (String? value) {
  //                   setState(() {
  //                     _selectedDropdownTestDriveDislocation = value!;
  //                   });
  //                 },
  //               ),
  //             ),
  //             ListTile(
  //               contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
  //               leading: const Icon(Icons.today),
  //               title: const Text("Дата начала тест-драйва"),
  //               subtitle: Text(_dateStartTestDrive),
  //               trailing: IconButton(
  //                   icon: const Icon(Icons.edit),
  //                   onPressed: () {
  //                     showDatePicker(
  //                             context: context,
  //                             initialDate: DateTime.now(),
  //                             firstDate: DateTime(2000),
  //                             lastDate: DateTime(2099),
  //                             locale: const Locale("ru", "RU"))
  //                         .then((date) {
  //                       setState(() {
  //                         if (date != null) {
  //                           _dateStartTestDrive =
  //                               DateFormat('d MMMM yyyy', "ru_RU").format(date);
  //                         }
  //                       });
  //                     });
  //                   },
  //                   color: Colors.blue),
  //             ),
  //             !_isCategoryPhotocamera
  //                 ? ListTile(
  //                     contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
  //                     leading: const Icon(Icons.today),
  //                     title: const Text("Дата конца тест-драйва"),
  //                     subtitle: Text(DateFormat('d MMMM yyyy', "ru_RU").format(
  //                         DateTime.parse(_dateFinishTestDrive.replaceAll('.', '-')))),
  //                     trailing: IconButton(
  //                         icon: const Icon(Icons.edit),
  //                         onPressed: () {
  //                           showDatePicker(
  //                                   context: context,
  //                                   initialDate: DateTime.now(),
  //                                   firstDate: DateTime(2000),
  //                                   lastDate: DateTime(2099),
  //                                   locale: const Locale("ru", "RU"))
  //                               .then((date) {
  //                             setState(() {
  //                               if (date != null) {
  //                                 _dateFinishTestDrive =
  //                                     DateFormat('d MMMM yyyy', "ru_RU").format(date);
  //                               }
  //                             });
  //                           });
  //                         },
  //                         color: Colors.blue),
  //                   )
  //                 : const SizedBox.shrink(),
  //             ListTile(
  //               contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
  //               leading: const Icon(Icons.create),
  //               title: TextFormField(
  //                 decoration:
  //                     const InputDecoration(hintText: "Результат проверки-тестирования"),
  //                 controller: _resultTestDrive,
  //               ),
  //             ),
  //             CheckboxListTile(
  //                 contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
  //                 title: const Text('Тест-драйв выполнен'),
  //                 secondary: const Icon(Icons.check),
  //                 value: _checkboxTestDrive,
  //                 onChanged: (bool? value) {
  //                   setState(() {
  //                     _checkboxTestDrive = value!;
  //                   });
  //                 })
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future _save(Technic technic, ProviderModel providerModel) async {
    String nameUser = providerModel.user.name;
    await ConnectDbMySQL.connDB.connDatabase();
    int id = await ConnectDbMySQL.connDB.insertTechnicInDB(technic, nameUser);
    await ConnectDbMySQL.connDB.dispose();
    technic.id = id;
    // await addHistory(technic, nameUser);
    addTechnicInProviderModel(technic, providerModel);
  }

  void addTechnicInProviderModel(Technic technic, ProviderModel providerModel) {
    String dislocation = technic.dislocation;
    if (providerModel.technicsInPhotosalons.keys.any((element) => element == dislocation)) {
      providerModel.addTechnicInPhotosalon(dislocation, technic);
    } else {
      providerModel.addTechnicInStorage(dislocation, technic);
    }
  }

  Future addHistory(Technic technic, String nameUser) async {
    String descForHistory = descriptionForHistory(technic);
    History history = History(History.historyList.last.id + 1, 'Technic', technic.id, 'create', descForHistory,
        nameUser, DateFormat('yyyy.MM.dd').format(DateTime.now()));

    ConnectDbMySQL.connDB.insertHistory(history);
    History.historyList.insert(0, history);
  }

  String descriptionForHistory(Technic technic) {
    String internalID = technic.number == -1 ? 'БН' : '№${technic.number}';
    String result = 'Новая техника $internalID добавленна';

    return result;
  }

  String getDateFormat(String date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }

  void _viewSnackBar(IconData icon, bool isSuccessful, String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, size: 40, color: isSuccessful ? Colors.green : Colors.red),
            SizedBox(
              width: 20,
            ),
            Flexible(child: Text(text)),
          ],
        ),
        duration: const Duration(seconds: 5),
        showCloseIcon: true,
      ),
    );
  }

  void _viewSnackBarCheckEmptyNumberTechnic(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.bolt, size: 40, color: text == 'Номер свободен' ? Colors.green : Colors.red),
            Flexible(child: Text(text)),
          ],
        ),
        duration: const Duration(seconds: 5),
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
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
        formattedText = formattedText.substring(0, index) +
            thousandSeparator +
            formattedText.substring(index, formattedText.length);
      }
    }

    /// Check whether the text is unmodified.
    if (oldValue.text == formattedText) {
      return oldValue;
    }

    /// Handle moving cursor.
    final initialNumberOfPrecedingSeparators = oldValue.text.characters.where((e) => e == thousandSeparator).length;
    final newNumberOfPrecedingSeparators = formattedText.characters.where((e) => e == thousandSeparator).length;
    final additionalOffset = newNumberOfPrecedingSeparators - initialNumberOfPrecedingSeparators;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newValue.selection.baseOffset + additionalOffset),
    );
  }
}
