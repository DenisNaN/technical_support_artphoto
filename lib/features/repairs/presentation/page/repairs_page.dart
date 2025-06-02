import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/features/repairs/presentation/page/repair_add.dart';
import 'package:technical_support_artphoto/features/repairs/presentation/page/repair_view.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../../core/utils/formatters.dart';
import '../../../home/presentation/widgets/my_custom_refresh_indicator.dart';
import '../../models/repair.dart';
import '../widget/menu_repairs_page.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key});

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    final List<Repair> repairs = providerModel.getAllRepairs;
    return Scaffold(
        appBar: AppBar(
          title: Text('Ремонты'),
          actions: [
            MenuRepairPage()
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Новая заявка'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RepairAdd()));
          },
        ),
        body: SafeArea(
          child: WarpIndicator(
            controller: _controller,
            onRefresh: () => TechnicalSupportRepoImpl.downloadData.refreshRepairsData().then((resultData) {
              providerModel.refreshRepairs(resultData);
            }),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: repairs.length,
              itemBuilder: (context, index) {
                Repair repair = repairs[index];
                Color tileColor = getColorForList(repair);

                return Container(
                  margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10), color: tileColor, boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: Offset(2, 4), // Shadow position
                    ),
                  ]),
                  padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(context,
                          animationRouteSlideTransition(RepairView(repair: repair)));
                    },
                    title: _buildTextTitle(repair),
                    subtitle: _buildTextSubtitle(repair),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Text _buildTextTitle(Repair repair) {
    String repairComplaint = 'Не внесли данные.';
    if (repair.complaint != '') {
      repairComplaint = '${repair.complaint}.';
    }

    if (repair.numberTechnic != -1 || repair.numberTechnic != 0) {
      return Text.rich(TextSpan(children: [
        TextSpan(
            text: '№ ${repair.numberTechnic}. ${repair.category}.\n',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: 'Жалоба: $repairComplaint')
      ]));
    } else {
      return Text.rich(TextSpan(children: [
        TextSpan(text: 'Без №. ${repair.category}.\n', style: const TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: 'Жалоба: $repairComplaint')
      ]));
    }
  }

  Text _buildTextSubtitle(Repair repair) {
    String repairStatus = 'Отсутствует.';
    if (repair.status != '') {
      if (repair.newStatus != '') {
        repairStatus = '${repair.newStatus}.';
      } else {
        repairStatus = '${repair.status}.';
      }
    }
    String repairDislocation = 'Отсутствует.';
    if (repair.dislocationOld != '') {
      if (repair.newDislocation != '') {
        repairDislocation = '${repair.newDislocation}.';
      } else {
        repairDislocation = '${repair.dislocationOld}.';
      }
    }
    String repairLastDate = 'Забрали с точки: ${getDateFormatForInterface(repair.dateDeparture)}.';

    if (repair.dateTransferInService.toString() != "-0001-11-30 00:00:00.000Z") {
      repairLastDate = 'Сдали в ремонт: ${getDateFormatForInterface(repair.dateTransferInService ?? DateTime.now())}.';
    }
    if (repair.dateDepartureFromService.toString() != "-0001-11-30 00:00:00.000Z") {
      repairLastDate =
          'Забрали из ремонта: ${getDateFormatForInterface(repair.dateDepartureFromService ?? DateTime.now())}.';
    }
    return Text('Статус: $repairStatus\n'
        'Дислокация: $repairDislocation\n'
        '$repairLastDate');
  }

  Color getColorForList(Repair repair) {
    Color color = Colors.white;
    String resultColor = fieldsFilled(repair);
    switch (resultColor) {
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

  String fieldsFilled(Repair repair) {
    if (repair.serviceDislocation == '') {
      return 'red';
    }
    return 'yellow';
  }
}
