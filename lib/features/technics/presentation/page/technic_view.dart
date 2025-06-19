import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/core/shared/plurals.dart';
import 'package:technical_support_artphoto/core/utils/constants.dart';
import 'package:technical_support_artphoto/core/utils/extension.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/core/shared/input_decoration/input_deroration.dart';
import 'package:technical_support_artphoto/features/repairs/models/summ_repair.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/repairs_technic_page.dart';
import 'package:technical_support_artphoto/features/test_drive/models/test_drive.dart';
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
  String? _selectedDropdownDislocation;
  String? _selectedDropdownStatus;
  final List<SumRepair> sumsRepairs = [];
  late final int totalSumm;

  DateTime? _dateStartTestDrive;
  DateTime? _dateFinishTestDrive;
  bool _isDoneTestDrive = false;
  final _resultTestDrive = TextEditingController();

  late Technic technicNew;

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
    _selectedDropdownStatus = widget.technic.status;
    _selectedDropdownDislocation = widget.technic.dislocation;
    _nameTechnic.text = '';
    technicNew = widget.technic.copyWith();
    if (widget.technic.testDrive != null) {
      _dateStartTestDrive = widget.technic.testDrive!.dateStart;
      _dateFinishTestDrive =  widget.technic.testDrive?.dateFinish ?? _dateStartTestDrive!.add(Duration(days: countDaysTestDrive));
      _isDoneTestDrive = widget.technic.testDrive!.isCloseTestDrive;
      _resultTestDrive.text = widget.technic.testDrive!.result;
    } else if (widget.technic.testDrive == null && _selectedDropdownStatus == 'Тест-драйв') {
      _selectedDropdownStatus = null;
    }
    TechnicalSupportRepoImpl.downloadData.getSumRepairs(widget.technic.number.toString()).then((value) {
      if (value.isNotEmpty) {
        setState(() {
          sumsRepairs.addAll(value.values.first);
          totalSumm = value.keys.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    double widthScreen = MediaQuery
        .sizeOf(context)
        .width;
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
                _buildTestDrive(technicNew),
                SizedBox(height: 20),
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
                            technicNew.status = _selectedDropdownStatus ?? 'На хранении';
                            technicNew.dislocation = _selectedDropdownDislocation ?? 'Офис';

                            SaveTestDriveStatus status = SaveTestDriveStatus.notSave;
                            if ((_selectedDropdownStatus == 'Тест-драйв' && widget.technic.testDrive == null) ||
                                (widget.technic.status != 'Тест-драйв' && _selectedDropdownStatus == 'Тест-драйв')) {
                              status = SaveTestDriveStatus.save;
                            }
                            if(widget.technic.status == 'Тест-драйв' && widget.technic.testDrive != null) {
                              status = SaveTestDriveStatus.update;
                            }
                            if(status == SaveTestDriveStatus.save || status == SaveTestDriveStatus.update){
                              TestDrive testDrive = TestDrive(
                                  idTechnic: widget.technic.id,
                                  categoryTechnic: widget.technic.category,
                                  dislocationTechnic: _selectedDropdownDislocation ?? 'На хранении',
                                  dateStart: _dateStartTestDrive ?? DateTime.now(),
                                  dateFinish:
                                  _dateFinishTestDrive ?? DateTime.now().add(Duration(days: countDaysTestDrive)),
                                  result: _resultTestDrive.text,
                                  isCloseTestDrive: _isDoneTestDrive,
                                  user: providerModel.user.name);
                              if (status == SaveTestDriveStatus.update) {
                                testDrive.id = widget.technic.testDrive!.id;
                              }
                              technicNew.testDrive = testDrive;
                            }

                            _save(technicNew, providerModel, status).then((value) {
                              _viewSnackBar(value ? Icons.save : Icons.dangerous_outlined, value,
                                  value ? 'Изменения приняты' : 'Изменения не сохранились');
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
                  titleTextStyle: Theme
                      .of(context)
                      .textTheme
                      .headlineMedium,
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
                        radius: widget.technic.number
                            .toString()
                            .length > 4 ? 25 : null,
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
                titleTextStyle: Theme
                    .of(context)
                    .textTheme
                    .headlineMedium,
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
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineMedium,
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
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
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
                  if (value != null && _selectedDropdownStatus != 'В ремонте' && value == 'В ремонте') {
                    _selectedDropdownDislocation = null;
                  }
                  if (value != null && _selectedDropdownStatus == 'В ремонте' && value != 'В ремонте') {
                    _selectedDropdownDislocation = null;
                  }
                  if (value != null && _selectedDropdownStatus == 'Тест-драйв' && value != 'Тест-драйв') {
                    _dateFinishTestDrive = DateTime.now();
                    _resultTestDrive.text = 'ok';
                    _isDoneTestDrive = true;
                  }
                  if (value != null && value == 'Тест-драйв') {
                    _dateStartTestDrive = DateTime.now();
                    _dateFinishTestDrive = DateTime.now().add(Duration(days: countDaysTestDrive));
                    _resultTestDrive.text = '';
                    _isDoneTestDrive = false;
                  }
                  _selectedDropdownStatus = value;
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
              'Местонахождение техники',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
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
              items: _selectedDropdownStatus == 'В ремонте'
                  ? providerModel.services.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList()
                  : providerModel.namesDislocation.map<DropdownMenuItem<String>>((String value) {
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

  Widget _buildTestDrive(Technic technic) {
    TestDriveStatus status = getStatusTestDrive(technic);
    Color color = getColorTestDrive(status);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 5),
            child: Text(
              'Тест-драйв',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: ExpansionTile(
              title: Text(getTitleTestDrive(status)),
              tilePadding: EdgeInsets.only(left: 28),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              collapsedBackgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: color,
              showTrailingIcon: false,
              textColor: Colors.black,
              enabled: status == TestDriveStatus.notMake ? false : true,
              children: [
                technicNew.testDrive != null || _selectedDropdownStatus == 'Тест-драйв'
                    ? getSubtitleTestDrive()
                    : SizedBox(),
              ],
            )),
      ],
    );
  }

  TestDriveStatus getStatusTestDrive(Technic technic) {
    if (technic.testDrive == null && _selectedDropdownStatus != 'Тест-драйв') {
      return TestDriveStatus.notMake;
    }
    if (_dateFinishTestDrive!.difference(DateTime.now()) < Duration(days: -1) && !_isDoneTestDrive) {
      return TestDriveStatus.missDeadline;
    }
    if (_isDoneTestDrive == false) {
      return TestDriveStatus.inProcess;
    } else {
      return TestDriveStatus.finished;
    }
  }

  String getTitleTestDrive(TestDriveStatus status) {
    if (status == TestDriveStatus.notMake) {
      return 'Не проводился';
    }
    if (status == TestDriveStatus.missDeadline) {
      int days = _dateFinishTestDrive!.difference(DateTime.now()).inDays;
      return 'Просрочен на ${days.abs()} ${pluralize(days.abs())}';
    }
    if (status == TestDriveStatus.inProcess) {
      return 'В процессе до ${_dateFinishTestDrive!.dateFormattedForInterface()}';
    } else {
      return 'Завершен ${_dateFinishTestDrive!.dateFormattedForInterface()}';
    }
  }

  Widget getSubtitleTestDrive() {
    final provider = Provider.of<ProviderModel>(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Column(
                children: [
                  Text(
                    'Начало',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  GestureDetector(
                    onTap: _isDoneTestDrive ? () {} : () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2099),
                          locale: const Locale("ru", "RU"))
                          .then((date) {
                        setState(() {
                          if (date != null) {
                            _dateStartTestDrive = date;
                            _dateFinishTestDrive = _dateStartTestDrive!.add(Duration(days: countDaysTestDrive));
                          }
                        });
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          spacing: 2,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: Colors.grey,
                            ),
                            _dateStartTestDrive!.toString() == "-0001-11-30 00:00:00.000Z" ||
                                _dateStartTestDrive!.toString() == "0001-11-30 00:00:00.000Z" ?
                            Text('Нет даты') : Text(DateFormat('dd/MM/yyyy').format(_dateStartTestDrive!)),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    'Конец',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        spacing: 2,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: Colors.grey,
                          ),
                          _dateFinishTestDrive!.toString() == "-0001-11-30 00:00:00.000Z" ||
                              _dateFinishTestDrive!.toString() == "0001-11-30 00:00:00.000Z" ?
                          Text('Нет даты') : Text(DateFormat('dd/MM/yyyy').format(_dateFinishTestDrive!)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Результат',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                TextFormField(
                  readOnly: _isDoneTestDrive ? true : false,
                  maxLines: 2,
                  decoration: myDecorationTextFormField(),
                  controller: _resultTestDrive,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                      value: _isDoneTestDrive,
                      activeColor: Colors.green.shade300,
                      onChanged: !_isDoneTestDrive ? (_) {
                        setState(() {
                          _isDoneTestDrive = true;
                          _selectedDropdownStatus = 'На хранении';
                          if (_resultTestDrive.text == '') {
                            _resultTestDrive.text = 'ok';
                          }
                          _dateFinishTestDrive = DateTime.now();
                          TestDrive testDrive = TestDrive(
                              idTechnic: widget.technic.id,
                              categoryTechnic: widget.technic.category,
                              dislocationTechnic: _selectedDropdownDislocation ?? 'Офис',
                              dateStart: _dateStartTestDrive ?? DateTime.now(),
                              dateFinish: _dateFinishTestDrive ?? DateTime.now(),
                              result: _resultTestDrive.text,
                              isCloseTestDrive: _isDoneTestDrive,
                              user: provider.user.name);
                          technicNew.testDrive = testDrive;
                        });
                      } : (_) {}),
                ),
                Text(_isDoneTestDrive ? 'Завершен' : 'Завершить тест-драйв'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color getColorTestDrive(TestDriveStatus status) {
    if (status == TestDriveStatus.notMake) {
      return Colors.blue.shade50;
    }
    if (status == TestDriveStatus.missDeadline) {
      return Colors.red.shade50;
    }
    if (status == TestDriveStatus.inProcess) {
      return Colors.yellow.shade50;
    } else {
      return Colors.green.shade50;
    }
  }

  Widget _buildCostAndTotalSumRepairs(ProviderModel provider) {
    bool isListEmpty = sumsRepairs.isEmpty;
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
                    titleTextStyle: Theme
                        .of(context)
                        .textTheme
                        .headlineMedium,
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
                    style: Theme
                        .of(context)
                        .textTheme
                        .headlineMedium,
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
                  sumsRepairs: sumsRepairs,
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
                    Text('Количество ремонтов: ${sumsRepairs.length}'),
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

  Future<bool> _save(Technic technicModel, ProviderModel providerModel, SaveTestDriveStatus status) async {
    LoadingOverlay.of(context).show();

    bool isSuccessStatus = false;
    bool isSuccessTestDrive = false;
    isSuccessStatus = await TechnicalSupportRepoImpl.downloadData
        .updateStatusAndDislocationTechnic(technicModel, providerModel.user.name);
    switch (status) {
      case SaveTestDriveStatus.save:
        isSuccessTestDrive = await TechnicalSupportRepoImpl.downloadData.saveTestDrive(technicModel.testDrive!);
      case SaveTestDriveStatus.update:
        isSuccessTestDrive = await TechnicalSupportRepoImpl.downloadData.updateTestDrive(technicModel.testDrive!);
      case SaveTestDriveStatus.notSave:
        isSuccessTestDrive = true;
    }

    Map<String, dynamic> result = await TechnicalSupportRepoImpl.downloadData.refreshTechnicsData();
    providerModel.refreshTechnics(result['Photosalons'], result['Repairs'], result['Storages']);

    if (mounted) {
      LoadingOverlay.of(context).hide();
    }
    return isSuccessStatus && isSuccessTestDrive;
  }

  void _viewSnackBar(IconData icon, bool isSuccessful, String text) {
    if (context.mounted) {
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
      Navigator.pushAndRemoveUntil(
          context, animationRouteSlideTransition(const ArtphotoTech()), (Route<dynamic> route) => false);
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
