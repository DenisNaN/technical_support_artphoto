import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:technical_support_artphoto/features/history/history.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        body: ListView.builder(
          itemCount: History.historyList.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: Offset(2, 4), // Shadow position
                    ),
                  ]
              ),
              child: ListTile(
                  onTap: () {
                    // switch(History.historyList[index].section){
                    //   case 'Technic':
                    //     Technic technicFind = Technic.technicList.firstWhere((item) => item.id == History.historyList[index].idSection);
                    //     Navigator.push(
                    //         context, MaterialPageRoute(
                    //         builder: (context) => TechnicViewAndChange(technic: technicFind)));
                    //     break;
                    //   case 'Repair':
                    //     Repair repairFind = Repair.repairList.firstWhere((item) => item.id == History.historyList[index].idSection);
                    //     Navigator.push(
                    //         context, MaterialPageRoute(
                    //         builder: (context) => RepairViewAndChange(repair: repairFind)));
                    //     break;
                    //   case 'Trouble':
                    //     Trouble troubleFind = Trouble.troubleList.firstWhere((item) => item.id == History.historyList[index].idSection);
                    //     Navigator.push(
                    //         context, MaterialPageRoute(
                    //         builder: (context) => TroubleViewAndChange(trouble: troubleFind)));
                    //     break;
                    // }
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: _buildText(context, index)
              ),
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




