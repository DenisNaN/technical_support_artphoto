import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../models/repair.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key});

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    final List<Repair> repairs = providerModel.getAllRepairs;
    return Scaffold (
        appBar: AppBar(title: Text('Ремонты'),),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const RepairAdd())).then((value) {
              //   setState(() {
              //     if(value != null) Repair.repairList.insert(0, value);
              //   });
              // });
            },
            child: const Icon(Icons.add, color: Colors.white)),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: repairs.length,
          itemBuilder: (context, index) {
            Repair repair = repairs[index];
            Color tileColor = getColorForList(repair);

            return Container(
              margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: tileColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: Offset(2, 4), // Shadow position
                    ),
                  ]
              ),
              padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
              child: ListTile(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(
                    //     builder: (context) => RepairViewAndChange(repair: repair))).then((value) {
                    //   setState(() {
                    //     if (value != null) Repair.repairList[index] = value;
                    //   });
                    // });
                  },
                  title: _buildTextTitle(context, repair),
                  subtitle: _buildTextSubtitle(context, repair),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        )
    );
  }

  Text _buildTextTitle(BuildContext context, Repair repair){
    String repairComplaint = 'Не внесли данные.';
    if(repair.complaint != ''){
      repairComplaint = '${repair.complaint}.';
    }

    if(repair.number != -1){
      return Text.rich(TextSpan(children:
        [TextSpan(text: '№ ${repair.number}. ${repair.category}.\n',
          style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: 'Жалоба: $repairComplaint')
        ]
      ));
    } else{
      return Text.rich(TextSpan(children:
      [TextSpan(text: 'Без №. ${repair.category}.\n',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: 'Жалоба: $repairComplaint')
      ]
      ));
    }
  }

  Text _buildTextSubtitle(BuildContext context, Repair repair){
    String repairStatus = 'Отсутствует.';
    if(repair.status != ''){
        if(repair.newStatus != ''){
          repairStatus = '${repair.newStatus}.';
        } else {
          repairStatus = '${repair.status}.';
        }
    }
    String repairDislocation = 'Отсутствует.';
    if(repair.dislocationOld != ''){
      if(repair.newDislocation != ''){
        repairDislocation = '${repair.newDislocation}.';
      } else {
        repairDislocation = '${repair.dislocationOld}.';
      }
    }
    String repairLastDate = 'Даты отсутствуют.';
    if(repair.dateDeparture != '') {
      repairLastDate = 'Забрали с точки: ${getDateFormat(repair.dateDeparture)}.';
    }
    if(repair.dateTransferInService != ''){
      repairLastDate = 'Сдали в ремонт: ${getDateFormat(repair.dateTransferInService)}.';
    }
    if(repair.dateDepartureFromService != ''){
      repairLastDate = 'Забрали из ремонта: ${getDateFormat(repair.dateDepartureFromService)}.';
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
        color = Colors.deepOrange.shade100;
        break;
      case 'yellow':
        color = Colors.yellow.shade100;
        break;
      case 'green':
        color = Colors.green.shade100;
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




