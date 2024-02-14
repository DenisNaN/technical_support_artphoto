import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/technics/Technic.dart';
import 'package:intl/intl.dart';

class TechnicTotalTestDrive extends StatefulWidget {
  final int technicId;
  final int technicinternalID;
  const TechnicTotalTestDrive({super.key, required this.technicId, required this.technicinternalID});

  @override
  State<TechnicTotalTestDrive> createState() => _TechnicTotalTestDriveState();
}

class _TechnicTotalTestDriveState extends State<TechnicTotalTestDrive> {
  @override
  Widget build(BuildContext context) {
    List listTotalTestDrive = getListTotalTestDrive(widget.technicId);

    return Scaffold(
      appBar: AppBar(
          title: Text('Тест-драйв техники №${widget.technicinternalID}')),
      body: ListView.builder(
          itemCount: listTotalTestDrive.length,
          itemBuilder: (context, index){
            Technic? technicTectDrive = listTotalTestDrive[index];
            bool isDoneTestDrive = isFinishTestDrive(technicTectDrive);
            return ListTile(
              title: _buildText(context, technicTectDrive),
              tileColor: isDoneTestDrive ? Colors.lightGreenAccent : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20)
            );
          }
      ),
    );
  }

  Text _buildText(BuildContext context, Technic? technicTestDrive){
    if(technicTestDrive == null){
      return const Text('Ошибка загруки данных\n'
          'Скриншот отправить Денису');
    }
    return Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Место тест-драйва: ${technicTestDrive.testDriveDislocation}\n', style: const TextStyle(fontSize: 20)),
          TextSpan(text: 'Период проведения:\n'
              '${getDateFormat(technicTestDrive.dateStartTestDrive)} - ${getDateFormat(technicTestDrive.dateFinishTestDrive)}\n'),
          TextSpan(text: 'результат тест-драйва: ${technicTestDrive.resultTestDrive}\n'),
          TextSpan(text: 'Сотрудник: ${technicTestDrive.userTestDrive}\n')
        ]
        )
    );
  }

  List getListTotalTestDrive(int TechnicId){
    List totalTestDrive = [];
    // int index = 0;
    Technic.testDriveList.forEach((element) {
      if(element.internalID == TechnicId){
        totalTestDrive.add(element);
      }
    });
    return totalTestDrive;
  }

  bool isFinishTestDrive(Technic? technic){
    if(technic == null) return false;
    bool result = false;
    if(technic.checkboxTestDrive){
      result = true;
    }
    return result;
  }

  String getDateFormat(String date) {
    if(date == '') return 'Нет даты';
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }
}
