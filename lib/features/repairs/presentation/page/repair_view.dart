import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';

import '../../../../core/api/data/models/technic.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../technics/presentation/page/technic_view.dart';
import '../../models/repair.dart';

class RepairView extends StatefulWidget {
  const RepairView({super.key, required this.repair});

  final Repair repair;

  @override
  State<RepairView> createState() => _RepairViewState();
}

class _RepairViewState extends State<RepairView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _innerNumberTechnic = TextEditingController();
  final _nameTechnicController = TextEditingController();
  final _lastDislocationController = TextEditingController();
  String? _selectedDropdownDislocationOld;
  String? _selectedDropdownStatusOld;
  final _complaint = TextEditingController();
  DateTime? _dateDeparture;
  DateTime? _dateTransferInService;
  DateTime? _dateDepartureFromService;
  final _worksPerformed = TextEditingController();
  final _costService = TextEditingController();
  final _diagnosisService = TextEditingController();
  final _recommendationsNotes = TextEditingController();
  DateTime? _dateReceipt;

  String? _selectedDropdownService;
  String? _selectedDropdownWhoTook;
  String? _selectedDropdownStatusNew;
  String? _selectedDropdownDislocationNew;
  bool isBN = false;
  bool isExistNumber = false;

  Technic? technicFind;

  @override
  void initState() {
    super.initState();
    _innerNumberTechnic.text = widget.repair.numberTechnic.toString();
    _nameTechnicController.text = widget.repair.category;
    _lastDislocationController.text = widget.repair.dislocationOld;
    _selectedDropdownStatusOld = widget.repair.status != '' ? widget.repair.status : null;
    _complaint.text = widget.repair.complaint;
    _dateDeparture = widget.repair.dateDeparture;
    _selectedDropdownWhoTook = widget.repair.whoTook != '' ? widget.repair.whoTook : null;
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
        appBar: CustomAppBar(typePage: TypePage.viewRepair, location: widget.repair, technic: null),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 10),
              _headerData(),
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
                        if (_formKey.currentState!.validate()) {
                          Repair repair = Repair(
                              !isBN ? int.parse(_innerNumberTechnic.text) : 0,
                              _nameTechnicController.text,
                              _lastDislocationController.text,
                              _selectedDropdownStatusOld ?? '',
                              _complaint.text,
                              _dateDeparture ?? DateTime.now(),
                              providerModel.user.name);

                          _save(repair, providerModel).then((_) {
                            _viewSnackBar(Icons.save, true, 'Заявка создана', 'Заявка не создана');
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

  Column _headerData(ProviderModel provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(
            decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10),  boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 4,
                offset: Offset(2, 4), // Shadow position
              ),
            ]),
            child: ExpansionTile(
              trailing: GestureDetector(
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          actions: [
                            Center(
                                child: ElevatedButton(
                                    onPressed: () {
                                      // TechnicalSupportRepoImpl.downloadData.getTechnic(widget.repair.numberTechnic.toString()).then((technicResult){
                                      //   if(technicResult != null){
                                      //     Technic technic = technicResult;
                                      //     technic.name = _nameTechnic.text;
                                      //     provider.updateTechnicInProvider(widget.location, technic);
                                      //     TechnicalSupportRepoImpl.downloadData.updateTechnic(technic).then((value) {
                                      //       _viewSnackBar(value ? Icons.print : Icons.print_disabled, value,
                                      //           value ? 'Изменения приняты' : 'Изменения не сохранились');
                                      //     });
                                      //     Navigator.of(context).pop();
                                      //   }
                                      // });
                                    },
                                    child: Text('Сохранить')))
                          ],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          title: Text('Редактировать'),
                          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                          content: Column(
                            children: [
                              TextFormField(
                                decoration: myDecorationTextFormField(null, 'Наименование техники'),
                                controller: _nameTechnic..text = widget.technic.name,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Обязательное поле';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        );
                      });
                },
                child: Icon(Icons.edit),
              ),
              tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              collapsedBackgroundColor: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: Colors.blue[100],
              title: _buildTextTitle(),
              children: <Widget>[
                ListTile(
                    title: _buildTextSubtitle()
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextTitle() {
    return Row(children: [
      GestureDetector(
        onTap: () {
          TechnicalSupportRepoImpl.downloadData.getTechnic(widget.repair.numberTechnic.toString()).then((technic){
            if(technic != null){
              _navigationOnTehcnicView(technic);
            }
          });
        },
        child: CircleAvatar(
          radius: widget.repair.numberTechnic.toString().length > 4 ? 27 : null,
          child: Text(widget.repair.numberTechnic.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
      SizedBox(width: 10,),
      Text(widget.repair.category, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
    ],);
  }

  void _navigationOnTehcnicView(Technic technic){
    Navigator.push(context,
        animationRouteSlideTransition(TechnicView(location: technic.dislocation, technic: technic)));
  }

  Widget _buildTextSubtitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          TextSpan(text: 'Жалоба: ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: widget.repair.complaint != '' ? widget.repair.complaint : 'Данные отсутствуют'),
          TextSpan(text: '\n \n', style: TextStyle(fontSize: 2)),
        ])),
        Row(children: [
          Text(widget.repair.dislocationOld != '' ? widget.repair.dislocationOld : 'Неизвестно откуда забрали'),
          SizedBox(width: 7,),
          Icon(Icons.delivery_dining, color: Colors.green.shade700,),
          Icon(Icons.arrow_forward, color: Colors.green.shade700,),
          SizedBox(width: 5,),
          widget.repair.whoTook != '' ? Text(widget.repair.whoTook) : Icon(Icons.person_off),
        ],),
        Row(children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '\n \n', style: TextStyle(fontSize: 2)),
              TextSpan(text: 'Статус: '),
              TextSpan(text: widget.repair.status != '' ? widget.repair.status : 'Отсутствует'),
            ])),
          ),
          SizedBox(width: 8,),
          Icon(Icons.calendar_month),
          SizedBox(width: 4,),
          Text(widget.repair.dateDeparture.toString() != '-0001-11-30 00:00:00.000Z' ? DateFormat('d MMMM yyyy', 'ru_RU').format(widget.repair.dateDeparture) : 'Дата отсутствует')
        ])
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
                    _lastDislocationController.text = result.dislocation;
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
              controller: _lastDislocationController,
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
            padding: const EdgeInsets.only(left: 40, right: 40),
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

  // ListTile _buildServiceDislocationListTile(){
  //   return ListTile(
  //     leading: const Icon(Icons.miscellaneous_services),
  //     title: DropdownButton<String>(
  //       borderRadius: BorderRadius.circular(10.0),
  //       isExpanded: true,
  //       hint: const Text('Местонахождение техники'),
  //       icon: _selectedDropdownService != null ? IconButton(
  //           icon: const Icon(Icons.clear, color: Colors.grey),
  //           onPressed: (){
  //             setState(() {
  //               _selectedDropdownService = null;
  //             });}) : null,
  //       value: _selectedDropdownService,
  //       items: CategoryDropDownValueModel.service.map<DropdownMenuItem<String>>((String value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(value),
  //         );
  //       }).toList(),
  //       onChanged: (String? value){
  //         setState(() {
  //           _selectedDropdownService = value!;
  //         });
  //       },
  //     ),
  //   );
  // }

  // ListTile _buildDateTransferInServiceListTile(){
  //   return ListTile(
  //     leading: const Icon(Icons.today),
  //     title: const Text("Дата сдачи в ремонт"),
  //     subtitle: Text(_dateTransferInService == "" ? "Выберите дату" : _dateTransferInService),
  //     trailing: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         IconButton(
  //             icon: const Icon(Icons.edit),
  //             onPressed: () {
  //               showDatePicker(
  //                   context: context,
  //                   initialDate: DateTime.now(),
  //                   firstDate: DateTime(2000),
  //                   lastDate: DateTime(2099),
  //                   locale: const Locale("ru", "RU")
  //               ).then((date) {
  //                 setState(() {
  //                   if(date != null) {
  //                     _dateTransferInServiceForSQL = DateFormat('yyyy.MM.dd').format(date);
  //                     _dateTransferInService = DateFormat('d MMMM yyyy', "ru_RU").format(date);
  //                   }
  //                 });
  //               });
  //             },
  //             color: Colors.blue
  //         ),
  //         IconButton(
  //             onPressed: (){
  //               setState(() {
  //                 _dateTransferInServiceForSQL = '';
  //                 _dateTransferInService = '';
  //               });
  //             },
  //             icon: const Icon(Icons.clear))
  //       ],
  //     ),
  //   );
  // }

  // ListTile _buildDateDepartureFromServiceListTile(){
  //   return ListTile(
  //     leading: const Icon(Icons.today),
  //     title: const Text("Забрали из ремонта. Дата"),
  //     subtitle: Text(_dateDepartureFromService == "" ? "Выберите дату" : _dateDepartureFromService),
  //     trailing: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         IconButton(
  //             icon: const Icon(Icons.edit),
  //             onPressed: () {
  //               showDatePicker(
  //                   context: context,
  //                   initialDate: DateTime.now(),
  //                   firstDate: DateTime(2000),
  //                   lastDate: DateTime(2099),
  //                   locale: const Locale("ru", "RU")
  //               ).then((date) {
  //                 setState(() {
  //                   if(date != null) {
  //                     _dateDepartureFromServiceForSQL = DateFormat('yyyy.MM.dd').format(date);
  //                     _dateDepartureFromService = DateFormat('d MMMM yyyy', "ru_RU").format(date);
  //                   }
  //                 });
  //               });
  //             },
  //             color: Colors.blue
  //         ),
  //         IconButton(
  //             onPressed: (){
  //               setState(() {
  //                 _dateDepartureFromServiceForSQL = '';
  //                 _dateDepartureFromService = '';
  //               });
  //             },
  //             icon: const Icon(Icons.clear))
  //       ],
  //     ),
  //   );
  // }

  ListTile _buildWorksPerformedListTile() {
    return ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Произведенные работы"),
        controller: _worksPerformed,
      ),
    );
  }

  ListTile _buildCostServiceListTile() {
    return ListTile(
        leading: const Icon(Icons.shopify),
        title: TextFormField(
          decoration: const InputDecoration(hintText: "Стоимость ремонта", prefix: Text('₽ ')),
          controller: _costService,
          inputFormatters: [IntegerCurrencyInputFormatter()],
          keyboardType: TextInputType.number,
        ));
  }

  ListTile _buildDiagnosisServiceListTile() {
    return ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Диагноз мастерской"),
        controller: _diagnosisService,
      ),
    );
  }

  ListTile _buildRecommendationsNotesListTile() {
    return ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Рекомендации/примечания (необязательно)"),
        controller: _recommendationsNotes,
      ),
    );
  }

  // ListTile _buildNewStatusListTile(){
  //   return ListTile(
  //     leading: const Icon(Icons.copyright),
  //     title: DropdownButton<String>(
  //       borderRadius: BorderRadius.circular(10.0),
  //       isExpanded: true,
  //       hint: const Text('Новый статус'),
  //       icon: _selectedDropdownStatusNew != null ? IconButton(
  //           icon: const Icon(Icons.clear, color: Colors.grey),
  //           onPressed: (){
  //             setState(() {
  //               _selectedDropdownStatusNew = null;
  //             });}) : null,
  //       value: _selectedDropdownStatusNew,
  //       items: CategoryDropDownValueModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(value),
  //         );
  //       }).toList(),
  //       onChanged: (String? value){
  //         setState(() {
  //           _selectedDropdownStatusNew = value!;
  //         });
  //       },
  //     ),
  //   );
  // }

  // ListTile _buildNewDislocationListTile(){
  //   return ListTile(
  //     leading: const Icon(Icons.local_shipping),
  //     title: DropdownButton<String>(
  //       borderRadius: BorderRadius.circular(10.0),
  //       isExpanded: true,
  //       hint: const Text('Куда уехал'),
  //       icon: _selectedDropdownDislocationNew != null ? IconButton(
  //           icon: const Icon(Icons.clear, color: Colors.grey),
  //           onPressed: (){
  //             setState(() {
  //               _selectedDropdownDislocationNew = null;
  //             });}) : null,
  //       value: _selectedDropdownDislocationNew,
  //       items: CategoryDropDownValueModel.photosalons.map<DropdownMenuItem<String>>((String value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(value),
  //         );
  //       }).toList(),
  //       onChanged: (String? value){
  //         setState(() {
  //           _selectedDropdownDislocationNew = value!;
  //         });
  //       },
  //     ),
  //   );
  // }

  // ListTile _buildDateReceiptListTile(){
  //   return ListTile(
  //     leading: const Icon(Icons.today),
  //     title: const Text("Дата поступления"),
  //     subtitle: Text(_dateReceipt == "" ? "Выберите дату" : _dateReceipt),
  //     trailing: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         IconButton(
  //             icon: const Icon(Icons.edit),
  //             onPressed: () {
  //               showDatePicker(
  //                   context: context,
  //                   initialDate: DateTime.now(),
  //                   firstDate: DateTime(2000),
  //                   lastDate: DateTime(2099),
  //                   locale: const Locale("ru", "RU")
  //               ).then((date) {
  //                 setState(() {
  //                   if(date != null) {
  //                     _dateReceiptForSQL = DateFormat('yyyy.MM.dd').format(date);
  //                     _dateReceipt = DateFormat('d MMMM yyyy', "ru_RU").format(date);
  //                   }
  //                 });
  //               });
  //             },
  //             color: Colors.blue
  //         ),
  //         IconButton(
  //             onPressed: (){
  //               setState(() {
  //                 _dateReceiptForSQL = '';
  //                 _dateReceipt = '';
  //               });
  //             },
  //             icon: const Icon(Icons.clear))
  //       ],
  //     ),
  //   );
  // }

  Future<bool> _save(Repair repair, ProviderModel provider) async{
    int? id = await TechnicalSupportRepoImpl.downloadData.saveRepair(repair);
    if(id != null){
      repair.id = id;
      // await addHistory(technic, nameUser);
      provider.addRepairInRepairs(repair);
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

  void _viewSnackBar(IconData icon, bool isSuccessful, String successText, String notSuccessText) {
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
            Flexible(child: Text(isSuccessful ? successText : notSuccessText)),
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
