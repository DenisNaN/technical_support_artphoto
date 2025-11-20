import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/models/photosalon_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/repair_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/storage_location.dart';
import 'package:technical_support_artphoto/core/api/data/models/transportation_location.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/features/technics/models/grid_view_technics_model.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/core/shared/technic_image/technic_image.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_view.dart';
import '../../../../../core/navigation/animation_navigation.dart';

class GridViewSearchTechnics extends StatelessWidget {
  const GridViewSearchTechnics(this.valueTechnic, {super.key, required this.typeSearch});

  final TypeSearch typeSearch;
  final String? valueTechnic;

  @override
  Widget build(BuildContext context) {
    List<Technic> technics =
        getSearchTechnics(typeSearch, valueTechnic ?? '', Provider.of<ProviderModel>(context));
    GridViewTechnicsModel gridViewTechnicsModel =
      filteredTechnics(technics, Provider.of<ProviderModel>(context));
    List<Technic> technicsNotDonors = [];
    List<Technic> technicsDonors = [];
    for (var technicsNotDonorsList in gridViewTechnicsModel.mapNotDonors.values){
      if(technicsNotDonorsList.isNotEmpty){
        technicsNotDonors.addAll(technicsNotDonorsList);
      }
    }
    for (var technicsDonorsList in gridViewTechnicsModel.mapDonors.values){
      if(technicsDonorsList.isNotEmpty){
        technicsDonors.addAll(technicsDonorsList);
      }
    }
    bool isTechnicsDonorsNotZero = technicsDonors.isEmpty ? false : true;
    return Scaffold(
        appBar: CustomAppBar(typePage: TypePage.searchTechnic, location: valueTechnic ?? '', technic: null),
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          primary: false,
          slivers: [
            technicsNotDonors.isEmpty ?
              SliverAppBar(
                leading: SizedBox(),
                title: Text('Работоспособная техника не найдена'),
                centerTitle: true,
              ) :
              SliverPadding(
                padding: EdgeInsets.all(8),
                sliver: SliverGrid.builder(
                    itemCount: technicsNotDonors.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (_, int index) {
                      Technic technic = technicsNotDonors[index];
                      bool isTechnicBroken = technic.status == 'Неисправна';
                      bool isTestDrive = technic.status == 'Тест-драйв';
                      bool isNotDeadlineTestDrive = false;
                      if(technic.testDrive != null && technic.testDrive!.isCloseTestDrive == false &&
                          technic.testDrive!.dateFinish.difference(DateTime.now()).inDays < 0){
                        isNotDeadlineTestDrive = true;
                      }
                      return GridTile(
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Text(
                                  technic.dislocation,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black54, width: 1),
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(technic.number == 0 ? 'БН' :technic.number.toString()),
                                )),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context,
                                animationRouteSlideTransition(LoadingOverlay(
                                    child: TechnicView(location: technic.dislocation, technic: technic))));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isTechnicBroken ? Colors.red.shade50 : isTestDrive ? Colors.yellow.shade50 : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade500,
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(technic.category),
                                      Expanded(child: TechnicImage(category: technic.category)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    isNotDeadlineTestDrive ? Icon(Icons.error, color: Colors.red.shade400,) : SizedBox(),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          technic.name == '' ? 'Модель не указана' : technic.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            SliverAppBar(
              backgroundColor: Colors.grey.shade50,
              automaticallyImplyLeading: false,
              title: isTechnicsDonorsNotZero
                  ? Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 2,
                    decoration: BoxDecoration(color: Colors.black),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'Доноры:',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ],
              )
                  : SizedBox(),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                  bottom: technicsDonors.isNotEmpty ? 14.0 : 0,
                  left: technicsDonors.isNotEmpty ? 14.0 : 0,
                  right: technicsDonors.isNotEmpty ? 14.0 : 0),
              sliver: SliverGrid.builder(
                  itemCount: technicsDonors.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (_, int index) {
                    Technic technic = technicsDonors[index];

                    return GridTile(
                      header: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                technic.category,
                                style: Theme.of(context).textTheme.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54, width: 1),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(technic.number.toString()),
                              )),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context,
                              animationRouteSlideTransition(LoadingOverlay(child: TechnicView(location: technic.dislocation, technic: technic))));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Expanded(child: TechnicImage(category: technic.category)),
                              Padding(
                                padding: const EdgeInsets.only(left: 4, right: 2),
                                child: Text(
                                  technic.name == '' ? 'Модель не указана' : technic.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ));
  }

  List<Technic> getSearchTechnics(TypeSearch typeSearch, String valueTechnic, ProviderModel provider) {
    List<Technic> technics = [];
    Map<String, PhotosalonLocation> techPhoto = provider.technicsInPhotosalons;
    Map<String, RepairLocation> techRep = provider.technicsInRepairs;
    Map<String, StorageLocation> techStor = provider.technicsInStorages;
    Map<String, TransportationLocation> techTransp = provider.technicsInTransportation;
    Iterable<PhotosalonLocation> photosalonLocation = techPhoto.values;
    Iterable<RepairLocation> repairLocation = techRep.values;
    Iterable<StorageLocation> storageLocation = techStor.values;
    Iterable<TransportationLocation> transportationLocation = techTransp.values;
    List<Technic> tmpTechnics = [];
    for (var element in photosalonLocation) {
      tmpTechnics.addAll(element.technics);
    }
    for (var element in repairLocation) {
      tmpTechnics.addAll(element.technics);
    }
    for (var element in storageLocation) {
      tmpTechnics.addAll(element.technics);
    }
    for (var element in transportationLocation) {
      tmpTechnics.addAll(element.technics);
    }

    for (var technic in tmpTechnics) {
      switch(typeSearch){
        case TypeSearch.searchByName:
          if(technic.name.trim().toLowerCase().contains(valueTechnic.trim().toLowerCase())){
            technics.add(technic);
          }
        case TypeSearch.filterByStatus:
          if(technic.status.trim().toLowerCase().contains(valueTechnic.trim().toLowerCase())){
            technics.add(technic);
          }
        case TypeSearch.filterByCategory:
          if(technic.category.trim().toLowerCase().contains(valueTechnic.trim().toLowerCase())){
            technics.add(technic);
          }
      }
    }
    return technics;
  }

  GridViewTechnicsModel filteredTechnics(List<Technic> list, ProviderModel provider) {
    GridViewTechnicsModel gridViewTechnicsModel = GridViewTechnicsModel();
    List<Technic> listNotDonors = [];
    List<Technic> listDonors = [];
    List<String> namesEquipments = provider.namesEquipments;

    for (int i = 0; i < list.length; i++) {
      if (list[i].status != 'Донор') {
        listNotDonors.add(list[i]);
      } else {
        listDonors.add(list[i]);
      }
    }

    //filter for namesEquipments
    for (var elementNamesEquipments in namesEquipments) {
      gridViewTechnicsModel.mapNotDonors[elementNamesEquipments] = <Technic>[];
      gridViewTechnicsModel.mapDonors[elementNamesEquipments] = <Technic>[];

      for (var elementListNotDonors in listNotDonors) {
        if (elementListNotDonors.category == elementNamesEquipments) {
          gridViewTechnicsModel.mapNotDonors[elementNamesEquipments]?.add(elementListNotDonors);
        }
      }
      for (var elementListDonors in listDonors) {
        if (elementListDonors.category == elementNamesEquipments) {
          gridViewTechnicsModel.mapDonors[elementNamesEquipments]?.add(elementListDonors);
        }
      }
    }
    return gridViewTechnicsModel;
  }
}
