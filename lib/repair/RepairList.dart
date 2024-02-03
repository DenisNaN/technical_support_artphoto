import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/repair/RepairViewAndChange.dart';
import '../utils/hasNetwork.dart';
import 'Repair.dart';
import 'package:flutter/material.dart';
import 'RepairAdd.dart';

class RepairList extends StatefulWidget {
  const RepairList({super.key});

  @override
  State<RepairList> createState() => _RepairListState();
}

class _RepairListState extends State<RepairList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
        floatingActionButton: FloatingActionButton(
            backgroundColor: HasNetwork.isConnecting ? Colors.blue : Colors.grey,
            onPressed: HasNetwork.isConnecting ? () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RepairAdd())).then((value) {
                setState(() {
                  if(value != null) Repair.repairList.insert(0, value);
                });
              });
            } : null,
            child: const Icon(Icons.add, color: Colors.white)),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemCount: Repair.repairList.length,
          itemBuilder: (context, index) {
            Repair repair = Repair.repairList[index];
            Color tileColor = getColorForList(repair);

            return ListTile(
              tileColor: tileColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => RepairViewAndChange(repair: repair))).then((value) {
                    setState(() {
                      if (value != null) Repair.repairList[index] = value;
                    });
                  });
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: repair.internalID == -1 ? _buildTextWithoutBN(context, index) : _buildTextWithBN(context, index),
                subtitle: _buildTextSubtitle(context, index)
            );
          },
        )
    );
  }

  Text _buildTextWithBN(BuildContext context, int index){
    String repairComplaint = 'Не внесли данные.';
    if(Repair.repairList[index].complaint != '' && Repair.repairList[index].complaint != null){
      repairComplaint = '${Repair.repairList[index].complaint}.';
    }

    return Text('№ ${Repair.repairList[index].internalID}. ${Repair.repairList[index].category}.\n'
        'Жалоба: $repairComplaint');
  }

  Text _buildTextWithoutBN(BuildContext context, int index){
    String repairComplaint = 'Не внесли данные.';
    if(Repair.repairList[index].complaint != '' && Repair.repairList[index].complaint != null){
      repairComplaint = '${Repair.repairList[index].complaint}.';
    }

    return Text('Без №. ${Repair.repairList[index].category}.\n'
        'Жалоба: $repairComplaint');
  }

  Text _buildTextSubtitle(BuildContext context, int index){
    String repairStatus = 'Отсутствует.';
    if(Repair.repairList[index].status != '' && Repair.repairList[index].status != null){
        if(Repair.repairList[index].newStatus != '' && Repair.repairList[index].newStatus != null){
          repairStatus = '${Repair.repairList[index].newStatus}.';
        } else {
          repairStatus = '${Repair.repairList[index].status}.';
        }
    }
    String repairDislocation = 'Отсутствует.';
    if(Repair.repairList[index].dislocationOld != '' && Repair.repairList[index].dislocationOld != null){
      if(Repair.repairList[index].newDislocation != '' && Repair.repairList[index].newDislocation != null){
        repairDislocation = '${Repair.repairList[index].newDislocation}.';
      } else {
        repairDislocation = '${Repair.repairList[index].dislocationOld}.';
      }
    }
    String repairLastDate = 'Даты отсутствуют.';
    if(Repair.repairList[index].dateDeparture != '') {
      repairLastDate = 'Забрали с точки: ${getDateFormat(Repair.repairList[index].dateDeparture)}.';
    }
    if(Repair.repairList[index].dateTransferInService != ''){
      repairLastDate = 'Сдали в ремонт: ${getDateFormat(Repair.repairList[index].dateTransferInService)}.';
    }
    if(Repair.repairList[index].dateDepartureFromService != ''){
      repairLastDate = 'Забрали из ремонта: ${getDateFormat(Repair.repairList[index].dateDepartureFromService)}.';
    }

    return Text(
            'Статус: $repairStatus\n'
            'Дислокация: $repairDislocation\n'
            '$repairLastDate'
    );
  }

  Color getColorForList(Repair repair){
    Color color = Colors.white;
    String resultColor = fieldsFilled(repair);
    switch(resultColor){
      case 'red':
        color = Colors.red.shade200;
        break;
      case 'yellow':
        color = Colors.yellow.shade200;
        break;
      case 'green':
        color = Colors.green.shade200;
        break;
    }
    return color;
  }

  String fieldsFilled(Repair repair){
    String result = 'yellow';
    if(repair.complaint != '' &&
        repair.dateDeparture != '' &&
        repair.dateTransferInService != '' &&
        repair.serviceDislocation != '' &&
        repair.dateDepartureFromService != '' &&
        repair.worksPerformed != '' &&
        repair.costService != 0 &&
        repair.diagnosisService != '' &&
        repair.dateReceipt != '' &&
        repair.newStatus != '' &&
        repair.newDislocation != ''){
      return 'green';
    }
    if(repair.dateTransferInService == '' ||
        repair.serviceDislocation == ''){
      return 'red';
    }
    return result;
  }

  String getDateFormat(String date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }
}




