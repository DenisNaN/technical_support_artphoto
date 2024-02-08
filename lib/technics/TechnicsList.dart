import 'package:flutter/material.dart';
import '../repair/Repair.dart';
import '../utils/categoryDropDownValueModel.dart';
import 'Technic.dart';
import 'TechnicAdd.dart';
import 'TechnicViewAndChange.dart';
import 'package:technical_support_artphoto/utils/hasNetwork.dart';
import 'package:intl/intl.dart';

class TechnicsList extends StatefulWidget {
  const TechnicsList({super.key});

  @override
  State<TechnicsList> createState() => _TechnicsListState();
}

class _TechnicsListState extends State<TechnicsList> {
  Map<String, int> colorForTechnic = {};

  @override
  void initState() {
    super.initState();
    colorForTechnic.addAll(CategoryDropDownValueModel.colorForEquipment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        floatingActionButton: FloatingActionButton(
            backgroundColor: HasNetwork.isConnecting ? Colors.blue : Colors.grey,
            onPressed: HasNetwork.isConnecting ? () {Navigator.push(context, MaterialPageRoute(builder: (context) => const TechnicAdd())).then((value) {
              setState(() {
                if(value != null) Technic.technicList.insert(0, value);
              });
            });
            } : null,
            child: const Icon(Icons.add, color: Colors.white)
            ),
        body: ListView.builder(
          // separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: Technic.technicList.length,
          itemBuilder: (context, index) {
            String dateStart = _dateStart(index);
            Color color = _getTileColor(index);
            String nameTechnic = _nameTechnic(index);
            return Material(
                child: ListTile(
                  tileColor: color,
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.technicList[index]))).then((value){
                        setState(() {
                          if(value != null) Technic.technicList[index] = value;
                        });
                      });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text.rich(TextSpan(children: [
                    TextSpan(text: '№ ${Technic.technicList[index].internalID} '),
                    TextSpan(text: '${Technic.technicList[index].category}. ', style: const TextStyle(fontWeight: FontWeight.bold), ),
                    TextSpan(text: nameTechnic)
                  ])),
                  subtitle: dateStart != '' ? _buildTextWithTestDrive(context, index) : _buildTextWithoutTestDrive(context, index),
                ));
          },
        )
    );
  }

  Text _buildTextWithoutTestDrive(BuildContext context, int index){
    int totalSumRepairs = _getTotalSumRepairs(index);
    Color color = const Color(0xff000000);
    return Text.rich(TextSpan(children: [
      TextSpan(text: '${Technic.technicList[index].dislocation}.',
        style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      TextSpan(text: ' Статус: ${Technic.technicList[index].status}\n'
          'Тест-драйв не проводился\n'),
      TextSpan(text: totalSumRepairs != 0 ? 'Итоговая сумма ремонта: $totalSumRepairs р.' :
      'Ремонт не проводился'),
      ])
    );
  }

  Text _buildTextWithTestDrive(BuildContext context, int index){
    DateTime dateStart = DateTime.parse(Technic.technicList[index].dateStartTestDrive.replaceAll('.', '-'));
    DateTime dateFinish;
    DateTime dateNow;
    String formatedStartDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateStart);
    String formatedFinishDate = '';
    Duration duration = const Duration(days: 0);
    bool isHaveFinishDate = false;
    int totalSumRepairs = _getTotalSumRepairs(index);
    Color color = const Color(0xff000000);

    if(Technic.technicList[index].dateFinishTestDrive != ''){
      dateFinish = DateTime.parse(Technic.technicList[index].dateFinishTestDrive.replaceAll('.', '-'));
      formatedFinishDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateFinish);
      dateNow = DateTime.now();
      duration = dateFinish.difference(dateNow);
      isHaveFinishDate = true;
    }
    return Text.rich(
        TextSpan(
            children:[
              TextSpan(
                text: '${Technic.technicList[index].dislocation}. ',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color)),
              TextSpan(text:
                  'Статус: ${Technic.technicList[index].status}\n'),
              isHaveFinishDate ?
              TextSpan(children: [
                TextSpan(text: 'Итоговая сумма ремонта: $totalSumRepairs р.\n'),
                TextSpan(text:
                  'Начало тест-драйва: $formatedStartDate.\n'
                  'Конец тест-драйва: $formatedFinishDate.\n'),
                duration.inDays > 0 && !Technic.technicList[index].checkboxTestDrive ?
                    TextSpan(
                    text: 'Осталось дней до конца тест-драйва: ${duration.inDays}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
                ) : TextSpan(
                    text: !Technic.technicList[index].checkboxTestDrive ?
                    'Период тест-драйва завершен' :
                    'Тест-драйв завершен',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Technic.technicList[index].checkboxTestDrive ? Colors.green : Colors.blue)
                )
                  ]
              ) :
              TextSpan(children:[
                TextSpan(text: 'Дата тест-драйва: $formatedStartDate.\n'),
                TextSpan(text: Technic.technicList[index].checkboxTestDrive ? 'Тест-драйв завершен' : 'Тест-драйв не завершен',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Technic.technicList[index].checkboxTestDrive ? Colors.green : Colors.blue)
                )
              ]
              ),
              TextSpan(text: totalSumRepairs != 0 ? '\nИтоговая сумма ремонта: $totalSumRepairs р.' :
              '\nРемонт не проводился')
            ]
        )
    );
  }

  String _dateStart(int index){
    String dateStart = '';
    if(Technic.technicList[index].dateStartTestDrive != ''){
      dateStart = Technic.technicList[index].dateStartTestDrive;
    }
    return dateStart;
  }

  Color _getTileColor(int index){
    Color color = const Color(0xffFFFFFF);
    if(colorForTechnic.isNotEmpty) {
      String dislocation = Technic.technicList[index].dislocation;
      color = Color(colorForTechnic[dislocation]!);
      // color = Color(CategoryDropDownValueModel.colorForEquipment[Technic.technicList[index].dislocation]!);
    }
    return color;
  }

  String _nameTechnic(int index){
    String nameTechnic = 'Модель не указана';
    if(Technic.technicList[index].name == '') return nameTechnic;
    int lastSymbolNameTechnic = Technic.technicList[index].name.length;
    nameTechnic = '${Technic.technicList[index].name[0].toUpperCase()}${Technic.technicList[index].name.substring(1, lastSymbolNameTechnic).trim()}.';
    return nameTechnic;
  }

  int _getTotalSumRepairs(int index){
    int totalSumRepairs = 0;
    for(TotalSumRepairs element in Repair.totalSumRepairs){
      if(element.idTechnic == Technic.technicList[index].internalID){
        int coastReapair = element.sumRepair;
        totalSumRepairs += coastReapair;
      }
    }
    return totalSumRepairs;
  }
}



