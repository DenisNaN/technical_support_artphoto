import 'package:flutter/material.dart';
import '../repair/Repair.dart';
import '../utils/categoryDropDownValueModel.dart';
import 'Technic.dart';
import 'TechnicViewAndChange.dart';
import 'package:intl/intl.dart';

class ViewFindTechnic extends StatefulWidget {
  const ViewFindTechnic({super.key});

  @override
  State<ViewFindTechnic> createState() => _ViewFindTechnicState();
}

class _ViewFindTechnicState extends State<ViewFindTechnic> {
  Map<String, int> colorForTechnic = {};


  @override
  void initState() {
    super.initState();
    colorForTechnic.addAll(CategoryDropDownValueModel.colorForEquipment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: Technic.tmpTechnicList.length,
        itemBuilder: (context, index) {
          String dateStart = _dateStart(index);
          Color color = _getTileColor(index);
          String nameTechnic = _nameTechnic(index);
          List testDriveList = _getListTestDrive(Technic.tmpTechnicList[index]);

          return Material(
              child: Column(
                children: [
                  ListTile(
                    tileColor: color,
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.tmpTechnicList[index]))).then((value){
                        setState(() {
                          if(value != null) {
                            Technic.tmpTechnicList[index] = value;
                          }
                        });
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text.rich(TextSpan(children: [
                      TextSpan(text: '№ ${Technic.tmpTechnicList[index].internalID} '),
                      TextSpan(text: '${Technic.tmpTechnicList[index].category}. ', style: const TextStyle(fontWeight: FontWeight.bold), ),
                      TextSpan(text: nameTechnic)
                    ])),
                    subtitle: dateStart != '' ?
                    _buildTextWithTestDrive(context, index, testDriveList) :
                    _buildTextWithoutTestDrive(context, index, testDriveList),
                  ),
                ],
              ));
        },
      ),
    );
  }

  Text _buildTextWithoutTestDrive(BuildContext context, int index, List testDriveList){
    Color color = const Color(0xff000000);
    return Text.rich(TextSpan(children: [
      TextSpan(text: '${Technic.tmpTechnicList[index].dislocation}.',
          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      testDriveList.isEmpty ? TextSpan(text: ' Статус: ${Technic.tmpTechnicList[index].status}\n'
          'Тест-драйв не проводился') : TextSpan(text: ' Статус: ${Technic.tmpTechnicList[index].status}\n'
          'Кол-во тест-драйвов: ${testDriveList.length}'),
      getTotalSumRepairs(index)
    ])
    );
  }

  Text _buildTextWithTestDrive(BuildContext context, int index, List testDriveList){
    DateTime dateStart = DateTime.parse(Technic.tmpTechnicList[index].dateStartTestDrive.replaceAll('.', '-'));
    DateTime dateFinish;
    DateTime dateNow;
    String formatedStartDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateStart);
    String formatedFinishDate = '';
    Duration duration = const Duration(days: 0);
    bool isHaveFinishDate = false;
    Color color = const Color(0xff000000);

    if(Technic.tmpTechnicList[index].dateFinishTestDrive != ''){
      dateFinish = DateTime.parse(Technic.tmpTechnicList[index].dateFinishTestDrive.replaceAll('.', '-'));
      formatedFinishDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateFinish);
      dateNow = DateTime.now().add(const Duration(days: -1));
      duration = dateFinish.difference(dateNow);
      isHaveFinishDate = true;
    }
    return Text.rich(
        TextSpan(
            children:[
              TextSpan(
                  text: '${Technic.tmpTechnicList[index].dislocation}. ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color)),
              TextSpan(text:
              'Статус: ${Technic.tmpTechnicList[index].status}\n'),
              isHaveFinishDate ?
              TextSpan(children: [
                TextSpan(text:
                'Начало тест-драйва: $formatedStartDate.\n'
                    'Конец тест-драйва: $formatedFinishDate.\n'),
                duration.inDays > 0 && !Technic.tmpTechnicList[index].checkboxTestDrive ?
                TextSpan(
                    text: 'До конца тест-драйва: ${duration.inDays} ${getDayAddition(duration.inDays)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
                ) : TextSpan(
                    text: !Technic.tmpTechnicList[index].checkboxTestDrive ?
                    'Период тест-драйва завершен' :
                    'Тест-драйв завершен',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Technic.tmpTechnicList[index].checkboxTestDrive ? Colors.green : Colors.blue)
                )
              ]
              ) :
              TextSpan(children:[
                TextSpan(text: 'Дата тест-драйва: $formatedStartDate.\n'),
                TextSpan(text: Technic.tmpTechnicList[index].checkboxTestDrive ? 'Тест-драйв завершен' : 'Тест-драйв не завершен',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Technic.tmpTechnicList[index].checkboxTestDrive ?
                    Colors.green : Colors.blue)),
              ]),
              getTotalSumRepairs(index)
            ]
        )
    );
  }

  TextSpan getTotalSumRepairs(int index){
    int totalSumRepairs = _getTotalSumRepairs(index);
    return TextSpan(text: totalSumRepairs != 0 ? '\nИтоговая сумма ремонта: $totalSumRepairs р.' :
    '\nРемонт не проводился');
  }

  int _getTotalSumRepairs(int index){
    int totalSumRepairs = 0;
    for(TotalSumRepairs element in Repair.totalSumRepairs){
      if(element.idTechnic == Technic.tmpTechnicList[index].internalID){
        int coastReapair = element.sumRepair;
        totalSumRepairs += coastReapair;
      }
    }
    return totalSumRepairs;
  }

  String getDayAddition(int num) {
    double preLastDigit = num % 100 / 10;
    if (preLastDigit.round() == 1) {
      return "дней";
    }
    switch (num % 10) {
      case 1:
        return "день";
      case 2:
      case 3:
      case 4:
        return "дня";
      default:
        return "дней";
    }
  }

  String _dateStart(int index){
    String dateStart = '';
    if(Technic.tmpTechnicList[index].dateStartTestDrive != ''){
      dateStart = Technic.tmpTechnicList[index].dateStartTestDrive;
    }
    return dateStart;
  }

  Color _getTileColor(int index){
    Color color = const Color(0xffFFFFFF);
    if(colorForTechnic.isNotEmpty) {
      String dislocation = Technic.tmpTechnicList[index].dislocation;
      color = Color(colorForTechnic[dislocation]!);
      // color = Color(CategoryDropDownValueModel.colorForEquipment[Technic.technicList[index].dislocation]!);
    }
    return color;
  }

  String _nameTechnic(int index){
    String nameTechnic = 'Модель не указана';
    if(Technic.tmpTechnicList[index].name == '') return nameTechnic;
    int lastSymbolNameTechnic = Technic.tmpTechnicList[index].name.length;
    nameTechnic = '${Technic.tmpTechnicList[index].name[0].toUpperCase()}${Technic.tmpTechnicList[index].name.substring(1, lastSymbolNameTechnic).trim()}.';
    return nameTechnic;
  }

  List _getListTestDrive(Technic technic){
    List list = [];
    for(var element in Technic.testDriveList){
      if(technic.id == element.internalID){
        list.add(element);
      }
    }
    return list;
  }
}
