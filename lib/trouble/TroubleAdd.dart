import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/trouble/TroubleSQFlite.dart';
import '../ConnectToDBMySQL.dart';
import '../technics/Technic.dart';
import '../utils/categoryDropDownValueModel.dart';
import '../utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'Trouble.dart';

class TroubleAdd extends StatefulWidget {
  const TroubleAdd({super.key});

  @override
  State<TroubleAdd> createState() => _TroubleAddState();
}

class _TroubleAddState extends State<TroubleAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _photosalon;
  String _dateTrouble = '';
  String _dateTroubleForSQL = '';
  String? _employee;
  final _innerNumberTechnic = TextEditingController();
  final _focusInnerNumberTechnic = FocusNode();
  String _category = "";
  final _categoryController = TextEditingController();
  final _trouble = TextEditingController();
  bool _isBN = false;
  File? imageFile;
  String _photoTrouble = '';

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
        _category = technicFind.name;
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
    super.initState();
  }

  @override
  void dispose() {
    _innerNumberTechnic.dispose();
    _focusInnerNumberTechnic.dispose();
    _trouble.dispose();
    _categoryController.dispose();
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
              _buildEmployeeListTile(),
              _buildComplaintListTile(),
              const SizedBox(height: 10),
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
    return _isBN ? ListTile(
      leading: const Icon(Icons.copyright),
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
    ) : ListTile(
      leading: const Icon(Icons.print),
      title: technicFind.id == -1 ? const Text('Введите номер техники') : Text('Последний фотосалон: ${technicFind.dislocation}'),
    );
  }

  ListTile _buildDateTroubleListTile(){
    return ListTile(
      leading: const Icon(Icons.today),
      title: const Text("Дата проблемы"),
      subtitle: Text(_dateTrouble == "" ? "Выберите дату" : _dateTrouble),
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

  ListTile _buildEmployeeListTile(){
    Iterable<String> employee = LoginPassword.loginPassword.values;
    return ListTile(
      leading: const Icon(Icons.copyright),
      title: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10.0),
        isExpanded: true,
        hint: const Text('Сотрудник'),
        icon: _employee != null ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: (){
              setState(() {
                _employee = null;
              });}) : null,
        value: _employee,
        items: employee.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value){
          setState(() {
            _employee = value!;
          });
        },
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
    // if(imageFile != null) {
    //   double height = 0.0;
    //   _calculateImageHeight().then((value) => print(value));
    // }

    return ListTile(
      leading: const Icon(Icons.photo_camera),
      title: imageFile == null ? const Text("Фотография") :
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
              // SizedBox(
              // height: 500,
              // child: PhotoView(
              //     backgroundDecoration: const BoxDecoration(color: Colors.white70),
              //     imageProvider: FileImage(imageFile!)
              //     )
              // )

              FutureBuilder<double>(
                future: _calculateImageHeight(),
                builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                  if (snapshot.hasData) {
                    double? height = snapshot.data;
                    return SizedBox(
                        height: height,
                        child: PhotoView(
                            backgroundDecoration: const BoxDecoration(color: Colors.white70),
                            imageProvider: FileImage(imageFile!)
                        )
                    );
                  } else {
                    return const Text('Loading...');
                  }
                },
              ),
      ),
    );
  }

  /// Get from gallery
  _getFromGallery() async {
    // FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    //
    // if (result != null) {
    //   setState(() {
    //     imageFile = File(result.files.single.path!);
    //   });
    // } else {
    //   // User canceled the picker
    // }

    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
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
      // maxWidth: 1800,
      // maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<double> _calculateImageHeight() {
    // ByteData data = Image.file(imageFile!).toByteData(format: ImageByteFormat.png);
    //
    // final Uint8List bytes = data.buffer.asUint8List();
    // final decodedImage = decodeImageFromList(bytes);
    // print(decodedImage.width);
    // print(decodedImage.height);

    Completer<double> completer = Completer();
    Image image = Image.file(imageFile!);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          double height = myImage.height.toDouble();
          print('myImage.height ${myImage.height.toDouble()}');
          print('myImage.width ${myImage.width.toDouble()}');

          completer.complete(height);
        },
      ),
    );
    return completer.future;
  }

  // Future<Size> _calculateImageDimension() {
  //   Completer<Size> completer = Completer();
  //   Image image = Image.network("https://i.stack.imgur.com/lkd0a.png");
  //   image.image.resolve(ImageConfiguration()).addListener(
  //     ImageStreamListener(
  //           (ImageInfo image, bool synchronousCall) {
  //         var myImage = image.image;
  //         Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
  //         completer.complete(size);
  //       },
  //     ),
  //   );
  //   return completer.future;
  // }

  bool _isValidateToSave(){
    bool validate = false;
    if(_photosalon != '' && _dateTrouble != '' && _employee != '' &&
        (!_isBN ? _innerNumberTechnic.text != "" : _innerNumberTechnic.text == '-1') &&
        (!_isBN ? _category != "" : _categoryController.text != "") &&
        _trouble.text != '') {
      validate = true;
    }
    return validate;
  }

  void _save(){
    Trouble troubleLast = Trouble.troubleList.first;
    Trouble trouble = Trouble(
      troubleLast.id! + 1,
      _photosalon!,
      _dateTroubleForSQL,
      _employee!,
      int.parse(_innerNumberTechnic.text),
      _trouble.text, '', '', '', '',
        _photoTrouble
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