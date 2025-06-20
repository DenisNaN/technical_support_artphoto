import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/features/test_drive/models/test_drive.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import 'package:technical_support_artphoto/main.dart';

import '../../../technics/models/technic.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../models/repair.dart';

class RepairAdd extends StatefulWidget {
  const RepairAdd({super.key, this.trouble, this.technic});

  final Trouble? trouble;
  final Technic? technic;

  @override
  State<RepairAdd> createState() => _RepairAddState();
}

class _RepairAddState extends State<RepairAdd> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _innerNumberTechnic = TextEditingController();
  final _nameTechnicController = TextEditingController();
  final _dislocationOldController = TextEditingController();
  final _complaint = TextEditingController();
  DateTime? _dateDeparture;
  final _worksPerformed = TextEditingController();
  final _costService = TextEditingController();
  final _diagnosisService = TextEditingController();
  final _recommendationsNotes = TextEditingController();
  String? _selectedDropdownDislocationOld;
  String? _selectedDropdownStatusOld = 'В ремонте';
  bool isBN = false;
  bool isExistNumber = false;

  Technic? technicFind;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if(widget.trouble != null){
      _complaint.text = widget.trouble!.trouble;
      _dislocationOldController.text = widget.trouble!.photosalon;
      _selectedDropdownDislocationOld = widget.trouble!.photosalon;
      if(widget.technic != null){
        _innerNumberTechnic.text = widget.technic!.number.toString();
        _nameTechnicController.text = widget.technic!.name;
      }else{
        isBN = true;
        _selectedDropdownDislocationOld = widget.trouble!.photosalon;
      }
    }
    _dateDeparture = DateTime.now();
  }

  @override
  void dispose() {
    _innerNumberTechnic.dispose();
    _complaint.dispose();
    _worksPerformed.dispose();
    _costService.dispose();
    _diagnosisService.dispose();
    _recommendationsNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Scaffold(
        key: scaffoldKey,
        appBar: CustomAppBar(typePage: TypePage.addRepair, location: null, technic: null),
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildInternalID(),
              SizedBox(height: 20),
              _buildNameTechnic(),
              SizedBox(height: isBN ? 14 : 25),
              _buildLastDislocation(providerModel),
              SizedBox(height: isBN ? 9 : 25),
              _buildStatus(providerModel),
              SizedBox(height: 20),
              _buildComplaint(),
              SizedBox(height: 20),
              _buildDateDeparture(),
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
                          Repair repair = Repair(
                              !isBN ? int.parse(_innerNumberTechnic.text) : 0,
                              _nameTechnicController.text,
                              isBN ? _dislocationOldController.text : _selectedDropdownDislocationOld ?? '',
                              _selectedDropdownStatusOld ?? '',
                              _complaint.text,
                              _dateDeparture ?? DateTime.now(),
                              providerModel.user.name,);
                          if(widget.trouble != null){
                            repair.idTrouble = widget.trouble!.id!;
                          }

                          _save(repair, providerModel).then((isSave) {
                            providerModel.changeCurrentPageMainBottomAppBar(1);
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
              Text(isBN ? 'Включить номер' : 'Выключить номер'),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                    value: isBN,
                    onChanged: (value) {
                      setState(() {
                        isBN = value;
                        if (value == true) {
                          _innerNumberTechnic.text = '';
                          _nameTechnicController.text = '';
                          _selectedDropdownDislocationOld = null;
                          _dislocationOldController.text = '';
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
                  enabled: !isBN,
                  decoration: myDecorationTextFormField(!isBN ? 'Номер техники' : 'Без номера'),
                  controller: _innerNumberTechnic,
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
            backgroundColor: !isBN ? Colors.blue : Colors.grey,
          ),
          onPressed: () async {
            if (_innerNumberTechnic.text != '' && !isBN) {
              TechnicalSupportRepoImpl.downloadData.getTechnic(_innerNumberTechnic.text).then((result) {
                if (result != null) {
                  setState(() {
                    _nameTechnicController.text = result.name;
                    _dislocationOldController.text = result.dislocation;
                    _selectedDropdownDislocationOld = result.dislocation;
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
              enabled: isBN,
              decoration: myDecorationTextFormField(null, isBN ? 'Наименование техники' : 'Введите номер техники'),
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

  Widget _buildLastDislocation(ProviderModel providerModel) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Откуда забрали:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: isBN
                ? DropdownButtonFormField<String>(
                    decoration: myDecorationDropdown(),
                    validator: (value) => value == null ? "Обязательное поле" : null,
                    dropdownColor: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10.0),
                    hint: const Text('Последнее местонахождение'),
                    value: _selectedDropdownDislocationOld,
                    items: providerModel.namesDislocation.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedDropdownDislocationOld = value!;
                      });
                    },
                  )
                : TextFormField(
                    enabled: false,
                    decoration: myDecorationTextFormField(null, 'Введите номер техники'),
                    controller: _dislocationOldController,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatus(ProviderModel providerModel) {
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
              value: _selectedDropdownStatusOld,
              items: providerModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedDropdownStatusOld = value!;
                });
              },
            ),
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

  Widget _buildDateDeparture() {
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
              DateFormat('d MMMM yyyy', 'ru_RU').format(_dateDeparture ?? DateTime.now()),
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
                    _dateDeparture = date;
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

  Future<bool> _save(Repair repair, ProviderModel providerModel) async{
    LoadingOverlay.of(context).show();
    List<Repair>? resultData =
      await TechnicalSupportRepoImpl.downloadData.saveRepair(repair);
    if(resultData != null){
      Technic? technic =
        await TechnicalSupportRepoImpl.downloadData.getTechnic(repair.numberTechnic.toString());
      if (technic != null) {
        if(technic.status == 'Тест-драйв'){
          if (technic.testDrive != null) {
            TestDrive testDrive = TestDrive(
                id: technic.testDrive!.id!,
                idTechnic: technic.id,
                categoryTechnic: technic.category,
                dislocationTechnic: technic.dislocation,
                dateStart: technic.testDrive!.dateStart,
                dateFinish: DateTime.now(),
                result: 'Увезли в ремонт',
                isCloseTestDrive: true,
                user: providerModel.user.name);
            await TechnicalSupportRepoImpl.downloadData.updateTestDrive(testDrive);
          }
        }
        technic.status = repair.status;
        if(technic.status == 'В ремонте'){
          technic.dislocation = 'Сергей';
        }
        await TechnicalSupportRepoImpl.downloadData.updateStatusAndDislocationTechnic(technic, providerModel.user.name);
        Map<String, dynamic> technics = await TechnicalSupportRepoImpl.downloadData.refreshTechnicsData();
        providerModel.refreshTechnics(
            technics['Photosalons'], technics['Repairs'], technics['Storages']);
      }
      providerModel.refreshCurrentRepairs(resultData);
      // await addHistory(technic, nameUser);
      if(mounted){
        LoadingOverlay.of(context).hide();
      }
      return true;
    }
    if(mounted){
      LoadingOverlay.of(context).hide();
    }
    return false;
  }

  Future addHistory(Repair repair) async {
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
  }

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
      Navigator.pushAndRemoveUntil(
          context, animationRouteSlideTransition(const ArtphotoTech(indexPage: 1,)), (Route<dynamic> route) => false);
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
