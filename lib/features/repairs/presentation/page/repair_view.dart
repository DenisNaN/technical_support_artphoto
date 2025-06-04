import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import '../../../../core/api/data/models/technic.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../../core/utils/enums.dart';
import '../../models/repair.dart';
import '../widget/first_step_repair_desc.dart';

class RepairView extends StatefulWidget {
  const RepairView({super.key, required this.repair});

  final Repair repair;

  @override
  State<RepairView> createState() => _RepairViewState();
}

class _RepairViewState extends State<RepairView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedDropdownService;
  DateTime? _dateTransferInService;
  DateTime? _dateDepartureFromService;
  final _worksPerformed = TextEditingController();
  final _costService = TextEditingController();
  final _diagnosisService = TextEditingController();
  final _recommendationsNotes = TextEditingController();
  String? _selectedDropdownStatusNew;
  String? _selectedDropdownDislocationNew;
  DateTime? _dateReceipt;

  @override
  void initState() {
    super.initState();
    _selectedDropdownService = widget.repair.serviceDislocation != '' ? widget.repair.serviceDislocation : null;
    _dateTransferInService = widget.repair.dateTransferInService;
    _dateDepartureFromService = widget.repair.dateDepartureFromService;
    _worksPerformed.text = widget.repair.worksPerformed ?? '';
    _costService.text = widget.repair.costService.toString();
    _diagnosisService.text = widget.repair.diagnosisService ?? '';
    _recommendationsNotes.text = widget.repair.recommendationsNotes ?? '';
    _selectedDropdownStatusNew = widget.repair.newStatus != '' ? widget.repair.newStatus : null;
    _selectedDropdownDislocationNew = widget.repair.newDislocation != '' ? widget.repair.newDislocation : null;
    _dateReceipt = widget.repair.dateReceipt;
  }

  @override
  void dispose() {
    _worksPerformed.dispose();
    _costService.dispose();
    _diagnosisService.dispose();
    _recommendationsNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    Color colorStepTwoRepair = _getColorStepTwoRepair();
    Color colorStepThreeRepair = _getColorStepThreeRepair();
    return Scaffold(
        appBar: CustomAppBar(typePage: TypePage.viewRepair, location: widget.repair, technic: null),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: 10),
              _headerData(),
              SizedBox(height: 20),
              Center(child: Text('Второй этап заявки',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      color: colorStepTwoRepair,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Column(
                      spacing: 10,
                      children: [
                    _buildServices(providerModel),
                    _buildDateTransferInService(),
                  ])),
              ),
              SizedBox(height: 10),
              Center(child: Column(
                children: [
                  Text('Третий этап заявки',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),),
                ],
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        color: colorStepThreeRepair,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        _buildDateDepartureFromService(),
                        _buildWorksPerformed(),
                        _buildCostService(),
                        _buildDiagnosisService(),
                        _buildRecommendationsNotes(),
                        _buildNewStatus(providerModel),
                        _buildNewDislocation(providerModel),
                        _buildDateReceipt(),
                      ],
                    )),
              ),
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
                        if (_formKey.currentState!.validate()) {
                          Repair repair = Repair.fullRepair(
                              widget.repair.id,
                              widget.repair.numberTechnic,
                              widget.repair.category,
                              widget.repair.dislocationOld,
                              widget.repair.status,
                              widget.repair.complaint,
                              widget.repair.dateDeparture,
                              widget.repair.whoTook,
                              _selectedDropdownService,
                              _dateTransferInService,
                              _dateDepartureFromService,
                              _worksPerformed.text,
                              int.parse(_costService.text),
                              _diagnosisService.text,
                              _recommendationsNotes.text,
                              _selectedDropdownStatusNew,
                              _selectedDropdownDislocationNew,
                              _dateReceipt,
                          );

                          _save(repair, providerModel).then((value) {
                            _viewSnackBar(Icons.save, value, 'Заявка изменена', 'Заявка не изменена', true);
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
          ),
        ));
  }

  Color _getColorStepTwoRepair(){
    if(_selectedDropdownService != null &&
        _dateTransferInService.toString() != "-0001-11-30 00:00:00.000Z"){
      return Colors.greenAccent.shade100;
    }
    return Colors.yellow.shade200;
  }

  Color _getColorStepThreeRepair(){
    if(_dateDepartureFromService.toString() != "-0001-11-30 00:00:00.000Z" &&
    _worksPerformed.text != '' &&
    _costService.text != '' &&
    _diagnosisService.text != '' &&
    _recommendationsNotes.text != '' &&
    _selectedDropdownStatusNew != null &&
    _selectedDropdownDislocationNew != null &&
    _dateReceipt.toString() != "-0001-11-30 00:00:00.000Z"
    ){
      return Colors.greenAccent.shade100;
    }
    return Colors.yellow.shade200;
  }

  Column _headerData() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                offset: Offset(2, 4), // Shadow position
              ),
            ]),
            child: FirstStepRepairDesc(repair: widget.repair),
          ),
        ),
      ],
    );
  }

  Widget _buildServices(ProviderModel providerModel) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Мастер по ремонту',
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
                    hint: const Text('Мастер по ремонту'),
                    value: _selectedDropdownService,
                    items: providerModel.services.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedDropdownService = value!;
                      });
                    },
                  )
          ),
        ),
      ],
    );
  }

  Widget _buildDateTransferInService() {
    return Column(
      spacing: 5,
      children: [
        Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'Отвезли мастеру',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:  57),
          child: GestureDetector(
            onTap: (){
              showDatePicker(
                  context: context,
                  initialDate: _dateTransferInService.toString() != "-0001-11-30 00:00:00.000Z" ? _dateTransferInService : DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2099),
                  locale: const Locale("ru", "RU"))
                  .then((date) {
                if (date != null) {
                  setState(() {
                    _dateTransferInService = date;
                  });
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20, left: 12),
                    child: Text(
                        _dateTransferInService.toString() != "-0001-11-30 00:00:00.000Z" ?
                        DateFormat('d MMMM yyyy', 'ru_RU').format(_dateTransferInService ?? DateTime.now())
                        : 'Дата отсутствует'
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateDepartureFromService() {
    return Column(
      spacing: 5,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Забрали из сервиса',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:  57),
          child: GestureDetector(
            onTap: (){
              showDatePicker(
                  context: context,
                  initialDate: _dateDepartureFromService.toString() != "-0001-11-30 00:00:00.000Z" ? _dateDepartureFromService : DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2099),
                  locale: const Locale("ru", "RU"))
                  .then((date) {
                if (date != null) {
                  setState(() {
                    _dateDepartureFromService = date;
                  });
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20, left: 12),
                    child: Text(
                        _dateDepartureFromService.toString() != "-0001-11-30 00:00:00.000Z" ?
                        DateFormat('d MMMM yyyy', 'ru_RU').format(_dateDepartureFromService ?? DateTime.now())
                            : 'Дата отсутствует'
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorksPerformed() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Произведенные работы',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal:  40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Произведенные работы"),
              controller: _worksPerformed,
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

  Widget _buildCostService() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Стоимость ремонта',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal:  40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Стоимость ремонта"),
              controller: _costService,
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

  Widget _buildDiagnosisService() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Диагноз мастерской',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal:  40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Диагноз мастерской"),
              controller: _diagnosisService,
              maxLines: 2,
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

  Widget _buildRecommendationsNotes() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Рекомендации/примечания',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal:  40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Рекомендации/примечания"),
              controller: _recommendationsNotes,
              maxLines: 2,
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

  Widget _buildNewStatus(ProviderModel providerModel) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Новый статус',
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
                hint: const Text('Новый статус'),
                value: _selectedDropdownStatusNew,
                items: providerModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedDropdownStatusNew = value!;
                  });
                },
              )
          ),
        ),
      ],
    );
  }

  Widget _buildNewDislocation(ProviderModel providerModel) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Куда уехал',
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
                hint: const Text('Куда уехал'),
                value: _selectedDropdownDislocationNew,
                items: providerModel.namesDislocation.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedDropdownDislocationNew = value!;
                  });
                },
              )
          ),
        ),
      ],
    );
  }

  Widget _buildDateReceipt() {
    return Column(
      spacing: 5,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Дата поступления',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:  57),
          child: GestureDetector(
            onTap: (){
              showDatePicker(
                  context: context,
                  initialDate: _dateReceipt.toString() != "-0001-11-30 00:00:00.000Z" ? _dateReceipt : DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2099),
                  locale: const Locale("ru", "RU"))
                  .then((date) {
                if (date != null) {
                  setState(() {
                    _dateReceipt = date;
                  });
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20, left: 12),
                    child: Text(
                        _dateReceipt.toString() != "-0001-11-30 00:00:00.000Z" ?
                        DateFormat('d MMMM yyyy', 'ru_RU').format(_dateReceipt ?? DateTime.now())
                            : 'Дата отсутствует'
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _save(Repair repair, ProviderModel provider) async {
    bool isResult = await TechnicalSupportRepoImpl.downloadData.updateRepair(repair, false);
    if (isResult) {
      Technic? technic = await TechnicalSupportRepoImpl.downloadData.getTechnic(repair.numberTechnic.toString());
      if(technic != null){
        bool isSaveStatus = await TechnicalSupportRepoImpl.downloadData.updateStatusAndDislocationTechnic(technic, provider.user.name);
        if(isSaveStatus){
          return true;
        }
        _viewSnackBar(Icons.print_disabled, false, '', 'Статус и дислокацию техники изменить не удалось. Попробуйте вручную в карточке техники', false);
        return false;
      }
      _viewSnackBar(Icons.print_disabled, false, '', 'Техника с таким номером в базе не обнаружена', false);
      provider.addRepairInRepairs(repair);
      // await addHistory(technic, nameUser);
      return true;
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

  void _viewSnackBar(IconData icon, bool isSuccessful, String successfulText, String notSuccessfulText, bool isSkipPrevSnackBar) {
    if(isSkipPrevSnackBar){
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, size: 40, color: isSuccessful ? Colors.green : Colors.red),
            SizedBox(
              width: 20,
            ),
            Flexible(child: Text(isSuccessful ? successfulText : notSuccessfulText)),
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
