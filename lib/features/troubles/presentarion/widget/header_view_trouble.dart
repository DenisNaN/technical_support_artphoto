import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../../core/shared/is_fields_filled.dart';
import '../../../technics/models/technic.dart';
import '../../../technics/presentation/page/technic_view.dart';
import '../../models/trouble.dart';

class HeaderViewTrouble extends StatefulWidget {
  const HeaderViewTrouble({super.key, required this.trouble, required this.technic});

  final Trouble trouble;
  final Technic? technic;

  @override
  State<HeaderViewTrouble> createState() => _HeaderViewTroubleState();
}

class _HeaderViewTroubleState extends State<HeaderViewTrouble> {
  final _numberTechnic = TextEditingController();
  String? _selectedDropdownDislocation;
  DateTime? _dateTrouble;
  final _employee = TextEditingController();
  final _complaint = TextEditingController();

  @override
  void initState() {
    super.initState();
    _numberTechnic.text = widget.trouble.numberTechnic.toString();
    _selectedDropdownDislocation = widget.trouble.photosalon;
    _dateTrouble = widget.trouble.dateTrouble;
    _employee.text = widget.trouble.employee;
    _complaint.text = widget.trouble.trouble;
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          title: _buildTextTitle(widget.technic),
          subtitle: _buildTextSubtitle(),
          trailing: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return StatefulBuilder(
                      builder: (showDialogContext, setState) {
                        return AlertDialog(
                          actions: [
                            Center(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Trouble trouble = Trouble(
                                          id: widget.trouble.id,
                                          photosalon: _selectedDropdownDislocation!,
                                          dateTrouble: _dateTrouble!,
                                          employee: _employee.text,
                                          numberTechnic: int.parse(_numberTechnic.text),
                                          trouble: _complaint.text);
                                      trouble.dateFixTroubleEmployee =
                                          widget.trouble.dateFixTroubleEmployee;
                                      trouble.fixTroubleEmployee =
                                          widget.trouble.fixTroubleEmployee;
                                      trouble.dateFixTroubleEngineer =
                                          widget.trouble.dateFixTroubleEngineer;
                                      trouble.fixTroubleEngineer =
                                          widget.trouble.fixTroubleEngineer;
                                      trouble.photoTrouble = widget.trouble.photoTrouble;

                                      _save(trouble, providerModel).then((value) {
                                        _viewSnackBar(
                                            Icons.save,
                                            value,
                                            'Неисправность изменена',
                                            'Неисправность не изменена',
                                            true);
                                      });
                                    },
                                    child: Text('Сохранить')))
                          ],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10))),
                          title: Text('Редактировать неисправность'),
                          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 20,
                              children: [
                                TextFormField(
                                  decoration:
                                      myDecorationTextFormField('Жалоба', 'Жалоба'),
                                  controller: _complaint,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Обязательное поле';
                                    }
                                    return null;
                                  },
                                  maxLines: _complaint.text.length > 120 ? 4 : 3,
                                ),
                                DropdownButtonFormField<String>(
                                  decoration: myDecorationDropdown('Откуда увезли'),
                                  validator: (value) =>
                                      value == null ? "Обязательное поле" : null,
                                  borderRadius: BorderRadius.circular(10.0),
                                  hint: const Text('Последнее местонахождение'),
                                  value: _selectedDropdownDislocation,
                                  items: providerModel.namesDislocation
                                      .map<DropdownMenuItem<String>>((String value) {
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
                                TextFormField(
                                  decoration:
                                      myDecorationTextFormField('Сотрудник', 'Сотрудник'),
                                  controller: _employee,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Обязательное поле';
                                    }
                                    return null;
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: _dateTrouble,
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2099),
                                            locale: const Locale("ru", "RU"))
                                        .then((date) {
                                      if (date != null) {
                                        setState(() {
                                          _dateTrouble = date;
                                        });
                                      }
                                    });
                                  },
                                  child: Stack(clipBehavior: Clip.none, children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(12)),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12, bottom: 12, left: 10, right: 0),
                                            child: Text(DateFormat('d MMMM yyyy', 'ru_RU')
                                                .format(_dateTrouble ?? DateTime.now())),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                        left: 11,
                                        top: -6.5,
                                        child: Text(
                                          'Дата неисправности',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black.withValues(alpha: 0.6)),
                                        )),
                                  ]),
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
        ),
      ),
    );
  }

  Widget _buildTextTitle(Technic? technic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (technic != null) {
                TechnicalSupportRepoImpl.downloadData
                    .getTechnic(widget.trouble.numberTechnic.toString())
                    .then((technic) {
                  if (technic != null) {
                    _navigationOnTehcnicView(technic);
                  } else {
                    _viewSnackBar(
                        Icons.print, false, '', 'Такой техники нет в базе', false);
                  }
                });
              }
            },
            child: CircleAvatar(
              radius: widget.trouble.numberTechnic.toString().length > 4 ? 27 : null,
              child: Text(technic != null ?
                widget.trouble.numberTechnic.toString() : 'БН',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          technic != null ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                technic.category,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(technic.name)
            ],
          ) : Text('Техника без номера'),
        ],
      ),
    );
  }

  void _navigationOnTehcnicView(Technic technic) {
    Navigator.push(
        context,
        animationRouteSlideTransition(
            TechnicView(location: technic.dislocation, technic: technic)));
  }

  Widget _buildTextSubtitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          TextSpan(text: 'Жалоба: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          TextSpan(
              text: widget.trouble.trouble != ''
                  ? widget.trouble.trouble
                  : 'Данные отсутствуют',
          style: TextStyle(fontSize: 18)),
          TextSpan(text: '\n \n', style: TextStyle(fontSize: 2)),
        ])),
        Row(
          children: [
            Text(widget.trouble.photosalon != ''
                ? widget.trouble.photosalon
                : 'Неизвестно, где неисправность'),
            SizedBox(
              width: 7,
            ),
            Icon(
              Icons.message,
              color: Colors.green.shade700,
            ),
            SizedBox(
              width: 5,
            ),
            widget.trouble.employee != ''
                ? Text(widget.trouble.employee)
                : Icon(Icons.person_off),
          ],
        ),
        Row(children: [
          Icon(Icons.calendar_month),
          SizedBox(
            width: 4,
          ),
          Text(widget.trouble.dateTrouble.toString() != '-0001-11-30 00:00:00.000Z'
              ? DateFormat('d MMMM yyyy', 'ru_RU').format(widget.trouble.dateTrouble)
              : 'Дата отсутствует')
        ])
      ],
    );
  }

  Future<bool> _save(Trouble trouble, ProviderModel providerModel) async {
    final bool isFinishedTrouble = isFieldsFilledTrouble(trouble);
    List<Trouble>? resultData =
        await TechnicalSupportRepoImpl.downloadData.updateTrouble(trouble);
    if (resultData != null) {
      if (!isFinishedTrouble) {
        providerModel.refreshTroubles(resultData);
      }
      // await addHistory(technic, nameUser);
      return true;
    }
    return false;
  }

  void _viewSnackBar(IconData icon, bool isSuccessful, String successfulText,
      String notSuccessfulText, bool isSkipPrevSnackBar) {
    if (context.mounted) {
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
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}
