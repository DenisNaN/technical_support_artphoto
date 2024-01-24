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
            bool isDoneRepair = isAllFieldsFilled(Repair.repairList[index]);

            return ListTile(
              tileColor: isDoneRepair ? Colors.lightGreenAccent : null,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => RepairViewAndChange(repair: Repair.repairList[index])))
                      .then((value) {
                    setState(() {
                      if (value != null) {
                        Repair.repairList[index] = value;
                      }
                    });
                  });
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Repair.repairList[index].internalID == -1 ? _buildTextWithoutBN(context, index) : _buildTextWithBN(context, index),
                subtitle: _buildTextWithoutTestDrive(context, index)
            );
          },
        )
    );
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
            'Дислокация: ${Repair.repairList[index].newDislocation == "" ?
            Repair.repairList[index].serviceDislocation :
            Repair.repairList[index].newDislocation}. '
            '${Repair.repairList[index].dateReceipt == "" ? (Repair.repairList[index].dateTransferForService == "" ?
            getDateFormat(Repair.repairList[index].dateDeparture) :
            getDateFormat(Repair.repairList[index].dateTransferForService)) :
            getDateFormat(Repair.repairList[index].dateReceipt)}'
    );
  }

  String getDateFormat(String date) {
    return DateFormat("d MMMM yyyy", "ru_RU").format(DateTime.parse(date.replaceAll('.', '-')));
  }
}




