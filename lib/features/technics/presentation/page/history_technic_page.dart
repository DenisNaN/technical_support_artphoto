import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/shared/logo_animate/logo_matrix_transition_animate.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/features/technics/data/models/history_technic.dart';
import 'package:technical_support_artphoto/features/technics/data/models/trouble_technic_on_period.dart';

class HistoryTechnicPage extends StatelessWidget {
  const HistoryTechnicPage({super.key, required this.numberTechnic});

  final String? numberTechnic;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: TechnicalSupportRepoImpl.downloadData.fetchHistoryTechnic(numberTechnic),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<HistoryTechnic> historyList = snapshot.data ?? [];
            return Scaffold(
              appBar: CustomAppBar(
                typePage: TypePage.history,
                location: null,
                technic: null,
              ),
              body: ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    return _listTile(historyList, index);
                  }),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
                appBar: CustomAppBar(typePage: TypePage.error, location: 'Произошел сбой', technic: null),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 150, color: Colors.blue, shadows: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: 3,
                          blurRadius: 4,
                          offset: Offset(0, 4), // changes position of shadow
                        ),
                      ],),
                      Text('Данные не загрузились.\nПроверьте подключение к сети', style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                    ],
                  ),
                ));
          } else {
            return SizedBox(height: 200, child: Center(child: MatrixTransitionLogo()));
          }
        });
  }

  Widget _listTile(List<HistoryTechnic> historyList, int index) {
    bool isStartIndex = index == 0;
    HistoryTechnic currentHistoryTechnic = historyList[index];
    DateTime? finishDate;

    if (currentHistoryTechnic.trouble != null) {
      return SizedBox();
    }
    if (currentHistoryTechnic.location is PhotosalonLocation) {
      if (historyList.length > 1 && index > 0) {
        finishDate = _findDateFinishPhotosalon(historyList, index);
      }
      return _buildListTilePhotosalon(currentHistoryTechnic, isStartIndex, finishDate);
    } else if (currentHistoryTechnic.location is RepairLocation) {
      return _buildListTileRepair(currentHistoryTechnic, isStartIndex, finishDate);
    }
    return SizedBox();
  }

  Widget _buildListTilePhotosalon(
    HistoryTechnic currentHistoryTechnic,
    bool isStartIndex,
    DateTime? finishDate,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: Colors.blue),
          child: Center(
              child: Text(
            (currentHistoryTechnic.location as PhotosalonLocation).name,
            style: TextStyle(fontSize: 20, color: Colors.white),
          )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isStartIndex || finishDate == null
                  ? Text('${DateFormat('dd MMMM yyyy', 'ru').format(currentHistoryTechnic.date)} - по настоящее время',
                      style: TextStyle(fontSize: 18))
                  : Text(
                      '${DateFormat('dd MMMM yyyy', 'ru').format(currentHistoryTechnic.date)} - ${DateFormat('dd MMMM yyyy', 'ru').format(finishDate)}',
                      style: TextStyle(fontSize: 18))
            ],
          ),
        ),
        _getListTroubles(currentHistoryTechnic.listTrouble),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Icon(Icons.arrow_downward),
        ),
      ],
    );
  }

  Widget _buildListTileRepair(
    HistoryTechnic currentHistoryTechnic,
    bool isStartIndex,
    DateTime? finishDate,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: Colors.green.shade300),
          child: Center(
              child: Text(
            (currentHistoryTechnic.location as RepairLocation).name,
            style: TextStyle(fontSize: 20, color: Colors.white),
          )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isStartIndex
                  ? Text('${DateFormat('dd MMMM yyyy', 'ru').format(currentHistoryTechnic.date)} - по настоящее время',
                      style: TextStyle(fontSize: 18))
                  : Text(
                      '${DateFormat('dd MMMM yyyy', 'ru').format(currentHistoryTechnic.date)} - ${DateFormat('dd MMMM yyyy', 'ru').format(currentHistoryTechnic.dateDepartureFromService!)}',
                      style: TextStyle(fontSize: 18))
            ],
          ),
        ),
        Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
              padding: EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 93, 255, 114), width: 1),
                borderRadius: BorderRadius.circular(10),
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 10, bottom: 5),
                child: Text(
                  '${currentHistoryTechnic.worksPerformed}',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
            Positioned(
              left: 50,
              bottom: 2,
              child: Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                color: Colors.grey.shade50,
                child: Text(
                  '${currentHistoryTechnic.costService} р.',
                  style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Icon(Icons.arrow_downward),
        ),
      ],
    );
  }

  Widget _getListTroubles(List<TroubleTechnicOnPeriod> troubles) {
    return Column(
      children: [
        for (int i = 0; i < troubles.length; i++)
          Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
                padding: EdgeInsets.only(bottom: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 51, 204, 255), width: 1),
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 10),
                  child: Text(
                    '${troubles[i].trouble}',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
              Positioned(
                left: 50,
                top: 12,
                child: Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  color: Colors.grey.shade50,
                  child: Text(
                    '${troubles[i].employee}',
                    style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }

  DateTime? _findDateFinishPhotosalon(List<HistoryTechnic> historyList, int index) {
    for (int i = index; i >= 0; i--) {
      if (historyList[i].location is PhotosalonLocation) return historyList[i - 1].date;
    }
    return null;
  }
}
