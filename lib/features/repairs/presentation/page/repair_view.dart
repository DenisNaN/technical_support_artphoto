import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/shared/technic_image/is_fields_filled.dart';
import '../../../technics/models/technic.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../../core/utils/enums.dart';
import '../../../../main.dart';
import '../../models/repair.dart';
import '../widget/first_step_repair_desc.dart';

class RepairView extends StatefulWidget {
  const RepairView({super.key, required this.repair});

  final Repair repair;

  @override
  State<RepairView> createState() => _RepairViewState();
}

class _RepairViewState extends State<RepairView> {
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

  String? validateDropdownDislocationNew(ProviderModel providerModel) {
    List<String> nameDislocation = providerModel.namesDislocation;
    for (var element in nameDislocation) {
      if (widget.repair.newDislocation != '') {
        if (element == widget.repair.newDislocation) {
          return widget.repair.newDislocation;
        }
      }
    }
    return _selectedDropdownDislocationNew;
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    Color colorStepTwoRepair = _getColorStepTwoRepair();
    Color colorStepThreeRepair = _getColorStepThreeRepair();
    return Scaffold(
        appBar: CustomAppBar(typePage: TypePage.viewRepair, location: widget.repair, technic: null),
        body: Form(
          child: ListView(
            children: [
              SizedBox(height: 10),
              _headerData(),
              SizedBox(height: 20),
              Center(
                  child: Text(
                'Второй этап заявки',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: colorStepTwoRepair, borderRadius: BorderRadius.circular(30)),
                    child: Column(spacing: 10, children: [
                      _buildServices(providerModel),
                      _buildDateTransferInService(),
                    ])),
              ),
              SizedBox(height: 10),
              Center(
                  child: Column(
                children: [
                  Text(
                    'Третий этап заявки',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: colorStepThreeRepair, borderRadius: BorderRadius.circular(30)),
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
                        Repair repair = Repair.fullRepair(
                          widget.repair.id,
                          widget.repair.numberTechnic,
                          widget.repair.category,
                          widget.repair.dislocationOld,
                          widget.repair.status,
                          widget.repair.complaint,
                          widget.repair.dateDeparture,
                          widget.repair.whoTook,
                          widget.repair.idTrouble,
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
                          widget.repair.idTestDrive,
                        );

                        _save(repair, providerModel).then((TypeMessageForSaveRepairView value) {
                          try{
                            switch (value) {
                              case TypeMessageForSaveRepairView.successSaveRepair:
                                _viewSnackBar(Icons.save, true, 'Заявка изменена', '', true, repair);
                              case TypeMessageForSaveRepairView.notSuccessSaveRepair:
                                _viewSnackBar(Icons.save, false, '', 'Заявка не изменена', true, repair);
                              case TypeMessageForSaveRepairView.notSuccessSaveStatus:
                                _viewSnackBar(
                                    Icons.print_disabled,
                                    false,
                                    '',
                                    'Статус и дислокацию техники изменить не удалось. Попробуйте вручную в карточке техники',
                                    false, repair);
                              case TypeMessageForSaveRepairView.notWriteAllFieldStatus:
                                _viewSnackBar(
                                    Icons.print_disabled, false, '', 'Статус или дислокация не заполенены.\n', false, repair);
                              case TypeMessageForSaveRepairView.notCheckTechnicInDB:
                                _viewSnackBar(Icons.print_disabled, false, '',
                                    'Техника с таким номером в базе не обнаружена', false, repair);
                            }
                          }catch(e){
                            debugPrint(e.toString());
                          }
                        });
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

  Color _getColorStepTwoRepair() {
    bool isDateTransferInService = _dateTransferInService.toString() == "-0001-11-30 00:00:00.000Z" ||
        _dateTransferInService.toString() == "0001-11-30 00:00:00.000Z";
    if (_selectedDropdownService == null || isDateTransferInService) {
      return Colors.yellow.shade200;
    }
    return Colors.greenAccent.shade100;
  }

  Color _getColorStepThreeRepair() {
    bool isDateDepartureFormService = _dateDepartureFromService.toString() == "-0001-11-30 00:00:00.000Z"  ||
        _dateDepartureFromService.toString() == "0001-11-30 00:00:00.000Z" ? true : false;
    bool isDateReceipt = _dateReceipt.toString() == "-0001-11-30 00:00:00.000Z" ||
        _dateReceipt.toString() == "0001-11-30 00:00:00.000Z" ? true : false;

    if (!isDateDepartureFormService &&
        _worksPerformed.text != '' &&
        _costService.text != '' &&
        _diagnosisService.text != '' &&
        _selectedDropdownStatusNew != null &&
        _selectedDropdownDislocationNew != null &&
        !isDateReceipt) {
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
          )),
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
          padding: const EdgeInsets.symmetric(horizontal: 57),
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                      context: context,
                      initialDate: _dateTransferInService.toString() == "-0001-11-30 00:00:00.000Z" ||
                          _dateTransferInService.toString() == "0001-11-30 00:00:00.000Z"
                          ? DateTime.now()
                          : _dateTransferInService,
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
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20, left: 12),
                    child: Text(_dateTransferInService.toString() == "-0001-11-30 00:00:00.000Z" ||
                        _dateTransferInService.toString() == "0001-11-30 00:00:00.000Z"
                        ? 'Дата отсутствует'
                        : DateFormat('d MMMM yyyy', 'ru_RU').format(_dateTransferInService ?? DateTime.now())),
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
          padding: const EdgeInsets.symmetric(horizontal: 57),
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                      context: context,
                      initialDate: _dateDepartureFromService.toString() == "-0001-11-30 00:00:00.000Z" || _dateDepartureFromService.toString() == "0001-11-30 00:00:00.000Z"
                          ? DateTime.now()
                          : _dateDepartureFromService,
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
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20, left: 12),
                    child: Text(_dateDepartureFromService.toString() == "-0001-11-30 00:00:00.000Z" || _dateDepartureFromService.toString() == "0001-11-30 00:00:00.000Z"
                        ? 'Дата отсутствует'
                        : DateFormat('d MMMM yyyy', 'ru_RU').format(_dateDepartureFromService ?? DateTime.now())),
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
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Произведенные работы"),
              controller: _worksPerformed,
              maxLines: 3,
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
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Стоимость ремонта"),
              controller: _costService,
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
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Диагноз мастерской"),
              controller: _diagnosisService,
              maxLines: 2,
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
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextFormField(
              decoration: myDecorationTextFormField(null, "Рекомендации/примечания"),
              controller: _recommendationsNotes,
              maxLines: 2,
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
          )),
        ),
      ],
    );
  }

