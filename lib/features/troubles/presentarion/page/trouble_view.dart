import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/navigation/animation_navigation.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/features/repairs/presentation/page/repair_add.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../../core/shared/logo_animate/logo_matrix_transition_animate.dart';
import '../../../../core/utils/enums.dart';
import '../../../technics/models/technic.dart';
import '../widget/header_view_trouble.dart';

class TroubleView extends StatefulWidget {
  const TroubleView({super.key, required this.troubleMain});

  final Trouble troubleMain;

  @override
  State<TroubleView> createState() => _TroubleViewState();
}

class _TroubleViewState extends State<TroubleView> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Uint8List? _photoTrouble;
  DateTime? _dateFixTroubleEmployee;
  final _fixTroubleEmployee = TextEditingController();
  DateTime? _dateFixTroubleEngineer;
  final _fixTroubleEngineer = TextEditingController();
  late Trouble trouble;

  late TransformationController transformationController;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  TapDownDetails? tapDownDetails;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    trouble = widget.troubleMain;
    _photoTrouble = widget.troubleMain.photoTrouble;
    _dateFixTroubleEmployee = widget.troubleMain.dateFixTroubleEmployee;
    _fixTroubleEmployee.text = widget.troubleMain.fixTroubleEmployee ?? '';
    _dateFixTroubleEngineer = widget.troubleMain.dateFixTroubleEngineer;
    _fixTroubleEngineer.text = widget.troubleMain.fixTroubleEngineer ?? '';

    transformationController = TransformationController();
    animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
          ..addListener(() {
            transformationController.value = animation!.value;
          });
  }

  @override
  void dispose() {
    transformationController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    return Scaffold(
        key: scaffoldKey,
        appBar: CustomAppBar(
            typePage: TypePage.viewTrouble, location: trouble, technic: null),
        body: FutureBuilder(
            future: TechnicalSupportRepoImpl.downloadData
                .getTechnic(trouble.numberTechnic.toString()),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData || !snapshot.hasData) {
                Technic? technic;
                bool isTechnicNull = !snapshot.hasData;
                if(!isTechnicNull){
                  technic = snapshot.data;
                }
                return Form(
                  key: formKey,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      LoadingOverlay(child: HeaderViewTrouble(trouble: trouble, technic: technic)),
                      SizedBox(height: 20),
                      _buildPhotoTrouble(),
                      SizedBox(height: 14),
                      _buildDateFixTroubleEmployee(providerModel),
                      SizedBox(height: 20),
                      _buildFixTroubleEmployee(),
                      SizedBox(height: 15),
                      _buildDateFixTroubleEngineer(providerModel),
                      SizedBox(height: 20),
                      _buildFixTroubleEngineer(),
                      SizedBox(height: 20),
                      _buildCreateNewRepair(trouble, technic),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.grey)),
                            child: Text("Отмена"),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Trouble troubleNew = Trouble(
                                  id: trouble.id,
                                  photosalon: trouble.photosalon,
                                  dateTrouble: trouble.dateTrouble,
                                  employee: trouble.employee,
                                  numberTechnic: trouble.numberTechnic,
                                  trouble: trouble.trouble,
                                );
                                if (_photoTrouble != null) {
                                  troubleNew.photoTrouble = _photoTrouble;
                                }
                                if (_dateFixTroubleEmployee != null &&
                                    _fixTroubleEmployee.text != '') {
                                  troubleNew.dateFixTroubleEmployee =
                                      _dateFixTroubleEmployee;
                                  troubleNew.fixTroubleEmployee =
                                      _fixTroubleEmployee.text;
                                }
                                if (_dateFixTroubleEngineer != null &&
                                    _fixTroubleEngineer.text != '') {
                                  troubleNew.dateFixTroubleEngineer =
                                      _dateFixTroubleEngineer;
                                  troubleNew.fixTroubleEngineer =
                                      _fixTroubleEngineer.text;
                                }

                                _save(troubleNew, providerModel).then((isSave) {
                                  _viewSnackBar(Icons.save, isSave, 'Изменения сохранены',
                                      'Изменения не сохранены', false);
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
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                    appBar: CustomAppBar(
                        typePage: TypePage.error,
                        location: 'Произошел сбой',
                        technic: null),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 150,
                            color: Colors.blue,
                            shadows: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.5),
                                spreadRadius: 3,
                                blurRadius: 4,
                                offset: Offset(0, 4), // changes position of shadow
                              ),
                            ],
                          ),
                          Text(
                            'Данные не загрузились.\nПроверьте подключение к сети',
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ));
              } else {
                return Center(child: MatrixTransitionLogo());
              }
            }));
  }

  Widget _buildDateFixTroubleEmployee(ProviderModel providerModel) {
    bool isValidateDate = _dateFixTroubleEmployee != null &&
        _dateFixTroubleEmployee.toString() != "-0001-11-30 00:00:00.000Z" &&
        _dateFixTroubleEmployee.toString() != "0001-11-30 00:00:00.000Z";
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Дата закрытия сотрудником',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 55, right: 55, top: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      isValidateDate ? DateFormat('d MMMM yyyy', 'ru_RU')
                          .format(_dateFixTroubleEmployee ?? DateTime.now()) : 'Дата отсутствует',
                      style: TextStyle(color: Colors.black54),
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
                            _dateFixTroubleEmployee = date;
                            _fixTroubleEmployee.text = providerModel.user.name;
                          }
                        });
                      });
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                  setState(() {
                    _dateFixTroubleEmployee = DateTime.tryParse("-0001-11-30 00:00:00.000Z");
                    _fixTroubleEmployee.text = '';
                  });
                }, icon: Icon(Icons.close, color: Colors.red,))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFixTroubleEmployee() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Сотрудник закрывший неис-ть',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: TextFormField(
              decoration: myDecorationTextFormField(),
              controller: _fixTroubleEmployee,
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

  Widget _buildDateFixTroubleEngineer(ProviderModel providerModel) {
    bool isValidateDate = _dateFixTroubleEngineer != null &&
        _dateFixTroubleEngineer.toString() != "-0001-11-30 00:00:00.000Z" &&
        _dateFixTroubleEngineer.toString() != "0001-11-30 00:00:00.000Z";
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Дата закрытия техником',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 55, right: 55, top: 6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(isValidateDate ?
                      DateFormat('d MMMM yyyy', 'ru_RU')
                          .format(_dateFixTroubleEngineer ?? DateTime.now()) : 'Дата отсутствует',
                      style: TextStyle(color: Colors.black54),
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
                            _dateFixTroubleEngineer = date;
                            _fixTroubleEngineer.text = providerModel.user.name;
                          }
                        });
                      });
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _dateFixTroubleEngineer = DateTime.tryParse("-0001-11-30 00:00:00.000Z");
                        _fixTroubleEngineer.text = '';
                      });
                    }, icon: Icon(Icons.close, color: Colors.red,))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFixTroubleEngineer() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Техник закрывший неис-ть',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: TextFormField(
              decoration: myDecorationTextFormField(),
              controller: _fixTroubleEngineer,
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

  Widget _buildCreateNewRepair(Trouble trouble, Technic? technic){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: ElevatedButton(
          onPressed: (){
            Navigator.push(context, animationRouteFadeTransition(LoadingOverlay(child: RepairAdd(trouble: trouble, technic: technic,))));
          },
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.greenAccent)
          ),
          child: const Text('Сформировать заявку на ремонт'),
      ),
    );
  }

  Widget _buildPhotoTrouble() {
    final providerModel = Provider.of<ProviderModel>(context);
    bool isPhoto = trouble.photoTrouble != null &&
        trouble.photoTrouble!.isNotEmpty ? true : false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('Фотография',
            style: TextStyle(
                fontSize: 23, fontStyle: FontStyle.italic, color: Colors.black45)),
        trailing: CircleAvatar(
          maxRadius: 15,
          backgroundColor: isPhoto ? Colors.green : Colors.red,
          child: Icon(
            isPhoto ? Icons.check : Icons.close,
            color: Colors.white,
            size: 25,
          ),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        collapsedBackgroundColor: Colors.blue[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.blue[100],
        children: [
          isPhoto
              ? Column(
                  children: [
                    _buildImage(),
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text('Подтвердите удаление фотографии'),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        trouble.photoTrouble = Uint8List(0);
                                        TechnicalSupportRepoImpl.downloadData
                                            .updateTrouble(trouble)
                                            .then((result) {
                                          bool isResult = result?.isNotEmpty ?? false;
                                          if (isResult) {
                                            providerModel.refreshTroubles(result ?? []);
                                            setState(() {});
                                          }
                                          _viewSnackBar(
                                            Icons.delete_forever,
                                            isResult, 'Фотография удалена',
                                            'Фотография не удалена', true);
                                        });
                                      },
                                      child: Text('Удалить')),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Отмена'))
                                ],
                              );
                            });
                      },
                      icon: Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.red,
                        size: 40,
                      ),
                    )
                  ],
                )
              : _createPhoto()
        ],
      ),
    );
  }

  Widget _createPhoto() {
    return Column(children: [
      ListTile(
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                _getFromGallery();
              },
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 50,
                  ),
                  Text(
                    'Галлерея',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _getFromCamera();
              },
              child: Column(
                children: [
                  Icon(Icons.camera_alt_outlined, size: 50),
                  Text(
                    'Фотоаппарат',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    ]);
  }

  /// Get from gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        Uint8List photo = _decoderPhotoToBlob(File(pickedFile.path));
        _photoTrouble = photo;
        trouble.photoTrouble = photo;
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        Uint8List photo = _decoderPhotoToBlob(File(pickedFile.path));
        _photoTrouble = photo;
        trouble.photoTrouble = photo;
      });
    }
  }

  Widget _buildImage() => GestureDetector(
      onDoubleTapDown: (details) => tapDownDetails = details,
      onDoubleTap: () {
        final position = tapDownDetails!.localPosition;

        const double scale = 3;
        final x = -position.dx * (scale - 1);
        final y = -position.dy * (scale - 1);
        final zoomed = Matrix4.identity()
          ..translate(x, y)
          ..scale(scale);

        final end =
            transformationController.value.isIdentity() ? zoomed : Matrix4.identity();

        animation = Matrix4Tween(begin: transformationController.value, end: end)
            .animate(CurveTween(curve: Curves.easeOut).animate(animationController));
        animationController.forward(from: 0);
      },
      child: InteractiveViewer(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          transformationController: transformationController,
          panEnabled: true,
          scaleEnabled: true,
          child: AspectRatio(aspectRatio: 1, child: Image.memory(_photoTrouble!))));

  Future<bool> _save(Trouble trouble, ProviderModel providerModel) async {
    LoadingOverlay.of(context).show();
    bool isEmptyDateEmployee = trouble.dateFixTroubleEmployee == null ||
        trouble.dateFixTroubleEmployee.toString() == "-0001-11-30 00:00:00.000Z" ||
        trouble.dateFixTroubleEmployee.toString() == "0001-11-30 00:00:00.000Z";
    bool isEmptyEmployee = trouble.fixTroubleEmployee == null ||
        trouble.fixTroubleEmployee == '';
    bool isEmptyDateEngineer = trouble.dateFixTroubleEngineer == null ||
        trouble.dateFixTroubleEngineer.toString() == "-0001-11-30 00:00:00.000Z" ||
        trouble.dateFixTroubleEngineer.toString() == "0001-11-30 00:00:00.000Z";
    bool isEmptyEngineer = trouble.fixTroubleEngineer == null ||
        trouble.fixTroubleEngineer == '';

    if((isEmptyDateEmployee && !isEmptyEmployee) ||
        (!isEmptyDateEmployee && isEmptyEmployee)) {
      _viewSnackBar(Icons.save, false, '', 'Заполните и дату, и сотрудника', false);
      if(context.mounted){
        LoadingOverlay.of(context).hide();
      }
      return false;
    }
    if((isEmptyDateEngineer && !isEmptyEngineer) ||
        (!isEmptyDateEngineer && isEmptyEngineer)) {
      _viewSnackBar(Icons.save, false, '', 'Заполните и дату, и техника', false);
      if(context.mounted){
        LoadingOverlay.of(context).hide();
      }
      return false;
    }
    List<Trouble>? resultData =
        await TechnicalSupportRepoImpl.downloadData.updateTrouble(trouble);
    if (resultData != null) {
      providerModel.refreshTroubles(resultData);
      // await addHistory(technic, nameUser);
      if(context.mounted){
        LoadingOverlay.of(context).hide();
      }
      return true;
    }
    if(context.mounted){
      LoadingOverlay.of(context).hide();
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

  void _viewSnackBar(
      IconData icon, bool isSuccessful, String successText, String notSuccessText, bool isSkip) {
    if (context.mounted) {
      if (isSkip) {
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
              Flexible(child: Text(isSuccessful ? successText : notSuccessText)),
            ],
          ),
          duration: const Duration(seconds: 5),
          showCloseIcon: true,
        ),
      );
      if (isSuccessful) {
        Navigator.pop(context);
      }
    }
  }
}

Uint8List _decoderPhotoToBlob(File image) {
  return image.readAsBytesSync();
}

class IntegerCurrencyInputFormatter extends TextInputFormatter {
  final validationRegex = RegExp(r'^[\d,]*$');
  final replaceRegex = RegExp(r'[^\d]+');
  static const thousandSeparator = ',';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
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
    final initialNumberOfPrecedingSeparators =
        oldValue.text.characters.where((e) => e == thousandSeparator).length;
    final newNumberOfPrecedingSeparators =
        formattedText.characters.where((e) => e == thousandSeparator).length;
    final additionalOffset =
        newNumberOfPrecedingSeparators - initialNumberOfPrecedingSeparators;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(
          offset: newValue.selection.baseOffset + additionalOffset),
    );
  }
}
