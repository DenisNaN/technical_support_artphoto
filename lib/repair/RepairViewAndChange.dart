import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technical_support_artphoto/history/History.dart';
import 'package:technical_support_artphoto/history/HistorySQFlite.dart';
import 'package:technical_support_artphoto/repair/RepairSQFlite.dart';
import 'package:technical_support_artphoto/technics/TechnicSQFlite.dart';
import 'package:technical_support_artphoto/utils/utils.dart';
import '../ConnectToDBMySQL.dart';
import '../technics/Technic.dart';
import '../technics/TechnicViewAndChange.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/hasNetwork.dart';
import 'package:intl/intl.dart';
import 'Repair.dart';

class RepairViewAndChange extends StatefulWidget {
  final Repair repair;
  const RepairViewAndChange({super.key, required this.repair});

  @override
  State<RepairViewAndChange> createState() => _RepairViewAndChangeState();
}

class _RepairViewAndChangeState extends State<RepairViewAndChange> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _innerNumberTechnic = '';
  String _nameTechnic = '';
  final _complaintController = TextEditingController();
  String _dateDeparture = '';
  String _dateTransferInService = '';
  String _dateDepartureFromService = '';
  final _worksPerformed = TextEditingController();
  final _costService = TextEditingController();
  final _diagnosisService = TextEditingController();
  final _recommendationsNotes = TextEditingController();
  String _dateReceipt = '';
  String? _selectedDropdownDislocationOld;
  String? _selectedDropdownStatusOld;
  String? _selectedDropdownService;
  String? _selectedDropdownStatusNew;
  String? _selectedDropdownDislocationNew;

  bool _isEditComplaint = false;
  bool _isEditWorksPerformed = false;
  bool _isEditDiagnosisService = false;
  bool _isEditRecommendationsNotes = false;
  bool _isEdit = false;
  bool _isEditNewStatusDislocation = false;
  int indexTechnic = 0;
  bool isTechnicFind = false;

  late Repair oldRepairForHistory;

  @override
  void initState() {
    super.initState();
    oldRepairForHistory = Repair(
        widget.repair.id,
        widget.repair.internalID,
        widget.repair.category,
        widget.repair.dislocationOld,
        widget.repair.status,
        widget.repair.complaint,
        widget.repair.dateDeparture,
        widget.repair.serviceDislocation,
        widget.repair.dateTransferInService,
        widget.repair.dateDepartureFromService,
        widget.repair.worksPerformed,
        widget.repair.costService,
        widget.repair.diagnosisService,
        widget.repair.recommendationsNotes,
        widget.repair.newStatus,
        widget.repair.newDislocation,
        widget.repair.dateReceipt,
        widget.repair.idTestDrive);

    for(int i = 0; i < Technic.technicList.length; i++){
      if(Technic.technicList[i].internalID == widget.repair.internalID){
        indexTechnic = i;
        isTechnicFind = true;
        break;
      }
    }
    _innerNumberTechnic = '${widget.repair.internalID}';
    _nameTechnic = widget.repair.category;
    _selectedDropdownStatusOld = widget.repair.status == '' ? null : widget.repair.status;
    _selectedDropdownDislocationOld = widget.repair.dislocationOld == '' ? null : widget.repair.dislocationOld;
    _complaintController.text = widget.repair.complaint;
    _dateDeparture = widget.repair.dateDeparture;
    _selectedDropdownService = widget.repair.serviceDislocation == '' ? null : widget.repair.serviceDislocation;
    _dateTransferInService = widget.repair.dateTransferInService;
    _dateDepartureFromService = widget.repair.dateDepartureFromService;
    _worksPerformed.text = widget.repair.worksPerformed;
    if(_worksPerformed.text == '') _isEditWorksPerformed = true;
    _costService.text = widget.repair.costService == 0 ? '' : '${widget.repair.costService}';
    _diagnosisService.text = widget.repair.diagnosisService;
    if(_diagnosisService.text == '') _isEditDiagnosisService = true;
    _recommendationsNotes.text = widget.repair.recommendationsNotes;
    if(_recommendationsNotes.text == '') _isEditRecommendationsNotes = true;
    _selectedDropdownStatusNew = widget.repair.newStatus == '' ? null : widget.repair.newStatus;

    int lastSymbolNameRepair = widget.repair.newDislocation.length;
    _selectedDropdownDislocationNew = widget.repair.newDislocation == '' ? null :
    '${widget.repair.newDislocation[0].toUpperCase()}${widget.repair.newDislocation.substring(1, lastSymbolNameRepair).trim()}';

    _dateReceipt = widget.repair.dateReceipt;
  }

  @override
  void dispose() {
    _complaintController.dispose();
    _worksPerformed.dispose();
    _costService.dispose();
    _diagnosisService.dispose();
    _recommendationsNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorAppBar colorAppBar = ColorAppBar();
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: colorAppBar.color(),
          title: const Text('Внесение изменений в ремонт'),
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
                        if(_complaintController.text == "" ||
                            _dateDeparture == "" ||
                            _selectedDropdownService == null){
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
                          if(isValidationNewStatusDislocation()){
                            Future<Repair> repair = _save();
                            Navigator.pop(context, repair);

                            if(_isEdit){
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
                          }
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
                _buildDataTechnick(),
                _buildComplait(),
                _buildDateDeparture(),
                _buildDislocationService(),
                _buildDateTransferInService(),
                _buildDateDepartureFromService(),
                _buildWorksPerformed(),
                _buildCostService(),
                _buildDiagnosisService(),
                _buildRecommendationsNotes(),
                _buildStatusNew(),
                _buildDislocationNew(),
                _buildDateReceipt()
              ]
          )
        )
    );
  }

  ListTile _buildInternalID() {
  return ListTile (
    leading: const Icon(Icons.fiber_new),
    title: widget.repair.internalID != -1 && isTechnicFind ?
      TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.only(left: 0.0),
          alignment: Alignment.centerLeft,
          textStyle: const TextStyle(fontSize: 20)
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.technicList[indexTechnic]))).
          then((value){
                setState(() {
                  if(value != null) {
                    Technic.technicList[indexTechnic] = value;
                  }
                });
              });
          },
        child: Text('№ - $_innerNumberTechnic'))
        :
        widget.repair.internalID == -1 ? const Text('БН') : Text('№ - $_innerNumberTechnic'),
    );
  }

  ListTile _buildDataTechnick() {
    String technicDislocationOld = 'Данные отсутствуют.';
    if(_selectedDropdownDislocationOld != '' && _selectedDropdownDislocationOld != null){
      technicDislocationOld = '$_selectedDropdownDislocationOld.';
    }
    return ListTile(
      leading: const Icon(Icons.dataset_linked_rounded),
      title: Text.rich(TextSpan(children: [
        const TextSpan(text: 'Наименование: ', style: TextStyle(fontStyle: FontStyle.italic)),
        TextSpan(text: '$_nameTechnic\n', style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: 'Откуда забрали: ', style: TextStyle(fontStyle: FontStyle.italic)),
        TextSpan(text: technicDislocationOld, style: const TextStyle(fontWeight: FontWeight.bold))
      ]))
  );
  }

  ListTile _buildComplait() {
    return _isEditComplaint ?
    ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Жалоба"),
        controller: _complaintController,
      ),
    ) :
    ListTile(
      leading: const Icon(Icons.comment),
      title: Text(_complaintController.text),
      subtitle: const Text('Жалоба'),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: (){
            setState(() {
              _isEditComplaint = true;
              _isEdit = true;
            }
          );
        },
      ),
    );
  }

  ListTile _buildDateDeparture() {
    String dateDeparture = 'Отсутствует.';
    if(_dateDeparture != ''){
      dateDeparture = DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(
          _dateDeparture.replaceAll('.', '-')));
    }
    return ListTile(
      leading: const Icon(Icons.today),
      title: Text(dateDeparture),
      subtitle: const Text("Забрали с точки. Дата"),
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
                      _dateDeparture = DateFormat('yyyy.MM.dd').format(date);
                      _isEdit = true;
                    }
                  });
                });
              },
              color: Colors.blue
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  _dateDeparture = '';
                  _isEdit = true;
                });
              },
              icon: const Icon(Icons.clear))
        ],
      ),
    );
  }

  ListTile _buildDislocationService() {
    return ListTile(
      leading: const Icon(Icons.miscellaneous_services),
        subtitle: _selectedDropdownService != null ? const Text('Местонахождение техники') : null,
        title: DropdownButton<String>(
          borderRadius: BorderRadius.circular(10.0),
          isExpanded: true,
          hint: const Text('Местонахождение техники'),
          icon: _selectedDropdownService != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _selectedDropdownService = null;
              });}) : null,
          value: _selectedDropdownService,
          items: CategoryDropDownValueModel.service.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value){
            setState(() {
              _selectedDropdownService = value;
              _isEdit = true;
            });
          },
        )
    );
  }

  ListTile _buildDateTransferInService() {
    return ListTile(
      leading: const Icon(Icons.today),
      title: Text(_dateTransferInService == '' ? 'Выберите дату' : DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateTransferInService.replaceAll('.', '-')))),
      subtitle: const Text("Дата сдачи в ремонт"),
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
                      _dateTransferInService = DateFormat('yyyy.MM.dd').format(date);
                      _isEdit = true;
                    }
                  });
                });
              },
              color: Colors.blue
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  _dateTransferInService = '';
                  _isEdit = true;
                });
              },
              icon: const Icon(Icons.clear))
        ],
      ),
    );
  }

  ListTile _buildDateDepartureFromService() {
    return ListTile(
      leading: const Icon(Icons.today),
      title: Text(_dateDepartureFromService == '' ? 'Выберите дату' : DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateDepartureFromService.replaceAll('.', '-')))),
      subtitle: const Text("Забрали из ремонта. Дата"),
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
                      _dateDepartureFromService = DateFormat('yyyy.MM.dd').format(date);
                      _isEdit = true;
                    }
                  });
                });
              },
              color: Colors.blue
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  _dateDepartureFromService = '';
                  _isEdit = true;
                });
              },
              icon: const Icon(Icons.clear))
        ],
      ),
    );
  }

  ListTile _buildWorksPerformed() {
    return _isEditWorksPerformed ?
      ListTile(
        leading: const Icon(Icons.create),
        title: TextFormField(
          decoration: const InputDecoration(hintText: "Произведенные работы"),
          controller: _worksPerformed,
        ),
      ) :
      ListTile(
        leading: const Icon(Icons.comment),
        title: Text(_worksPerformed.text),
        subtitle: const Text('Произведенные работы'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: (){
            setState(() {
              _isEditWorksPerformed = true;
              _isEdit = true;
            });
          },
        ),
      );
  }

  ListTile _buildCostService() {
    return ListTile(
      leading: const Icon(Icons.shopify),
      subtitle: _costService.text != '' ? const Text('Стоимость ремонта') : null,
      title: TextFormField(
        decoration: const InputDecoration(
            hintText: 'Стоимость ремонта',
            prefix: Text('₽ ')),
        controller: _costService,
        onChanged: (value){
          setState(() {
            _isEdit = true;
          });
        },
        inputFormatters: [IntegerCurrencyInputFormatter()],
        keyboardType: TextInputType.number,
      )
    );
  }

  ListTile _buildDiagnosisService() {
    return _isEditDiagnosisService ?
      ListTile(
        leading: const Icon(Icons.create),
        title: TextFormField(
          decoration: const InputDecoration(hintText: 'Диагноз мастерской'),
          controller: _diagnosisService,
        ),
      ) :
      ListTile(
        leading: const Icon(Icons.comment),
        title: Text(_diagnosisService.text),
        subtitle: const Text('Диагноз мастерской'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: (){
            setState(() {
              _isEditDiagnosisService = true;
              _isEdit = true;
            });
          },
        ),
      );
  }

  ListTile _buildRecommendationsNotes() {
    return _isEditRecommendationsNotes ?
    ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: 'Рекомендации/примечания'),
        controller: _recommendationsNotes,
      ),
    ) :
    ListTile(
      leading: const Icon(Icons.comment),
      title: Text(_recommendationsNotes.text),
      subtitle: const Text('Рекомендации/примечания'),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: (){
          setState(() {
            _isEditRecommendationsNotes = true;
            _isEdit = true;
          });
        },
      ),
    );
  }

  ListTile _buildStatusNew() {
    return ListTile(
      leading: const Icon(Icons.copyright),
      subtitle: _selectedDropdownStatusNew != null ? const Text('Новый статус') : null,
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        isExpanded: true,
        hint: const Text('Новый статус'),
        icon: _selectedDropdownStatusNew != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _selectedDropdownStatusNew = null;
              });}) : null,
        value: _selectedDropdownStatusNew,
        items: CategoryDropDownValueModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value){
          setState(() {
            _selectedDropdownStatusNew = value;
            _isEdit = true;
            _isEditNewStatusDislocation = true;
          });
        },
      ),
    );
  }

  ListTile _buildDislocationNew() {
    return ListTile(
      leading: const Icon(Icons.local_shipping),
      subtitle: _selectedDropdownDislocationNew != null ? const Text('Куда уехал') : null,
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        isExpanded: true,
        hint: const Text('Куда уехал'),
        icon: _selectedDropdownDislocationNew != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _selectedDropdownDislocationNew = null;
              });
            }) : null,
        value: _selectedDropdownDislocationNew,
        items: CategoryDropDownValueModel.photosalons.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value){
          setState(() {
            _selectedDropdownDislocationNew = value;
            _isEdit = true;
            _isEditNewStatusDislocation = true;
          });
        },
      ),
    );
  }

  ListTile _buildDateReceipt() {
    return ListTile(
      leading: const Icon(Icons.today),
      title: Text(_dateReceipt == '' ? 'Выберите дату' : DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.parse(_dateReceipt.replaceAll('.', '-')))),
      subtitle: const Text("Дата поступления"),
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
                      _dateReceipt = DateFormat('yyyy.MM.dd').format(date);
                      _isEdit = true;
                    }
                  });
                });
              },
              color: Colors.blue
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  _dateReceipt = '';
                  _isEdit = true;
                });
              },
              icon: const Icon(Icons.clear))
        ],
      ),
    );
  }

  Future<Repair> _save() async{
    int costServ = 0;
    _costService.text != "" ? costServ = int.parse(_costService.text.replaceAll(",", "")) : costServ = 0;
    _selectedDropdownStatusNew = _selectedDropdownStatusNew ?? '';
    _selectedDropdownDislocationNew = _selectedDropdownDislocationNew ?? '';
    _selectedDropdownDislocationOld = _selectedDropdownDislocationOld ?? '';
    _selectedDropdownStatusOld = _selectedDropdownStatusOld ?? '';

    Repair repair = Repair(
        widget.repair.id,
        widget.repair.internalID,
        _nameTechnic,
        _selectedDropdownDislocationOld!,
        _selectedDropdownStatusOld!,
        _complaintController.text,
        _dateDeparture,
        _selectedDropdownService!,
        _dateTransferInService,
        _dateDepartureFromService,
        _worksPerformed.text,
        costServ,
        _diagnosisService.text,
        _recommendationsNotes.text,
        _selectedDropdownStatusNew!,
        _selectedDropdownDislocationNew!,
        _dateReceipt,
        0
    );

    await ConnectToDBMySQL.connDB.connDatabase();
    if(_isEdit) {
      ConnectToDBMySQL.connDB.updateRepairInDB(repair);
      RepairSQFlite.db.update(repair);

      if(widget.repair.internalID != -1 && _isEditNewStatusDislocation){
        repair.dateReceipt = DateFormat('yyyy.MM.dd').format(DateTime.now());
        ConnectToDBMySQL.connDB.insertStatusInDB(Technic.technicList[indexTechnic].id!, repair.newStatus, repair.newDislocation);
        TechnicSQFlite.db.updateStatusDislocationTechnic(Technic.technicList[indexTechnic].id, repair.newStatus, repair.newDislocation);
        Technic.technicList[indexTechnic].status = repair.newStatus;
        Technic.technicList[indexTechnic].dislocation = repair.newDislocation;
      }
      addHistory(repair);
    }
    return repair;
  }

  bool isValidationNewStatusDislocation(){
    bool result = true;

    if(_selectedDropdownStatusNew != null && _selectedDropdownDislocationNew == null){
      result = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.add_task, size: 40, color: Colors.white),
              Text(' Заполните поле "Куда уехал"'),
            ],
          ),
          duration: Duration(seconds: 5),
          showCloseIcon: true,
        ),
      );
    }
    if(_selectedDropdownStatusNew == null && _selectedDropdownDislocationNew != null){
      result = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.add_task, size: 40, color: Colors.white),
              Text(' Заполните поле "Новый статус"'),
            ],
          ),
          duration: Duration(seconds: 5),
          showCloseIcon: true,
        ),
      );
    }
    return result;
  }

  Future addHistory(Repair repair) async{
    String descForHistory = descriptionForHistory(oldRepairForHistory, repair);
    History historyForSQL = History(
        History.historyList.last.id + 1,
        'Repair',
        repair.id!,
        'edit',
        descForHistory,
        LoginPassword.login,
        DateFormat('yyyy.MM.dd').format(DateTime.now())
    );

    ConnectToDBMySQL.connDB.insertHistory(historyForSQL);
    HistorySQFlite.db.insertHistory(historyForSQL);
    History.historyList.insert(0, historyForSQL);
  }

  String descriptionForHistory(Repair repairOld, Repair repairNew){
    String internalID = repairOld.internalID == -1 ? 'БН' : '№${repairOld.internalID}';
    String result = 'Заявка на ремонт $internalID изменена:';

    if(repairOld.complaint != repairNew.complaint){
      result = '$result\n Жалоба изменена:\n'
          '  Было: ${repairOld.complaint}\n'
          '  Стало: ${repairNew.complaint}';
    }
    if(repairOld.dateDeparture != repairNew.dateDeparture){
      result = '$result\n Дата вывоза с точки изменена:\n'
          '  Было: ${getDateFormat(repairOld.dateDeparture)}\n'
          '  Стало: ${getDateFormat(repairNew.dateDeparture)}';
    }
    if(repairOld.serviceDislocation != repairNew.serviceDislocation){
      result = '$result\n Местонахождение техники изменено:\n'
          '  Было: ${repairOld.serviceDislocation}\n'
          '  Стало: ${repairNew.serviceDislocation}';
    }
    if(repairOld.dateTransferInService != repairNew.dateTransferInService){
      if(repairOld.dateTransferInService == ''){
        result = '$result\n Внесена дата сдачи в ремонт: '
            '${getDateFormat(repairNew.dateTransferInService)}';
      }else {
        result = '$result\n Дата сдачи в ремонт изменена:\n'
            '  Было: ${getDateFormat(repairOld.dateTransferInService)}\n'
            '  Стало: ${getDateFormat(repairNew.dateTransferInService)}';
      }
    }
    if(repairOld.dateDepartureFromService != repairNew.dateDepartureFromService){
      if(repairOld.dateDepartureFromService == ''){
        result = '$result\n Внесена дата вывоза из ремонта: '
            '${getDateFormat(repairNew.dateDepartureFromService)}';
      }else {
      result = '$result\n Дата вывоза из ремонта изменена:\n'
          '  Было: ${getDateFormat(repairOld.dateDepartureFromService)}\n'
          '  Стало: ${getDateFormat(repairNew.dateDepartureFromService)}';
      }
    }
    if(repairOld.worksPerformed != repairNew.worksPerformed){
      if(repairOld.worksPerformed == ''){
        result = '$result\n Внесены выполненые работы: '
            '${repairNew.worksPerformed}';
      }else {
      result = '$result\n Выполненые работы изменены:\n'
          '  Было: ${repairOld.worksPerformed}\n'
          '  Стало: ${repairNew.worksPerformed}';
      }
    }
    if(repairOld.costService != repairNew.costService){
      if(repairOld.costService == 0){
        result = '$result\n Внесена стоимость ремонта: '
            '${repairNew.costService == 0 ? 0 : repairNew.costService} р.';
      }else {
      result = '$result\n Стоимость ремонта изменена:\n'
          '  Было: ${repairOld.costService == 0 ? 0 : repairOld.costService} р.\n'
          '  Стало: ${repairNew.costService == 0 ? 0 : repairNew.costService} р.';
      }
    }
    if(repairOld.diagnosisService != repairNew.diagnosisService){
      if(repairOld.diagnosisService == ''){
        result = '$result\n Внесен диагноз мастерской: '
            '${repairNew.diagnosisService}';
      }else {
      result = '$result\n Диагноз мастерской изменен:\n'
          '  Было: ${repairOld.diagnosisService}\n'
          '  Стало: ${repairNew.diagnosisService}';
      }
    }
    if(repairOld.recommendationsNotes != repairNew.recommendationsNotes){
      if(repairOld.recommendationsNotes == ''){
        result = '$result\n Внесены рекомендации: '
            '${repairNew.recommendationsNotes}';
      }else {
      result = '$result\n Рекомендации изменены:\n'
          '  Было: ${repairOld.recommendationsNotes}\n'
          '  Стало: ${repairNew.recommendationsNotes}';
      }
    }
    if(repairOld.newStatus != repairNew.newStatus){
      if(repairOld.newStatus == ''){
        result = '$result\n Внесен новый статус: '
            '${repairNew.newStatus}';
      }else {
      result = '$result\n Новый статус изменен:\n'
          '  Было: ${repairOld.newStatus}\n'
          '  Стало: ${repairNew.newStatus}';
      }
    }
    if(repairOld.newDislocation != repairNew.newDislocation){
      if(repairOld.newDislocation == ''){
        result = '$result\n Внесено новое местоположение техники: '
            '${repairNew.newDislocation}';
      }else {
      result = '$result\n Новое местоположение техники изменено:\n'
          '  Было: ${repairOld.newDislocation}\n'
          '  Стало: ${repairNew.newDislocation}';
      }
    }
    if(repairOld.dateReceipt != repairNew.dateReceipt){
      if(repairOld.dateReceipt == ''){
        result = '$result\n Внесена дата поступления на точку: '
            '${getDateFormat(repairNew.dateReceipt)}';
      }else {
        result = '$result\n Дата поступления на точку изменена:\n'
            '  Было: ${getDateFormat(repairOld.dateReceipt)}\n'
            '  Стало: ${getDateFormat(repairNew.dateReceipt)}';
      }
    }
    return result;
  }

  String getDateFormat(String date) {
    if(date == '') return '';
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
