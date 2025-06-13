import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/shared/input_decoration/input_deroration.dart';
import '../../../../core/shared/logo_animate/logo_matrix_transition_animate.dart';
import '../../../../core/utils/enums.dart';
import '../../../technics/models/technic.dart';
import '../widget/header_view_trouble.dart';

class TroubleView extends StatefulWidget {
  const TroubleView({super.key, required this.trouble});

  final Trouble trouble;

  @override
  State<TroubleView> createState() => _TroubleViewState();
}

class _TroubleViewState extends State<TroubleView> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Uint8List? _photoTrouble;
  File? imageFile;
  DateTime? _dateFixTroubleEmployee;
  final _fixTroubleEmployee = TextEditingController();
  DateTime? _dateFixTroubleEngineer;
  final _fixTroubleEngineer = TextEditingController();

  late TransformationController transformationController;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  TapDownDetails? tapDownDetails;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _photoTrouble = widget.trouble.photoTrouble;
    _dateFixTroubleEmployee = widget.trouble.dateFixTroubleEmployee;
    _fixTroubleEmployee.text = widget.trouble.fixTroubleEmployee ?? '';
    _dateFixTroubleEngineer = widget.trouble.dateFixTroubleEngineer;
    _fixTroubleEngineer.text = widget.trouble.fixTroubleEngineer ?? '';

    transformationController = TransformationController();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
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
        appBar: CustomAppBar(typePage: TypePage.viewTrouble, location: widget.trouble, technic: null),
        body: FutureBuilder(
            future: TechnicalSupportRepoImpl.downloadData.getTechnic(widget.trouble.numberTechnic.toString()),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                Technic technic = snapshot.data;
                return Form(
                  key: formKey,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      HeaderViewTrouble(trouble: widget.trouble, technic: technic),
                      SizedBox(height: 20),
                      _buildPhotoTrouble(),
                      SizedBox(height: 14),
                      _buildDateFixTroubleEmployee(providerModel),
                      SizedBox(height: 20),
                      _buildFixTroubleEmployee(),
                      SizedBox(height: 20),
                      _buildDateFixTroubleEngineer(providerModel),
                      SizedBox(height: 20),
                      _buildFixTroubleEngineer(),
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
                                Trouble trouble = Trouble(
                                  id: widget.trouble.id,
                                  photosalon: widget.trouble.photosalon,
                                  dateTrouble: widget.trouble.dateTrouble,
                                  employee: widget.trouble.employee,
                                  numberTechnic: widget.trouble.numberTechnic,
                                  trouble: widget.trouble.trouble,
                                );
                                if(imageFile != null) {
                                  _photoTrouble = _decoderPhotoToBlob(imageFile!);
                                  trouble.photoTrouble = _photoTrouble;
                                }
                                if(_dateFixTroubleEmployee != null && _fixTroubleEmployee.text != ''){
                                  trouble.dateFixTroubleEmployee = _dateFixTroubleEmployee;
                                  trouble.fixTroubleEmployee = _fixTroubleEmployee.text;
                                }
                                if(_dateFixTroubleEngineer != null && _fixTroubleEngineer.text != ''){
                                  trouble.dateFixTroubleEngineer = _dateFixTroubleEngineer;
                                  trouble.fixTroubleEngineer = _fixTroubleEngineer.text;
                                }

                                _save(trouble, providerModel).then((isSave) {
                                  _viewSnackBar(Icons.save, isSave, 'Заявка создана', 'Заявка не создана', scaffoldKey);
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
              }else if (snapshot.hasError) {
                return Scaffold(
                    appBar: CustomAppBar(typePage: TypePage.error, location: 'Произошел сбой', technic: null),
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
            }
        ));
  }

  Widget _buildDateFixTroubleEmployee(ProviderModel providerModel) {
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
          child: ListTile(
            title: Text(
              DateFormat('d MMMM yyyy', 'ru_RU').format(_dateFixTroubleEmployee ?? DateTime.now()),
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
                    _dateFixTroubleEmployee = date;
                    _fixTroubleEmployee.text = providerModel.user.name;
                  }
                });
              });
            },
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
              decoration: myDecorationTextFormField('Сотрудник закрывший неис-ть', 'Сотрудник закрывший неис-ть'),
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
          child: ListTile(
            title: Text(
              DateFormat('d MMMM yyyy', 'ru_RU').format(_dateFixTroubleEngineer ?? DateTime.now()),
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
                    _dateFixTroubleEngineer = date;
                    _fixTroubleEngineer.text = providerModel.user.name;
                  }
                });
              });
            },
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
              'Сотрудник закрывший неис-ть',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ListTile(
            title: TextFormField(
              decoration: myDecorationTextFormField('Сотрудник закрывший неис-ть', 'Сотрудник закрывший неис-ть'),
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

  Widget _buildPhotoTrouble() {
    return Column(children: [
      Center(
        child: Text(
          'Фотография',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      ListTile(
        title: imageFile == null
            ? null
            : IconButton(
                icon: Icon(Icons.delete_forever_outlined, color: Colors.red, size: 40,),
                onPressed: () {
                  setState(() {
                    imageFile = null;
                  });
                }),
        subtitle: Container(
          decoration: imageFile != null ? BoxDecoration(
            border: Border.all(color: Colors.white, width: 4.5),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 4,
                  offset: Offset(2, 4), // Shadow position
                ),
              ]
          ) : null,
            child: imageFile == null
                ? Row(
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
                )
                : _buildImage()),
      )
    ]);
  }

  /// Get from gallery
  _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
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

        final end = transformationController.value.isIdentity() ? zoomed : Matrix4.identity();

        animation = Matrix4Tween(begin: transformationController.value, end: end)
            .animate(CurveTween(curve: Curves.easeOut).animate(animationController));
        animationController.forward(from: 0);
      },
      child: InteractiveViewer(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          transformationController: transformationController,
          panEnabled: true,
          scaleEnabled: true,
          child: AspectRatio(
              aspectRatio: 1,
              child: _photoTrouble != null ? Image.memory(_photoTrouble!) :
              Image.file(imageFile!))));

  Future<bool> _save(Trouble trouble, ProviderModel providerModel) async {
    if ((trouble.dateFixTroubleEmployee != null && trouble.fixTroubleEmployee == '') ||
        (trouble.dateFixTroubleEmployee == null && trouble.fixTroubleEmployee != '') ||
        (trouble.dateFixTroubleEngineer != null && trouble.fixTroubleEngineer == '') ||
        (trouble.dateFixTroubleEngineer == null && trouble.fixTroubleEngineer != '')
    ) {
      _viewSnackBar(Icons.save, false, '', 'Заполните и дату, и сотрудника', scaffoldKey);
      return false;
    }else{
      List<Trouble>? resultData = await TechnicalSupportRepoImpl.downloadData.saveTrouble(trouble);
      if (resultData != null) {
        providerModel.refreshTroubles(resultData);
        // await addHistory(technic, nameUser);
        return true;
      }
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

  void _viewSnackBar(IconData icon, bool isSuccessful, String successText, String notSuccessText,
      GlobalKey<ScaffoldState> scaffoldKey) {
    final contextViewSnackBar = scaffoldKey.currentContext;
    if (contextViewSnackBar != null && contextViewSnackBar.mounted) {
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
      Navigator.pop(contextViewSnackBar);
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
