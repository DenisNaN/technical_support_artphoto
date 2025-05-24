import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/models/technic.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/core/shared/technic_image/technic_image.dart';
import 'package:technical_support_artphoto/features/technics/data/models/grid_view_technics_model.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_view.dart';
import '../../../../core/navigation/animation_navigation.dart';

class GridViewTechnics extends StatelessWidget {
  const GridViewTechnics({super.key, required this.location});

  final dynamic location;

  @override
  Widget build(BuildContext context) {
    GridViewTechnicsModel gridViewTechnicsModel =
        filteredTechnics(location.technics, Provider.of<ProviderModel>(context));
    bool isTechnicsDonorsNotZero = false;
    for (var element in gridViewTechnicsModel.mapDonors.values) {
      if(element.isNotEmpty) {
        isTechnicsDonorsNotZero = true;
        break;
      }
    }
    return Scaffold(
        appBar: CustomAppBar(typePage: TypePage.listTechnics, location: location, technic: null),
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          primary: false,
          slivers: [
            for (var technicsNotDonors in gridViewTechnicsModel.mapNotDonors.values)
              SliverPadding(
                padding: EdgeInsets.all(technicsNotDonors.isNotEmpty ? 8 : 0),
                sliver: SliverGrid.builder(
                    itemCount: technicsNotDonors.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (_, int index) {
                      Technic technic = technicsNotDonors[index];
                      bool technicBroken = technic.status == 'Неисправна';
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
                                animationRouteSlideTransition(TechnicView(location: location, technic: technic)));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: technicBroken ? Colors.red.shade50 : Colors.blue.shade50,
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
            for (var technicsDonors in gridViewTechnicsModel.mapDonors.values)
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
                                animationRouteSlideTransition(TechnicView(location: location, technic: technic)));
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
