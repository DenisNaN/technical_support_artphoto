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
      appBar: AppBar(title: Text('Ремонты техники №$internalId')),
      body: ListView.builder(
          itemCount: listTotalSumRepair.length,
          itemBuilder: (context, index){
            Repair? repair = _getRepair(index);
            bool isDoneRepair = isAllFieldsFilled(repair!);
            return ListTile(
              title: _buildText(context, index),
              tileColor: isDoneRepair ? Colors.lightGreenAccent : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              onTap: (){
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => RepairViewAndChange(repair: repair)));
              },
            );
          }
      ),
    );
  }

  Text _buildText(BuildContext context, int index){
    Repair? repair = _getRepair(index);
    if(repair == null){
      return Text('Ошибка загруки данных\n'
          '\nПришел null из _getRepair в TechnicTotalSumRepair._buildText. '
          'index = $index\n'
          'Скриншот отправить Денису');
    }
    return Text.rich(
        TextSpan(children: [
          TextSpan(text: 'Наименование: ${repair.category}\n'),
          TextSpan(text: 'Сумма ремонта: ${repair.costService}\n'),
          TextSpan(text: 'Жалоба: ${repair.complaint}\n'),
          TextSpan(text: 'Забрали с точки: ${getDateFormat(repair.dateDeparture)}\n')
        ]
        )
    );
  }

  Repair? _getRepair(int index){
    List listTotalSumRepair = _getListTotalSumRepairs(internalId);
    TotalSumRepairs totalSumRepair = listTotalSumRepair[index];
    int idRepair = totalSumRepair.idRepair;
    Repair? repair;
    Repair.repairList.forEach((element) {
      if(element.id == idRepair) repair = element;
    });
    return repair;
  }

  List _getListTotalSumRepairs(int internalID){
    List totalSumRepairs = [];
    Repair.totalSumRepairs.forEach((element) {
      if(element.idTechnic == internalID){
        totalSumRepairs.add(element);
      }
    });
    return totalSumRepairs;
  }

  bool isAllFieldsFilled(Repair repair){
    bool result = false;
    if(repair.complaint != '' &&
        repair.dateDeparture != '' &&
        repair.dateTransferForService != '' &&
        repair.serviceDislocation != '' &&
        repair.dateDepartureFromService != '' &&
        repair.worksPerformed != '' &&
        repair.costService != 0 &&
        repair.diagnosisService != '' &&
        // repair.recommendationsNotes != '' &&
        repair.dateReceipt != '' &&
        repair.newStatus != '' &&
        repair.newDislocation != ''){
      result = true;
    }
    return result;
  }

  String getDateFormat(String date) {
    if(date == '') return 'Нет даты';
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }
}