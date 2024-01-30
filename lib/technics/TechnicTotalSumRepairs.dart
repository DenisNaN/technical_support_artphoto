import 'package:flutter/material.dart';
import '../repair/Repair.dart';
import '../repair/RepairViewAndChange.dart';
import 'package:intl/intl.dart';

class TechnicTotalSumRepairs extends StatelessWidget{
  final int internalId;
  const TechnicTotalSumRepairs({super.key, required this.internalId});

  @override
  Widget build(BuildContext context) {
    List listTotalSumRepair = _getListTotalSumRepairs(internalId);

    return Scaffold(
      appBar: AppBar(title: const Text('Свод ремонтов по технике')),
      body: ListView.builder(
          itemCount: listTotalSumRepair.length,
          itemBuilder: (context, index){
            return ListTile(
              title: _buildText(context),
              // onTap: (){
              //   Navigator.push(
              //       context, MaterialPageRoute(
              //       builder: (context) => RepairViewAndChange(repair: repairFind)));
              // },
            );
          }
      ),
    );
  }

  Text _buildText(BuildContext context){
    int index = _getIndex();
    return Text.rich(
        TextSpan(children: [
          TextSpan(text: '№ - ${Repair.repairList[index].internalID}\n'),
          TextSpan(text: 'Наименование: ${Repair.repairList[index].category}\n'),
          TextSpan(text: 'Жалоба: ${Repair.repairList[index].complaint}\n'),
          TextSpan(text: 'Забрали с точки: ${getDateFormat(Repair.repairList[index].dateDeparture)}\n')
        ]
        )
    );
  }

  int _getIndex(){
    int index = -1;
    Repair.repairList.forEach((element) {
      if(element.internalID == internalId){
        index = Repair.repairList.indexOf(element);
      }
    });
    return index;
  }

  List _getListTotalSumRepairs(int internalID){
    List totalSumRepairs = [];
    for(TotalSumRepairs element in Repair.totalSumRepairs){
      if(element.idTechnic == internalID){
        totalSumRepairs.add(element);
      }
    }
    return totalSumRepairs;
  }

  String getDateFormat(String date) {
    if(date == '') return 'Нет даты';
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }
}