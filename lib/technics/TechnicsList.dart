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
        body: ListView.builder(
          // separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: Technic.technicList.length,
          itemBuilder: (context, index) {
            // return Text(Technic.entityList[index].toString());
            return ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicViewAndChange(technic: Technic.technicList[index])));
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text('№ ${Technic.technicList[index].internalID}  ${Technic.technicList[index].name}  ${Technic.technicList[index].category}'),
              subtitle: Technic.technicList[index].dateStartTestDrive != 'Нет даты' ? _buildTextWithTestDrive(context, index) : _buildTextWithoutTestDrive(context, index),
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
    DateTime finishDate;
    DateTime dateNow;
    Duration duration = Duration(days: 0);
    bool isFinishDay = false;
    bool isEndTD = Technic.technicList[index].checkboxTestDrive;

    if(Technic.technicList[index].dateFinishTestDrive != 'Нет даты'){
      finishDate = DateFormat("d MMMM yyyy", "ru_RU").parse(Technic.technicList[index].dateFinishTestDrive);
      dateNow = DateTime.now();
      duration = finishDate.difference(dateNow);
      isFinishDay = true;
    }

    return Text.rich(
        TextSpan(
            children:[
              TextSpan(text:
                  '${Technic.technicList[index].dislocation}.  Статус: ${Technic.technicList[index].status}\n'),
              isFinishDay ?
              TextSpan(children: [
                TextSpan(text:
                  'Начало тест-драйва: ${Technic.technicList[index].dateStartTestDrive}.\n'
                  'Конец тест-драйва: ${Technic.technicList[index].dateFinishTestDrive}.\n',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                duration.inDays > 0 ?
                    TextSpan(
                    text: 'Осталось дней до конца тест-драйва: ${duration.inDays}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
                ) : TextSpan(
                    text: Technic.technicList[index].checkboxTestDrive ? 'Период тест-драйва завершен' : 'Тест-драйв завершен',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Technic.technicList[index].checkboxTestDrive ? Colors.green : Colors.blue)
                )
                  ]
              ) :
              TextSpan(children:[
                TextSpan(text: 'Дата тест-драйва: ${Technic.technicList[index].dateStartTestDrive}.'),
                TextSpan(text: Technic.technicList[index].checkboxTestDrive ? 'Тест-драйв завершен' : 'Тест-драйв не завершен')
              ]
              ),
            ]
        )
    );
  }
}



