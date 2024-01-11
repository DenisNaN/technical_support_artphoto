import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/trouble/TroubleSQFlite.dart';
import '../ConnectToDBMySQL.dart';
import '../technics/Technic.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'Trouble.dart';

class TroubleAdd extends StatefulWidget {
  const TroubleAdd({super.key});

  @override
  State<TroubleAdd> createState() => _TroubleAddState();
}

class _TroubleAddState extends State<TroubleAdd> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _photosalon;
  String _dateTrouble = DateFormat('d MMMM yyyy', "ru_RU").format(DateTime.now());
  String _dateTroubleForSQL = DateFormat('yyyy.MM.dd').format(DateTime.now());
  final _innerNumberTechnic = TextEditingController();
  final _focusInnerNumberTechnic = FocusNode();
  final _categoryController = TextEditingController();
  final _trouble = TextEditingController();
  bool _isBN = false;
  File? imageFile;
  Uint8List _photoTrouble = Uint8List(0);
  late TransformationController transformationController;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  TapDownDetails? tapDownDetails;

  Technic technicFind = Technic(-1, -1, 'name', 'category', -1, 'dateBuyTechnic', 'status',
      'dislocation', 'comment', 'dateStartTestDrive', 'dateFinishTestDrive', 'resultTestDrive', false);

  @override
  void initState() {
    _focusInnerNumberTechnic.addListener(() {
      if (!_focusInnerNumberTechnic.hasFocus) {
        technicFind =
            Technic.technicList.firstWhere((item) => item.internalID
                .toString() == _innerNumberTechnic.text,
                orElse: () =>
                    Technic(-1, -1, 'name', 'category', -1, 'dateBuyTechnic', 'status', 'dislocation',
                        'comment', 'dateStartTestDrive', 'dateFinishTestDrive', 'resultTestDrive', false));
        _categoryController.text = technicFind.name;
        _photosalon = technicFind.dislocation;
        if (technicFind.id == -1) {
          setState(() {
            _innerNumberTechnic.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.bolt, size: 40, color: Colors.white),
                  Text(
                      'Teхника с этим номером\nв базе не найдена.'),
                ],
              ),
              duration: Duration(seconds: 5),
              showCloseIcon: true,
            ),
          );
        }
      }
    });

    transformationController = TransformationController();
    animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300)
    )..addListener(() {
      transformationController.value = animation!.value;
    });
    super.initState();
  }

  @override
  void dispose() {
    _innerNumberTechnic.dispose();
    _focusInnerNumberTechnic.dispose();
    _trouble.dispose();
    _categoryController.dispose();
    transformationController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if(_isValidateToSave() == false){
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
                            _save();
                          }
                        }
                      },
                      child: const Text("Сохранить"))
                ],
              ),
            )
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
            child: Column(children:[
              const SizedBox(height: 10),
              _buildInnerNumberTechnicListTile(),
              _buildCategoryListTile(),
              _buildDislocationListTile(),
              _buildDateTroubleListTile(),
              _buildComplaintListTile(),
              _buildPhotoTroubleListTile(),
            ]),
          ),
        )
    );
  }

  ListTile _buildInnerNumberTechnicListTile(){
    final numberFormatter = FilteringTextInputFormatter.allow(
      RegExp(r'[0-9]'),
    );

    return ListTile(
        leading: const Icon(Icons.fiber_new),
        title: !_isBN ? TextFormField(
          decoration: const InputDecoration(hintText: "Номер техники"),
          focusNode: _focusInnerNumberTechnic,
          controller: _innerNumberTechnic,
          inputFormatters: [numberFormatter],
          keyboardType: TextInputType.number,
        ) :
        const Text('БН'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Без номера '),
            Switch(
                value: _isBN,
                onChanged: (value){
                  setState(() {
                    _isBN = value;
                    value ? _innerNumberTechnic.text = '0' : _innerNumberTechnic.text = '';
                  });
                }
            ),
          ],)
    );
  }

  ListTile _buildCategoryListTile(){
    return _isBN ? ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Наименование техники"),
        controller: _categoryController,
      ),
    ) : ListTile(
      leading: const Icon(Icons.print),
      title: technicFind.id == -1 ? const Text('Введите номер техники') : Text('Наименование: ${technicFind.name}'),
    );
  }

  ListTile _buildDislocationListTile(){
    return ListTile(
      leading: const Icon(Icons.language),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        isExpanded: true,
        hint: const Text('Фотосалон'),
        icon: _photosalon != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _photosalon = null;
              });}) : null,
        value: _photosalon,
        items: CategoryDropDownValueModel.photosalons.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _photosalon = value!;
          });
        },
      ),
    );
  }

  ListTile _buildDateTroubleListTile(){
    return ListTile(
      leading: const Icon(Icons.today),
      title: const Text("Дата проблемы"),
      subtitle: Text(_dateTrouble),
      trailing: IconButton(
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
                  _dateTroubleForSQL = DateFormat('yyyy.MM.dd').format(date);
                  _dateTrouble = DateFormat('d MMMM yyyy', "ru_RU").format(date);
                }
              });
            });
          },
          color: Colors.blue
      ),
    );
  }

  ListTile _buildComplaintListTile(){
    return ListTile(
      leading: const Icon(Icons.create),
      title: TextFormField(
        decoration: const InputDecoration(hintText: "Жалоба"),
        controller: _trouble,
      ),
    );
  }

  ListTile _buildPhotoTroubleListTile() {
    return ListTile(
      leading: const SizedBox(height: 37, child: Icon(Icons.photo_camera)),
      title: imageFile == null ? const Text("\nФотография") :
        TextButton(
          onPressed: (){
            setState(() {
              imageFile = null;
            });
          },
          child: const Text('Удалить фотографию')),
      subtitle: Container(
          child: imageFile == null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _getFromGallery();
                    },
                    child: const Text("Выбрать в галереи"),
                  ),
                  Container(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _getFromCamera();
                    },
                    child: const Text("Сфотографировать"),
                  )
                ],
              ):
              _buildImage()
      ),
    );
  }

  /// Get from gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 50
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
        imageQuality: 50
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildImage() => GestureDetector(
      onDoubleTapDown: (details) => tapDownDetails = details,
      onDoubleTap: (){
        final position = tapDownDetails!.localPosition;

        const double scale = 3;
        final x = -position.dx * (scale - 1);
        final y = -position.dy * (scale - 1);
        final zoomed = Matrix4.identity()
          ..translate(x, y)
          ..scale(scale);

        final end = transformationController.value.isIdentity() ? zoomed : Matrix4.identity();

        animation = Matrix4Tween(
          begin: transformationController.value,
          end: end
        ).animate(
          CurveTween(curve: Curves.easeOut).animate(animationController)
        );

        animationController.forward(from: 0);
      },
      child: InteractiveViewer(
        clipBehavior: Clip.none,
        transformationController: transformationController,
        panEnabled: true,
        scaleEnabled: true,
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.file(imageFile!)
        )
      )
  );

  bool _isValidateToSave(){
    bool validate = false;
    if(_innerNumberTechnic.text != "" &&
        _categoryController.text != "" &&
        _photosalon != '' &&
        _photosalon != null &&
        _dateTrouble != '' &&
        _trouble.text != '') {
      validate = true;
    }
    return validate;
  }

  void _save() {
    if(imageFile != null) {
      _photoTrouble = _decoderPhotoToBlob(imageFile!);
    }

    Trouble troubleLast = Trouble.troubleList.first;
    Trouble trouble = Trouble(
        troubleLast.id! + 1,
        _photosalon!,
        _dateTroubleForSQL,
        LoginPassword.login,
        int.parse(_innerNumberTechnic.text),
        _trouble.text, '', '', '', '',
        imageFile != null ? _photoTrouble : null
    );

    ConnectToDBMySQL.connDB.insertTroubleInDB(trouble);
    TroubleSQFlite.db.insertTrouble(trouble);

    Navigator.pop(context, trouble);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.add_task, size: 40, color: Colors.white),
            Text(' Неисправность добавлена'),
          ],
        ),
        duration: Duration(seconds: 5),
        showCloseIcon: true,
      ),
    );
  }

  Uint8List _decoderPhotoToBlob(File image) {
    return image.readAsBytesSync();
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