import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/api/data/models/technic.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../technics/presentation/page/technic_view.dart';
import '../../models/repair.dart';

class FirstStepRepairDesc extends StatefulWidget {
  const FirstStepRepairDesc({super.key, required this.repair});

  final Repair repair;

  @override
  State<FirstStepRepairDesc> createState() => _FirstStepRepairDescState();
}

class _FirstStepRepairDescState extends State<FirstStepRepairDesc> {
  final _innerNumberTechnic = TextEditingController();
  final _nameTechnicController = TextEditingController();
  final _complaint = TextEditingController();
  DateTime? _dateDeparture;
  String? _selectedDropdownDislocationOld;
  String? _selectedDropdownStatusOld;
  final _whoTook = TextEditingController();

  @override
  void initState() {
    super.initState();
    _innerNumberTechnic.text = widget.repair.numberTechnic.toString();
    _nameTechnicController.text = widget.repair.category;
    _complaint.text = widget.repair.complaint;
    _whoTook.text = widget.repair.whoTook;
    _dateDeparture = widget.repair.dateDeparture;
  }

  @override
  void dispose() {
    _innerNumberTechnic.dispose();
    _nameTechnicController.dispose();
    _complaint.dispose();
    _whoTook.dispose();
    super.dispose();
  }

  String? validateDropdownDislocationOld(ProviderModel providerModel){
    List<String> nameDislocation = providerModel.namesDislocation;
    for (var element in nameDislocation) {
      if(widget.repair.dislocationOld != ''){
        if(element == widget.repair.dislocationOld){
          return widget.repair.dislocationOld;
        }
      }
    }
    return null;
  }

  String? validateDropdownStatus(ProviderModel providerModel){
    List<String> nameStatus = providerModel.statusForEquipment;
    for (var element in nameStatus) {
      if(widget.repair.status != ''){
        if(element == widget.repair.status){
          return widget.repair.status;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return ExpansionTile(
      trailing: GestureDetector(
        onTap: () {
          _nameTechnicController.text = widget.repair.category;
          _complaint.text = widget.repair.complaint;
          _dateDeparture = widget.repair.dateDeparture;
          _selectedDropdownDislocationOld = validateDropdownDislocationOld(providerModel);
          _selectedDropdownStatusOld = validateDropdownStatus(providerModel);
          _whoTook.text = widget.repair.whoTook;
          showDialog(
              context: context,
              builder: (_) {
                return StatefulBuilder(
                  builder: (context, setState){
                    return AlertDialog(
                      actions: [
                        Center(
                            child: ElevatedButton(
                                onPressed: () {
                                    Repair repair = Repair(
                                      widget.repair.numberTechnic,
                                      _nameTechnicController.text,
                                      _selectedDropdownDislocationOld ?? '',
                                      _selectedDropdownStatusOld ?? '',
                                      _complaint.text = widget.repair.complaint,
                                      _dateDeparture ?? DateTime.now(),
                                      widget.repair.whoTook,
                                    );
                                    repair.id = widget.repair.id;

                                    _save(repair, providerModel).then((value) {
                                      _viewSnackBar(Icons.save, value, 'Заявка изменена', 'Заявка не изменена', true);
                                    });
                                    Navigator.pop(context);
                                },
                                child: Text('Сохранить')))
                      ],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      title: Text('Редактировать заявку'),
                      titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 20,
                          children: [
                            TextFormField(
                              decoration: myDecorationTextFormField('Наименование техники', 'Наименование техники'),
                              controller: _nameTechnicController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Обязательное поле';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: myDecorationTextFormField('Жалоба', 'Жалоба'),
                              controller: _complaint,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Обязательное поле';
                                }
                                return null;
                              },
                              maxLines: _complaint.text.length > 120 ? 4 : 3,
                            ),
                            TextFormField(
                              decoration: myDecorationTextFormField('Кто забрал', 'Кто забрал'),
                              controller: _whoTook,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Обязательное поле';
                                }
                                return null;
                              },
                            ),
                            GestureDetector(
                              onTap: (){
                                showDatePicker(
                                    context: context,
                                    initialDate: _dateDeparture,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2099),
                                    locale: const Locale("ru", "RU"))
                                    .then((date) {
                                  if (date != null) {
                                    setState(() {
                                      _dateDeparture = date;
                                    });
                                  }
                                });
                              },
                              child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12, bottom: 12, left: 10, right: 0),
                                            child: Text(DateFormat('d MMMM yyyy', 'ru_RU').format(_dateDeparture ?? DateTime.now())),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                        left: 11,
                                        top: -6.5,
                                        child: Text(
                                          'Когда увезли',
                                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black.withValues(alpha: 0.6)),
                                        )),
                                  ]),
                            ),
                            DropdownButtonFormField<String>(
                              decoration: myDecorationDropdown('Откуда увезли'),
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
                            ),
                            DropdownButtonFormField<String>(
                              decoration: myDecorationDropdown('Статус'),
                              validator: (value) => value == null ? "Обязательное поле" : null,
                              dropdownColor: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10.0),
                              hint: const Text('Статус'),
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
                          ],
                        ),
                      ),
                    );
                  },
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
      children: <Widget>[ListTile(title: _buildTextSubtitle())],
    );
  }

  Widget _buildTextTitle() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            TechnicalSupportRepoImpl.downloadData.getTechnic(widget.repair.numberTechnic.toString()).then((technic) {
              if (technic != null) {
                _navigationOnTehcnicView(technic);
              }else{
                _viewSnackBar(Icons.print, false, '', 'Такой техники нет в базе', false);
              }
            });
          },
          child: CircleAvatar(
            radius: widget.repair.numberTechnic.toString().length > 4 ? 27 : null,
            child: Text(
              widget.repair.numberTechnic.toString(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          widget.repair.category,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _navigationOnTehcnicView(Technic technic) {
    Navigator.push(
        context, animationRouteSlideTransition(TechnicView(location: technic.dislocation, technic: technic)));
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
        Row(
          children: [
            Text(widget.repair.dislocationOld != '' ? widget.repair.dislocationOld : 'Неизвестно откуда забрали'),
            SizedBox(
              width: 7,
            ),
            Icon(
              Icons.delivery_dining,
              color: Colors.green.shade700,
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.green.shade700,
            ),
            SizedBox(
              width: 5,
            ),
            widget.repair.whoTook != '' ? Text(widget.repair.whoTook) : Icon(Icons.person_off),
          ],
        ),
        Row(children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '\n \n', style: TextStyle(fontSize: 2)),
              TextSpan(text: 'Статус: '),
              TextSpan(text: widget.repair.status != '' ? widget.repair.status : 'Отсутствует'),
            ])),
          ),
          SizedBox(
            width: 8,
          ),
          Icon(Icons.calendar_month),
          SizedBox(
            width: 4,
          ),
          Text(widget.repair.dateDeparture.toString() != '-0001-11-30 00:00:00.000Z'
              ? DateFormat('d MMMM yyyy', 'ru_RU').format(widget.repair.dateDeparture)
              : 'Дата отсутствует')
        ])
      ],
    );
  }

  Future<bool> _save(Repair repair, ProviderModel provider) async {
    bool isResult = await TechnicalSupportRepoImpl.downloadData.updateRepair(repair, true);
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
