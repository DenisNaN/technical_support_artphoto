import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/core/utils/extension.dart';
import 'package:technical_support_artphoto/features/repairs/presentation/page/repair_add.dart';
import 'package:technical_support_artphoto/features/repairs/presentation/page/repair_view.dart';
import '../../../../core/api/data/repositories/technical_support_repo_impl.dart';
import '../../../../core/api/provider/provider_model.dart';
import '../../../../core/navigation/animation_navigation.dart';
import '../../../../core/shared/custom_app_bar/custom_app_bar.dart';
import '../../../../core/shared/logo_animate/logo_matrix_transition_animate.dart';
import '../../../../core/utils/enums.dart';
import '../../../home/presentation/widgets/my_custom_refresh_indicator.dart';
import '../../models/repair.dart';
import '../widget/popup_menu_repairs_page.dart';

class RepairsPage extends StatefulWidget {
  const RepairsPage({super.key, required this.isCurrentRepairs});

  final bool isCurrentRepairs;

  @override
  State<RepairsPage> createState() => _RepairsPageState();
}

class _RepairsPageState extends State<RepairsPage> {
  final _controller = IndicatorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.isCurrentRepairs ? AppBar(
          title: Text('Ремонты'),
          actions: [
            PopupMenuRepairPage()
          ],
        ) : AppBar(
          title: Text('Завершенные ремонты'),
        ),
        floatingActionButton: widget.isCurrentRepairs ? FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text('Новая заявка'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoadingOverlay(child: RepairAdd())));
          },
        ) : null,
        body: widget.isCurrentRepairs ?
        _buildBodyCurrentRepairs() :
        _buildBodyFinishedRepairs()
    );
  }

  Widget _buildBodyFinishedRepairs() {
    return FutureBuilder(
        future: TechnicalSupportRepoImpl.downloadData.getFinishedRepairs(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final List<Repair> repairs = snapshot.data;
            repairs.sort();
            return SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: repairs.length,
                itemBuilder: (context, index) {
                  Repair repair = repairs[index];
                  return Container(
                    margin: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 8),
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.green.shade100, boxShadow: const [
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
                            animationRouteSlideTransition(LoadingOverlay(child: RepairView(repair: repair))));
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
            );
          } else if (snapshot.hasError) {
            return Scaffold(
                appBar: CustomAppBar(typePage: TypePage.error, location: 'Произошел сбой', technic: null),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off,
                        size: 150,
                        color: Colors.blue,
                        shadows: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.5),
                            spreadRadius: 3,
                            blurRadius: 4,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      Text(
                        'Данные не загрузились.\nПроверьте подключение к сети',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ));
          } else {
            return Center(child: MatrixTransitionLogo());
          }
        },
    );
  }

  Widget _buildBodyCurrentRepairs() {
    final providerModel = Provider.of<ProviderModel>(context);
    final List<Repair> repairs = providerModel.getCurrentRepairs;
    return SafeArea(
        child: WarpIndicator(
          controller: _controller,
          onRefresh: () => TechnicalSupportRepoImpl.downloadData.refreshCurrentRepairsData().then((resultData) {
            providerModel.refreshCurrentRepairs(resultData);
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
                        animationRouteSlideTransition(LoadingOverlay(child: RepairView(repair: repair))));
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
      );
  }

  Text _buildTextTitle(Repair repair) {
    String repairComplaint = 'Не внесли данные.';
    if (repair.complaint != '') {
      repairComplaint = '${repair.complaint}.';
    }

    if (repair.numberTechnic != -1 || repair.numberTechnic != 0) {
      return Text.rich(TextSpan(children: [
        TextSpan(
            text: '№ ${repair.numberTechnic != 0 ? repair.numberTechnic : 'БН'}. ${repair.category}.\n',
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
    String repairLastDate = 'Забрали с точки: ${repair.dateDeparture.dateFormattedForInterface()}.';

    if (repair.dateTransferInService.toString() == "-0001-11-30 00:00:00.000Z" ||
        repair.dateTransferInService.toString() == "0001-11-30 00:00:00.000Z") {}else{
      repairLastDate = 'Сдали в ремонт: ${repair.dateTransferInService?.dateFormattedForInterface() ?? DateTime.now().dateFormattedForInterface()}.';
    }
    if (repair.dateDepartureFromService.toString() != "-0001-11-30 00:00:00.000Z" ||
        repair.dateDepartureFromService.toString() != "0001-11-30 00:00:00.000Z") {}else{
      repairLastDate =
      'Забрали из ремонта: ${repair.dateDepartureFromService?.dateFormattedForInterface() ?? DateTime.now().dateFormattedForInterface()}.';
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
    if (repair.serviceDislocation == null ||
        repair.serviceDislocation == '' ||
        repair.dateTransferInService.toString() == "-0001-11-30 00:00:00.000Z" ||
        repair.dateTransferInService.toString() == "0001-11-30 00:00:00.000Z") {
      return 'red';
    }
    return 'yellow';
  }
}
