import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technical_support_artphoto/repair/RepairAddWithTrouble.dart';
import 'package:technical_support_artphoto/trouble/TroubleSQFlite.dart';
import 'package:technical_support_artphoto/utils/utils.dart';
import '../ConnectToDBMySQL.dart';
import '../history/History.dart';
import '../history/HistorySQFlite.dart';
import '../repair/Repair.dart';
import '../technics/Technic.dart';
import '../technics/TechnicViewAndChange.dart';
import '../utils/hasNetwork.dart';
import 'package:intl/intl.dart';
import 'Trouble.dart';

class TroubleViewAndChange extends StatefulWidget {
  final Trouble trouble;
  const TroubleViewAndChange({super.key, required this.trouble});

  @override
  State<TroubleViewAndChange> createState() => _TroubleViewAndChangeState();
}

class _TroubleViewAndChangeState extends State<TroubleViewAndChange> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _innerNumberTechnic = '';
  String? _photosalon;
  String _employee = '';
  String _dateTrouble = '';
  String _trouble = '';
  String _dateCheckFixTroubleEmployee = '';
  String _employeeCheckFixTrouble = '';
  String _dateCheckFixTroubleEngineer = '';
  String _engineerCheckFixTrouble = '';
  Uint8List _photoTrouble = Uint8List.fromList([]);
  bool isTechnicFind = false;
  late Trouble _oldTroubleForHistory;

  late TransformationController transformationController;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  TapDownDetails? tapDownDetails;

  bool _isEdit = false;
  int indexTechnic = 0;

  @override
  void initState() {
    super.initState();

    _oldTroubleForHistory = Trouble(
        widget.trouble.id,
        widget.trouble.photosalon,
        widget.trouble.dateTrouble,
        widget.trouble.employee,
        widget.trouble.internalID,
        widget.trouble.trouble,
        widget.trouble.dateCheckFixTroubleEmployee,
        widget.trouble.employeeCheckFixTrouble,
        widget.trouble.dateCheckFixTroubleEngineer,
        widget.trouble.engineerCheckFixTrouble);

    for(int i = 0; i < Technic.technicList.length; i++){
      if(Technic.technicList[i].internalID == widget.trouble.internalID){
        indexTechnic = i;
        isTechnicFind = true;
        break;
      }
    }
    _innerNumberTechnic = '${widget.trouble.internalID}';
    _photosalon = widget.trouble.photosalon;
    _employee = widget.trouble.employee;
    _dateTrouble = widget.trouble.dateTrouble;
    _trouble = widget.trouble.trouble;
    _dateCheckFixTroubleEmployee = widget.trouble.dateCheckFixTroubleEmployee;
    _employeeCheckFixTrouble = widget.trouble.employeeCheckFixTrouble;
    _dateCheckFixTroubleEngineer = widget.trouble.dateCheckFixTroubleEngineer;
    _engineerCheckFixTrouble = widget.trouble.engineerCheckFixTrouble;
    if(widget.trouble.photoTrouble != null) _photoTrouble = widget.trouble.photoTrouble!;

    transformationController = TransformationController();
    animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300)
    )..addListener(() {
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
    ColorAppBar colorAppBar = ColorAppBar();
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: colorAppBar.color(),
          title: const Text('Внесение изменений в неисп-ть'),
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
                        if(_isEdit){
                          Future<Trouble> trouble = _save();
                          Navigator.pop(context, trouble);

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
                widget.trouble.internalID != 0 ? _buildPhotosalon() : const SizedBox(),
                widget.trouble.internalID != 0 ? _buildDateTrouble() : const SizedBox(),
                _buildTrouble(),
                _buildCloseTroubleEmployee(),
                _buildCloseTroubleEngineer(),
                _photoTrouble.isNotEmpty ? _buildPhotoTroubleListTile() : const SizedBox(),
                const SizedBox(height: 30),
                HasNetwork.isConnecting ? _buildRequestRepair() : const SizedBox()
              ],
            )
        )
    );
  }

  ListTile _buildInternalID() {
    return ListTile(
      leading: const Icon(Icons.fiber_new),
      title: widget.trouble.internalID != 0 && isTechnicFind ?
      TextButton(
          style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 0.0),
              alignment: Alignment.centerLeft,
              textStyle: const TextStyle(fontSize: 20)
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.technicList[indexTechnic]))).then(
                    (value){
                  setState(() {
                    if(value != null) {
                      Technic.technicList[indexTechnic] = value;
                    }
                  });
                });
          },
          child: Text('№ - $_innerNumberTechnic')
      ) :
      widget.trouble.internalID == 0 ? const Text('БН') : Text('№ - $_innerNumberTechnic'),
    );
  }

  ListTile _buildPhotosalon() {
    return ListTile(
      leading: const Icon(Icons.medical_information),
      title: Text('Наименование: ${Technic.technicList[indexTechnic].category}\n'
          'Местонахождение: $_photosalon\n'
          'Сотрудник: $_employee'),
      );
  }

  ListTile _buildDateTrouble() {
    return ListTile(
      leading: const Icon(Icons.date_range),
      title: Text('Дата: '
          '${DateFormat('d MMMM yyyy', 'ru_RU').format(DateTime.parse(_dateTrouble.replaceAll('.', '-')))}'),
    );
  }

  ListTile _buildTrouble() {
    return ListTile(
      leading: const Icon(Icons.create),
      title: Text('Жалоба:\n $_trouble')
    );
  }

  ListTile _buildCloseTroubleEmployee() {
    return ListTile(
      leading: const Icon(Icons.today),
      title: _dateCheckFixTroubleEmployee != '' ? Text(
          'Закрытие сотрудником:\n'
          'Сотрудник: $_employeeCheckFixTrouble\n'
          'Дата: ${_dateCheckFixTroubleEmployee.isNotEmpty ? getDateFormat(_dateCheckFixTroubleEmployee) : ''}') :
      const Text('Проблема сотрудником не закрыта'),
      trailing: LoginPassword.access == 'admin' ?
      Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 40, child: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            showDatePicker(
                context: context,
                initialDate: _dateCheckFixTroubleEmployee != '' ?
                  DateTime.parse(_dateCheckFixTroubleEmployee.replaceAll('.', '-')) : DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2099),
                locale: const Locale("ru", "RU")
            ).then((date) {
              setState(() {
                if(date != null) {
                  _dateCheckFixTroubleEmployee = DateFormat('yyyy.MM.dd').format(date);
                  _employeeCheckFixTrouble = LoginPassword.login;
                  _isEdit = true;
                }
              });
            });
          },
          color: Colors.blue)
        ),
        IconButton(
            onPressed: (){
              setState(() {
                _dateCheckFixTroubleEmployee = '';
                _employeeCheckFixTrouble = '';
                _isEdit = true;
              });
            },
            icon: const Icon(Icons.clear))
      ]) : null
    );
  }

  ListTile _buildCloseTroubleEngineer() {
    return ListTile(
      leading: const Icon(Icons.today),
      title: Text(_dateCheckFixTroubleEngineer == '' ? 'Для закрытия проблемы инженером выберите дату' :
              'Закрытие инженером:\n'
              'Сотрудник: $_engineerCheckFixTrouble\n'
              'Дата: ${_dateCheckFixTroubleEngineer.isNotEmpty ? getDateFormat(_dateCheckFixTroubleEngineer) : ''}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 40, child: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            showDatePicker(
                context: context,
                initialDate: _dateCheckFixTroubleEngineer != '' ?
                  DateTime.parse(_dateCheckFixTroubleEngineer.replaceAll('.', '-')) : DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2099),
                locale: const Locale("ru", "RU")
            ).then((date) {
              setState(() {
                if(date != null) {
                  _dateCheckFixTroubleEngineer = DateFormat('yyyy.MM.dd').format(date);
                  _engineerCheckFixTrouble = LoginPassword.login;
                  _isEdit = true;
                }
              });
            });
          },
          color: Colors.blue)),
        IconButton(
            onPressed: (){
              setState(() {
                _dateCheckFixTroubleEngineer = '';
                _engineerCheckFixTrouble = '';
                _isEdit = true;
              });
            },
            icon: const Icon(Icons.clear))
      ])
    );
  }

  ListTile _buildPhotoTroubleListTile() {
    return ListTile(
      title:  const Center(child: Text("\nФотография\n")),
      subtitle: Container(
          child: _buildImage()
      ),
    );
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
              child: Image.memory(_photoTrouble)
          )
      )
  );

  ListTile _buildRequestRepair(){
    return ListTile(
      title: TextButton(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(7)),
            child: const Text("Сформировать заявку на ремонт", style: TextStyle(color: Colors.white, fontSize: 15))),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => RepairAddWithTrouble(trouble: widget.trouble))).then((value){
            setState(() {
              if(value != null) Repair.repairList.insert(0, value);
            });
          });
        },
      ),
    );
  }

  Future<Trouble> _save() async{

    Trouble trouble = Trouble(
        widget.trouble.id,
        _photosalon!,
        _dateTrouble,
        widget.trouble.employee,
        int.parse(_innerNumberTechnic),
        _trouble,
        _dateCheckFixTroubleEmployee,
        _employeeCheckFixTrouble,
        _dateCheckFixTroubleEngineer,
        _engineerCheckFixTrouble,
        widget.trouble.photoTrouble
    );

    await ConnectToDBMySQL.connDB.connDatabase();
    if(_isEdit) {
      ConnectToDBMySQL.connDB.updateTroubleInDB(trouble);
      TroubleSQFlite.db.updateTrouble(trouble);
      addHistory(trouble);
    }
    return trouble;
  }

  Future addHistory(Trouble trouble) async{
    String descForHistory = descriptionForHistory(_oldTroubleForHistory, trouble);
    History historyForSQL = History(
        History.historyList.last.id + 1,
        'Trouble',
        trouble.id!,
        'edit',
        descForHistory,
        LoginPassword.login,
        DateFormat('yyyy.MM.dd').format(DateTime.now())
    );

    ConnectToDBMySQL.connDB.insertHistory(historyForSQL);
    HistorySQFlite.db.insertHistory(historyForSQL);
    History.historyList.insert(0, historyForSQL);
  }

  String descriptionForHistory(Trouble troubleOld, Trouble troubleNew){
    String internalID = troubleOld.internalID == -1 ? 'БН' : '№${troubleOld.internalID}';
    String result = 'Неисправность $internalID изменена:';

    if(troubleOld.dateCheckFixTroubleEmployee != troubleNew.dateCheckFixTroubleEmployee){
      if(troubleOld.dateCheckFixTroubleEmployee == ''){
        result = '$result\n Внесена дата закрытия неисп-ти фотографом: '
            '${troubleNew.dateCheckFixTroubleEmployee.isNotEmpty ? getDateFormat(troubleNew.dateCheckFixTroubleEmployee) : ''}';
      }else {
        result = '$result\n Дата закрытия неисп-ти фотографом изменена:\n'
            '  Было: ${troubleOld.dateCheckFixTroubleEmployee.isNotEmpty ? getDateFormat(troubleOld.dateCheckFixTroubleEmployee) : ''}\n'
            '  Стало: ${troubleNew.dateCheckFixTroubleEmployee.isNotEmpty ? getDateFormat(troubleNew.dateCheckFixTroubleEmployee) : ''}';
      }
    }
    if(troubleOld.dateCheckFixTroubleEngineer != troubleNew.dateCheckFixTroubleEngineer){
      if(troubleOld.dateCheckFixTroubleEngineer == ''){
        result = '$result\n Внесена дата закрытия неисп-ти инженером: '
            '${troubleNew.dateCheckFixTroubleEngineer.isNotEmpty ? getDateFormat(troubleNew.dateCheckFixTroubleEngineer) : ''}';
      }else {
        result = '$result\n Дата закрытия неисп-ти инженером изменена:\n'
            '  Было: ${troubleOld.dateCheckFixTroubleEngineer.isNotEmpty ? getDateFormat(troubleOld.dateCheckFixTroubleEngineer) : ''}\n'
            '  Стало: ${troubleNew.dateCheckFixTroubleEngineer.isNotEmpty ? getDateFormat(troubleNew.dateCheckFixTroubleEngineer) : ''}';
      }
    }
    return result;
  }

  String getDateFormat(String date) {
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
