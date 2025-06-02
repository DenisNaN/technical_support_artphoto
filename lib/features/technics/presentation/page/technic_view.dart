import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/core/shared/input_decoration/input_deroration.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/repairs_technic_page.dart';
import '../../../../core/shared/technic_image/technic_image.dart';
import '../../../../main.dart';

class TechnicView extends StatefulWidget {
  const TechnicView({super.key, required this.location, required this.technic});

  final dynamic location;
  final Technic technic;

  @override
  State<TechnicView> createState() => _TechnicViewState();
}

class _TechnicViewState extends State<TechnicView> {
  final _innerNumberTechnic = TextEditingController();
  final _nameTechnic = TextEditingController();
  final _costTechnic = TextEditingController();
  final _comment = TextEditingController();
  final List<SummRepair> summsRepairs = [];
  late final int totalSumm;

  // late final String _dateStartTestDrive;
  // String _dateFinishTestDrive = '';
  final _resultTestDrive = TextEditingController();
  String? _selectedDropdownDislocation;
  String? _selectedDropdownStatus;
  bool isBN = false;

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
    TechnicalSupportRepoImpl.downloadData.getSumRepairs(widget.technic.number.toString()).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          summsRepairs.addAll(value.values.first);
          totalSumm = value.keys.first;
        });
      }
    });
    // _dateStartTestDrive = DateFormat('d MMMM yyyy', 'ru_RU').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    double widthScreen = MediaQuery.sizeOf(context).width;
    return Scaffold(
        appBar: CustomAppBar(typePage: TypePage.viewTechnic, location: widget.location, technic: widget.technic),
        body: Form(
            key: _formInnerNumberKey,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDateBuyTechnic(providerModel),
                _buildCardTechnic(widthScreen, providerModel),
                SizedBox(height: 20),
                _buildComment(providerModel, widget.technic.comment ?? ''),
                SizedBox(height: 10),
                _buildStatus(providerModel),
                SizedBox(height: 10),
                _buildDislocation(providerModel),
                SizedBox(height: 10),
                _buildCostAndTotalSumRepairs(providerModel),
                SizedBox(height: 30),
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
                                widget.technic.id,
                                widget.technic.number,
                                widget.technic.category,
                                widget.technic.name,
                                _selectedDropdownStatus ?? widget.technic.status,
                                _selectedDropdownDislocation ?? widget.technic.dislocation,
                                widget.technic.dateBuyTechnic,
                                widget.technic.cost,
                                widget.technic.comment);

                            _save(technic, providerModel).then((value){
                              _viewSnackBar(value ? Icons.save : Icons.dangerous_outlined, value,
                                  value ? 'Изменения приняты' : 'Изменения не сохранились');
                            });
                            Navigator.pushReplacement(
                                context, animationRouteSlideTransition(const ArtphotoTech()));
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

  Padding _buildCardTechnic(double widthScreen, ProviderModel provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  actions: [
                    Center(
                        child: ElevatedButton(
                            onPressed: () {
                              Technic technic = widget.technic;
                              technic.name = _nameTechnic.text;
                              provider.updateTechnicInProvider(widget.location, technic);
                              TechnicalSupportRepoImpl.downloadData.updateTechnic(technic).then((value) {
                                _viewSnackBar(value ? Icons.print : Icons.print_disabled, value,
                                    value ? 'Изменения приняты' : 'Изменения не сохранились');
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Сохранить')))
                  ],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  title: Text('Редактировать'),
                  titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                  content: TextFormField(
                    decoration: myDecorationTextFormField(null, 'Наименование техники'),
                    controller: _nameTechnic..text = widget.technic.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Обязательное поле';
                      }
                      return null;
                    },
                  ),
                );
              });
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.blue[100],
          elevation: 8.0,
          child: SizedBox(
            height: widthScreen / 3 + 16,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.technic.category),
                      Text(widget.technic.name, style: TextStyle(fontSize: 25)),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircleAvatar(
                        radius: widget.technic.number.toString().length > 4 ? 25 : null,
                        child: Text(widget.technic.number.toString()),
                      ),
                    )),
                Positioned(
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(height: widthScreen / 3, child: TechnicImage(category: widget.technic.category)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell _buildComment(ProviderModel provider, String comment) {
    bool isCommentEmpty = comment.isEmpty;
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                actions: [
                  Center(
                      child: ElevatedButton(
                          onPressed: () {
                            Technic technic = widget.technic;
                            technic.comment = _comment.text;
                            provider.updateTechnicInProvider(widget.location, technic);
                            TechnicalSupportRepoImpl.downloadData.updateTechnic(technic).then((value) {
                              _viewSnackBar(value ? Icons.comment : Icons.comments_disabled, value,
                                  value ? 'Изменения приняты' : 'Изменения не сохранились');
                            });
                            Navigator.of(context).pop();
                          },
                          child: Text('Сохранить')))
                ],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                title: Text('Редактировать'),
                titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                content: TextFormField(
                  maxLines: 4,
                  decoration: myDecorationTextFormField(null, 'Комментарий'),
                  controller: _comment..text = widget.technic.comment ?? '',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Обязательное поле';
                    }
                    return null;
                  },
                ),
              );
            });
      },
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  Text(
                    isCommentEmpty ? 'Добавить комментарий' : 'Комментарий',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  isCommentEmpty
                      ? Icon(
                          Icons.edit,
                          color: Colors.grey,
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
          !isCommentEmpty
              ? ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.blue.shade50),
                        child: Text(widget.technic.comment!)),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  InkWell _buildDateBuyTechnic(ProviderModel provider) {
    return InkWell(
      onTap: () {
        showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2099),
                locale: const Locale("ru", "RU"))
            .then((date) {
          if (date != null) {
            Technic technic = widget.technic;
            technic.dateBuyTechnic = date;
            provider.updateTechnicInProvider(widget.location, technic);
            TechnicalSupportRepoImpl.downloadData.updateTechnic(technic).then((value) {
              _viewSnackBar(value ? Icons.date_range : Icons.dangerous_outlined, value,
                  value ? 'Изменения приняты' : 'Изменения не сохранились');
            });
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Row(
          children: [
            Text(
              'Дата покупки техники: ${DateFormat('d MMMM yyyy', "ru_RU").format(widget.technic.dateBuyTechnic)}',
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.edit,
              color: Colors.grey,
            )
          ],
        ),
      ),
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
              value: _selectedDropdownStatus == null ? widget.technic.status : null,
              items: providerModel.statusForEquipment.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                  _selectedDropdownStatus = value!;
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
              'Местонахождение техники',
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
              value: _selectedDropdownDislocation == null ? widget.technic.dislocation : null,
              validator: (value) => value == null ? "Обязательное поле" : null,
              items: providerModel.namesDislocation.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                  _selectedDropdownDislocation = value!;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostAndTotalSumRepairs(ProviderModel provider) {
    bool isListEmpty = summsRepairs.isEmpty;
    return Column(
      children: [
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    actions: [
                      Center(
                          child: ElevatedButton(
                              onPressed: () {
                                Technic technic = widget.technic;
                                technic.cost = int.tryParse(_costTechnic.text) ?? 0;
                                provider.updateTechnicInProvider(widget.location, technic);
                                TechnicalSupportRepoImpl.downloadData.updateTechnic(technic).then((value) {
                                  _viewSnackBar(value ? Icons.attach_money : Icons.money_off, value,
                                      value ? 'Изменения приняты' : 'Изменения не сохранились');
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('Сохранить')))
                    ],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    title: Text('Редактировать'),
                    titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                    content: TextFormField(
                      decoration: myDecorationTextFormField(null, 'Стоимость техники'),
                      controller: _costTechnic..text = widget.technic.cost.toString(),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Обязательное поле';
                        }
                        return null;
                      },
                    ),
                  );
                });
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 5),
              child: Row(
                children: [
                  Text(
                    'Стоимость техники: ${NumberFormat('#,###', 'fr').format(widget.technic.cost)} р.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Icon(
                    Icons.edit,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ),
        ),
        isListEmpty
            ? SizedBox()
            : InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      animationRouteSlideTransition(RepairsTechnicPage(
                        summsRepairs: summsRepairs,
                        technic: widget.technic,
                      )));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.blue.shade50),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Количество ремонтов: ${summsRepairs.length}'),
                          Text('Cтоимость ремонтов: ${NumberFormat('#,###', 'fr').format(totalSumm)} р.')
                        ],
                      ),
                    ),
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

  Future<bool> _save(Technic technicModel, ProviderModel providerModel) async{
    bool isSuccess = false;
    isSuccess = await TechnicalSupportRepoImpl.downloadData.updateStatusAndDislocationTechnic(technicModel, providerModel.user.name);
    Map<String, dynamic> result = await TechnicalSupportRepoImpl.downloadData.refreshTechnicsData();
    providerModel.refreshTechnics(result['Photosalons'], result['Repairs'], result['Storages']);
    return isSuccess;
  }

  // Future addHistory(Technic technic, String nameUser) async {
  //   String descForHistory = descriptionForHistory(technic);
  //   History history = History(History.historyList.last.id + 1, 'Technic', technic.id, 'create', descForHistory,
  //       nameUser, DateFormat('yyyy.MM.dd').format(DateTime.now()));
  //
  //   ConnectDbMySQL.connDB.insertHistory(history);
  //   History.historyList.insert(0, history);
  // }
  //
  // String descriptionForHistory(Technic technic) {
  //   String internalID = technic.number == -1 ? 'БН' : '№${technic.number}';
  //   String result = 'Новая техника $internalID добавленна';
  //
  //   return result;
  // }

  // String getDateFormat(String date) {
  //   return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  // }

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