  Widget _buildNewDislocation(ProviderModel providerModel) {
    if(_selectedDropdownDislocationNew == '' || _selectedDropdownDislocationNew == null){
      _selectedDropdownDislocationNew = validateDropdownDislocationNew(providerModel);
    }
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
          )),
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
          padding: const EdgeInsets.symmetric(horizontal: 57),
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                      context: context,
                      initialDate:
                          _dateReceipt.toString() == "-0001-11-30 00:00:00.000Z" || _dateReceipt.toString() == "0001-11-30 00:00:00.000Z" ? DateTime.now() : _dateReceipt,
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
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20, left: 12),
                    child: Text(_dateReceipt.toString() == "-0001-11-30 00:00:00.000Z" || _dateReceipt.toString() == "0001-11-30 00:00:00.000Z"
                        ? 'Дата отсутствует'
                        : DateFormat('d MMMM yyyy', 'ru_RU').format(_dateReceipt ?? DateTime.now())),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<TypeMessageForSaveRepairView> _save(Repair repair, ProviderModel providerModel) async {
    if((repair.newStatus != null && repair.newDislocation != null) || (repair.newStatus == null && repair.newDislocation == null)){
      List<Repair>? resultData = await TechnicalSupportRepoImpl.downloadData.updateRepair(repair, false);
      bool isFinishedRepair = isFieldsFilledRepair(repair);
      if (resultData != null) {
        if(repair.newStatus == null && repair.newDislocation == null){
          providerModel.refreshCurrentRepairs(resultData);
          return TypeMessageForSaveRepairView.successSaveRepair;
        }
        Technic? technic = await TechnicalSupportRepoImpl.downloadData.getTechnic(repair.numberTechnic.toString());
        if (technic != null) {
          technic.status = repair.newStatus!;
          technic.dislocation = repair.newDislocation!;
          bool isSaveStatusTechnic = await TechnicalSupportRepoImpl.downloadData
              .updateStatusAndDislocationTechnic(technic, providerModel.user.name);
          if (isSaveStatusTechnic) {
            Map<String, dynamic> resultDataRefTech = await TechnicalSupportRepoImpl.downloadData.refreshTechnicsData();
            if (!isFinishedRepair) {
              providerModel..
                          refreshTechnics(resultDataRefTech['Photosalons'], resultDataRefTech['Repairs'], resultDataRefTech['Storages'])..
                          refreshCurrentRepairs(resultData);
            }
            return TypeMessageForSaveRepairView.successSaveRepair;
          }else{
            return TypeMessageForSaveRepairView.notSuccessSaveStatus;
          }
        }else{
          return TypeMessageForSaveRepairView.notCheckTechnicInDB;
        }
      }else{
        return TypeMessageForSaveRepairView.notSuccessSaveRepair;
      }
    }else{
      return TypeMessageForSaveRepairView.notWriteAllFieldStatus;
    }
    // await addHistory(technic, nameUser);
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

  void _viewSnackBar(
      IconData icon, bool isSuccessful, String successfulText, String notSuccessfulText, bool isSkipPrevSnackBar, Repair repair) {
    if (context.mounted) {
      final providerModel = Provider.of<ProviderModel>(context, listen: false);
      if (isSkipPrevSnackBar) {
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
      if((repair.newStatus == null && repair.newDislocation != null) ||
          (repair.newStatus != null && repair.newDislocation == null)){}else{
        providerModel.changeCurrentPageMainBottomAppBar(1);
        Navigator.pushAndRemoveUntil(
            context, animationRouteSlideTransition(const ArtphotoTech(indexPage: 1,)), (Route<dynamic> route) => false);
      }
    }
  }
}
