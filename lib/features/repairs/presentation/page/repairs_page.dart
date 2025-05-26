import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/features/repairs/presentation/page/repair_add.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/utils/formatters.dart';
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
    final double height = MediaQuery.sizeOf(context).height;
    final double width = MediaQuery.sizeOf(context).width;
    final double aspectRatio = height / width;
    double paddingBottomFloatingActionButton = aspectRatio > 2 ? height / 11 : height / 9;
    return Scaffold (
        appBar: AppBar(title: Text('Ремонты'),),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: paddingBottomFloatingActionButton),
          child: FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text('Новая заявка'),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RepairAdd()));
              },),
        ),
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

    if(repair.numberTechnic != -1){
      return Text.rich(TextSpan(children:
        [TextSpan(text: '№ ${repair.numberTechnic}. ${repair.category}.\n',
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
    String repairLastDate = 'Забрали с точки: ${getDateFormatForInterface(repair.dateDeparture)}.';

    if(repair.dateTransferInService != null){
      repairLastDate = 'Сдали в ремонт: ${getDateFormatForInterface(repair.dateTransferInService ?? DateTime.now())}.';
    }
    if(repair.dateDepartureFromService != null){
      repairLastDate = 'Забрали из ремонта: ${getDateFormatForInterface(repair.dateDepartureFromService ?? DateTime.now())}.';
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
}




