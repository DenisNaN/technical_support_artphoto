import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/history/History.dart';
import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/trouble/Trouble.dart';
import 'package:technical_support_artphoto/trouble/TroubleViewAndChange.dart';
import '../repair/Repair.dart';
import '../repair/RepairViewAndChange.dart';
import '../technics/Technic.dart';
import '../technics/TechnicViewAndChange.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: History.historyList.length,
          itemBuilder: (context, index) {
            return ListTile(
                onTap: () {
                  switch(History.historyList[index].section){
                    case 'Technic':
                      Technic technicFind = Technic.technicList.firstWhere((item) => item.id == History.historyList[index].idSection);
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => TechnicViewAndChange(technic: technicFind)));
                      break;
                    case 'Repair':
                      Repair repairFind = Repair.repairList.firstWhere((item) => item.id == History.historyList[index].idSection);
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => RepairViewAndChange(repair: repairFind)));
                      break;
                    case 'Trouble':
                      Trouble troubleFind = Trouble.troubleList.firstWhere((item) => item.id == History.historyList[index].idSection);
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (context) => TroubleViewAndChange(trouble: troubleFind)));
                      break;
                  }
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: _buildText(context, index)
            );
          },
        )
    );
  }

  Text _buildText(BuildContext context, int index){
    String section = '';
    String typeOperation = '';
    switch(History.historyList[index].section){
      case 'Technic':
        section = 'Техника';
        break;
      case 'Repair':
        section = 'Ремонт';
        break;
      case 'Trouble':
        section = 'Неисправность';
        break;
    }
    switch(History.historyList[index].typeOperation){
      case 'edit':
        typeOperation = 'Изменение записи';
        break;
      case 'create':
        typeOperation = 'Новая запись';
        break;
    }

    return Text.rich(
          TextSpan(children: [
            TextSpan(text: '$typeOperation $section. ${History.historyList[index].login}\n',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: '${History.historyList[index].description}')
          ]
        )
    );
  }

  String getDateFormat(String date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }
}




