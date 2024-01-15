import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/history/History.dart';
import 'package:flutter/material.dart';

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
            // bool isDoneHistory = isAllFieldsFilled(Repair.repairList[index]);

            return ListTile(
                // onTap: () {
                //   Navigator.push(context, MaterialPageRoute(
                //       builder: (context) => RepairViewAndChange(repair: Repair.repairList[index])))
                //       .then((value) {
                //     setState(() {
                //       if (value != null) {
                //         Repair.repairList[index] = value;
                //       }
                //     });
                //   });
                // },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: _buildText(context, index)
            );
          },
        )
    );
  }

  // bool isAllFieldsFilled(Repair repair){
  //   bool result = false;
  //   if(repair.complaint != '' &&
  //       repair.dateDeparture != '' &&
  //       repair.dateTransferForService != '' &&
  //       repair.serviceDislocation != '' &&
  //       repair.dateDepartureFromService != '' &&
  //       repair.worksPerformed != '' &&
  //       repair.costService != null &&
  //       repair.diagnosisService != '' &&
  //       // repair.recommendationsNotes != '' &&
  //       repair.dateReceipt != '' &&
  //       repair.newStatus != '' &&
  //       repair.newDislocation != ''){
  //     result = true;
  //   }
  //   return result;
  // }

  Text _buildText(BuildContext context, int index){
    String section = '';
    String typeOperation = '';
    switch(History.historyList[index].section){
      case 'Technick':
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




