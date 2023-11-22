import 'package:intl/intl.dart';
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
            return ListTile(
                onTap: (){
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => TechnicsEntryViewAndChange(technic: Technic.entityList[index])));
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Repair.repairList[index].internalID == -1 ? _buildTextWithoutBN(context, index) : _buildTextWithBN(context, index),
                subtitle: Repair.repairList[index].dateStartTestDrive == "Нет даты" || Repair.repairList[index].dateFinishTestDrive == "Нет даты"
                    ? _buildTextWithoutTestDrive(context, index) : _buildTextWithTestDrive(context, index)
            );
          },
        )
    );
  }

  Text _buildTextWithBN(BuildContext context, int index){
    return Text('№ ${Repair.repairList[index].internalID}. ${Repair.repairList[index].category}.\n'
        'Жалоба: ${Repair.repairList[index].complaint}.' );
  }

  Text _buildTextWithoutBN(BuildContext context, int index){
    return Text('Без №. ${Repair.repairList[index].category}.\n'
        'Жалоба: ${Repair.repairList[index].complaint}.' );
  }

  Text _buildTextWithoutTestDrive(BuildContext context, int index){
    return Text(
        'Статус: ${Repair.repairList[index].newStatus == "" ? Repair.repairList[index].status : Repair.repairList[index].newStatus}.\n'
            'Дислокация: ${Repair.repairList[index].newDislocation == "" ? Repair.repairList[index].serviceDislocation : Repair.repairList[index].newDislocation}. '
            '${Repair.repairList[index].dateReceipt == "Нет даты" ?
        (Repair.repairList[index].dateTransferForService == "Нет даты" ? Repair.repairList[index].dateDeparture :
        Repair.repairList[index].dateTransferForService)
            : Repair.repairList[index].dateReceipt}.'
    );
  }

  Text _buildTextWithTestDrive(BuildContext context, int index){
    DateTime finishDate = DateFormat("d MMMM yyyy", "ru_RU").parse(Repair.repairList[index].dateFinishTestDrive);
    DateTime dateNow = DateTime.now();
    Duration duration = finishDate.difference(dateNow);

    return Text.rich(
        TextSpan(
            children:[
              TextSpan(text: 'Статус: ${Repair.repairList[index].newStatus == "" ? Repair.repairList[index].status : Repair.repairList[index].newStatus}.\n'
                  'Дислокация: ${Repair.repairList[index].newDislocation == "" ? Repair.repairList[index].serviceDislocation : Repair.repairList[index].newDislocation}. '
                  '${Repair.repairList[index].dateReceipt == "Нет даты" ? Repair.repairList[index].dateTransferForService : Repair.repairList[index].dateReceipt}.\n'),
              TextSpan(text: 'Начало тест-драйва: ${Repair.repairList[index].dateStartTestDrive}.\n'
                  'Конец тест-драйва: ${Repair.repairList[index].dateFinishTestDrive}.\n',
                  style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              duration.inDays > 0 ? TextSpan(
                  text: 'Осталось дней до конца тест-драйва: ${duration.inDays}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
              ) : const TextSpan(
                  text: 'Тест-драйв окончен',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
              )
            ]
        )
    );
  }

}




