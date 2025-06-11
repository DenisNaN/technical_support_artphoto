import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';

class TroubleAdd extends StatefulWidget {
  const TroubleAdd({super.key});

  @override
  State<TroubleAdd> createState() => _TroubleAddState();
}

class _TroubleAddState extends State<TroubleAdd> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isBN = false;
  final _numberTechnic = TextEditingController();
  final _nameTechnicController = TextEditingController();
  String? _nameTechnic;
  String? _selectedDropdownDislocation;
  String? _dislocation;
  DateTime? _dateTrouble;
  final _complaint = TextEditingController();
  Uint8List? _photoTrouble;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _dateTrouble = DateTime.now();
    _dislocation = '';
  }

  @override
  void dispose() {
    _numberTechnic.dispose();
    _nameTechnicController.dispose();
    _complaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Scaffold(
        key: scaffoldKey,
        appBar: CustomAppBar(typePage: TypePage.addTrouble, location: null, technic: null),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildInternalID(),
              SizedBox(height: 20),
              _buildNameTechnic(),
              SizedBox(height: _isBN ? 14 : 25),
              _buildDislocation(providerModel),
              SizedBox(height: 20),
              _buildComplaint(),
              SizedBox(height: 20),
              _buildDateTrouble(),
              SizedBox(height: 20),
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
                        if (formKey.currentState!.validate()) {
                          Trouble trouble = Trouble(
                              id: null,
                              photosalon: _isBN ? _selectedDropdownDislocation ?? '' : _dislocation ?? '',
                              dateTrouble: _dateTrouble ?? DateTime.now(),
                              employee: providerModel.user.name,
                              numberTechnic: _isBN ? int.parse(_numberTechnic.text) : 0,
                              trouble: _complaint.text,);
                          trouble.photoTrouble = _photoTrouble;

                          _save(trouble, providerModel).then((isSave) {
                            _viewSnackBar(Icons.save, isSave, 'Заявка создана', 'Заявка не создана', scaffoldKey);
                          });
                        }
                      },
                      child: const Text("Сохранить")),
                ],
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ));
  }

  Column _buildInternalID() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              Text(_isBN ? 'Включить номер' : 'Выключить номер'),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                    value: _isBN,
                    onChanged: (value) {
                      setState(() {
                        _isBN = value;
                        if (value == true) {
                          _numberTechnic.text = '';
                          _nameTechnicController.text = '';
                          _selectedDropdownDislocation = null;
                          _dislocation = '';
                        }
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
                  enabled: !_isBN,
                  decoration: myDecorationTextFormField(!_isBN ? 'Номер техники' : 'Без номера'),
                  controller: _numberTechnic,
                  validator: (value) {
                    if (value!.isEmpty && !_isBN) {
                      return 'Обязательное поле';
                    }
                    return null;
                  },
                  inputFormatters: [numberFormatter],
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            _buildButtonGetTechnic(),
          ],
        ),
      ],
    );
  }

  Padding _buildButtonGetTechnic() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 30),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: !_isBN ? Colors.blue : Colors.grey,
          ),
          onPressed: () async {
            if (_numberTechnic.text != '' && !_isBN) {
              TechnicalSupportRepoImpl.downloadData.getTechnic(_numberTechnic.text).then((result) {
                if (result != null) {
                  setState(() {
                    _nameTechnicController.text = result.name;
                    _dislocation = result.dislocation;
                    _selectedDropdownDislocation = result.dislocation;
                  });
                } else {
                  _viewSnackBarGetTechnic('Техники с таким номером нет.');
                }
              });
            }
          },
          child: Text('Найти технику')),
    );
  }

  Widget _buildNameTechnic() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Наименование техники',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: TextFormField(
              enabled: _isBN,
              decoration: myDecorationTextFormField(null, _isBN ? 'Наименование техники' : 'Введите номер техники'),
              controller: _nameTechnicController,
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

  Widget _buildDislocation(ProviderModel providerModel) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Где:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: _isBN
                ? DropdownButtonFormField<String>(
                    decoration: myDecorationDropdown(),
                    validator: (value) => value == null ? "Обязательное поле" : null,
                    dropdownColor: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10.0),
                    hint: const Text('Местонахождение'),
                    value: _selectedDropdownDislocation,
                    items: providerModel.namesDislocation.map<DropdownMenuItem<String>>((String value) {
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
                  )
                : Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 24),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
              ),
                child: Text(_dislocation == '' ? 'Введите номер техники' : _dislocation ?? '', style: TextStyle(color: Colors.black45),)),
          ),
        ),
      ],
    );
  }

  Widget _buildComplaint() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Жалоба',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal:  40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Жалоба"),
              controller: _complaint,
              maxLines: 3,
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

  Widget _buildDateTrouble() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Дата, когда забрали.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 55, right: 55, top: 6),
          child: ListTile(
            title: Text(
              DateFormat('d MMMM yyyy', 'ru_RU').format(_dateTrouble ?? DateTime.now()),
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
                    _dateTrouble = date;
                  }
                });
              });
            },
          ),
        ),
      ],
    );
  }

  void _viewSnackBarGetTechnic(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.bolt, size: 40, color: Colors.red),
            Flexible(child: Text(text)),
          ],
        ),
        duration: const Duration(seconds: 5),
        showCloseIcon: true,
      ),
    );
  }

  Future<bool> _save(Trouble trouble, ProviderModel providerModel) async{
    List<Trouble>? resultData = await TechnicalSupportRepoImpl.downloadData.saveTrouble(trouble);
    if(resultData != null){
      providerModel.refreshTroubles(resultData);
      // await addHistory(technic, nameUser);
      return true;
    }
    return false;
  }

  // Future addHistory(Trouble trouble) async {
    // String descForHistory = descriptionForHistory(repair);
    // History historyForSQL = History(
    //     History.historyList.last.id + 1,
    //     'Repair',
    //     repair.id!,
    //     'create',
    //     descForHistory,
    //     LoginPassword.login,
    //     DateFormat('yyyy.MM.dd').format(DateTime.now())
    // );
    //
    // ConnectToDBMySQL.connDB.insertHistory(historyForSQL);
    // HistorySQFlite.db.insertHistory(historyForSQL);
    // History.historyList.insert(0, historyForSQL);
  // }

  // String descriptionForHistory(Repair repair){
  //   String internalID = repair.internalID == -1 ? 'БН' : '№${repair.internalID}';
  //   String result = 'Заявка на ремонт $internalID добавленна';
  //
  //   return result;
  // }

  void _viewSnackBar(IconData icon, bool isSuccessful, String successText, String notSuccessText, GlobalKey<ScaffoldState> scaffoldKey) {
    final contextViewSnackBar = scaffoldKey.currentContext;
    if(contextViewSnackBar != null && contextViewSnackBar.mounted){
      ScaffoldMessenger.of(contextViewSnackBar).hideCurrentSnackBar();
      ScaffoldMessenger.of(contextViewSnackBar).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, size: 40, color: isSuccessful ? Colors.green : Colors.red),
              SizedBox(
                width: 20,
              ),
              Flexible(child: Text(isSuccessful ? successText : notSuccessText)),
            ],
          ),
          duration: const Duration(seconds: 5),
          showCloseIcon: true,
        ),
      );
      Navigator.pop(contextViewSnackBar);
    }
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