// String validateEmptyFields() {
//   String result = '';
//   String tmpResult = '';
//   int countEmptyFields = 0;
//
//   if (_innerNumberTechnic.text == "") {
//     tmpResult += 'Номер техники, ';
//     countEmptyFields++;
//   }
//   if (_selectedDropdownCategory == null) {
//     tmpResult += 'Наименование техники, ';
//     countEmptyFields++;
//   }
//   if (_costTechnic.text == "") {
//     tmpResult += 'Стоимость техники, ';
//     countEmptyFields++;
//   }
//   if (_dateBuyTechnic == "") {
//     tmpResult += 'Дата покупки техники, ';
//     countEmptyFields++;
//   }
//   if (_selectedDropdownStatus == null) {
//     tmpResult += 'Статус техники, ';
//     countEmptyFields++;
//   }
//   if (_selectedDropdownDislocation == null) {
//     tmpResult += 'Дислокация техники, ';
//     countEmptyFields++;
//   }
//   if (_switchTestDrive && _selectedDropdownTestDriveDislocation == null) {
//     tmpResult += 'Место тест-драйва, ';
//     countEmptyFields++;
//   }
//
//   if (countEmptyFields > 0) {
//     tmpResult = tmpResult.trim().replaceFirst(',', '', tmpResult.length - 5);
//     result = getFieldAddition(countEmptyFields);
//     result += '$tmpResult.';
//   }
//   return result;
// }
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
