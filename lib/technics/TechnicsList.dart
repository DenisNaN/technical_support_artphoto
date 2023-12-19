import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        floatingActionButton: FloatingActionButton(
            backgroundColor: HasNetwork.isConnecting ? Colors.blue : Colors.grey,
            onPressed: HasNetwork.isConnecting ? () {Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicAdd())).then((value) {
              setState(() {
                if(value != null) Technic.technicList.insert(0, value);
              });
            });
            } : null,
            child: const Icon(Icons.add, color: Colors.white)
            ),
        body: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: Technic.technicList.length,
          itemBuilder: (context, index) {
            String dateStart = '';
            if(Technic.technicList[index].dateStartTestDrive != ''){
              dateStart = Technic.technicList[index].dateStartTestDrive;
            }
            return ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.technicList[index]))).then(
                  (value){
                    setState(() {
                      if(value != null) Technic.technicList[index] = value;
                    });
                  });
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text('№ ${Technic.technicList[index].internalID}  ${Technic.technicList[index].name}  ${Technic.technicList[index].category}'),
              subtitle: dateStart != '' ? _buildTextWithTestDrive(context, index) : _buildTextWithoutTestDrive(context, index),
            );
          },
        )
    );
  }

  Text _buildTextWithoutTestDrive(BuildContext context, int index){
    return Text(
            '${Technic.technicList[index].dislocation}.  Статус: ${Technic.technicList[index].status}\n'
            'Тест-драйв не проводился'
    );
  }

  Text _buildTextWithTestDrive(BuildContext context, int index){
    DateTime dateStart = DateTime.parse(Technic.technicList[index].dateStartTestDrive.replaceAll('.', '-'));
    DateTime dateFinish;
    DateTime dateNow;
    String formatedStartDate = DateFormat("d MMMM yyyy", "ru_RU").format(dateStart);
    String formatedFinishDate = '';
    Duration duration = Duration(days: 0);
    bool isHaveFinishDate = false;
    bool isEndTD = Technic.technicList[index].checkboxTestDrive;

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
              TextSpan(text:
                  '${Technic.technicList[index].dislocation}.  Статус: ${Technic.technicList[index].status}\n'),
              isHaveFinishDate ?
              TextSpan(children: [
                TextSpan(text:
                  'Начало тест-драйва: $formatedStartDate.\n'
                  'Конец тест-драйва: $formatedFinishDate.\n'),
                duration.inDays > 0 ?
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
            ]
        )
    );
  }
}



