import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technical_support_artphoto/core/api/data/repositories/technical_support_repo_impl.dart';
import 'package:technical_support_artphoto/core/shared/loader_overlay/loading_overlay.dart';
import 'package:technical_support_artphoto/features/technics/models/technic.dart';
import 'package:technical_support_artphoto/core/api/provider/provider_model.dart';
import 'package:technical_support_artphoto/core/shared/custom_app_bar/custom_app_bar.dart';
import 'package:technical_support_artphoto/core/utils/enums.dart';
import 'package:technical_support_artphoto/core/shared/technic_image/technic_image.dart';
import 'package:technical_support_artphoto/features/technics/presentation/page/technic_view.dart';
import 'package:technical_support_artphoto/features/troubles/models/trouble.dart';
import '../../../../core/navigation/animation_navigation.dart';

class GridViewTechnicsRepair extends StatefulWidget {
  const GridViewTechnicsRepair({super.key, required this.location});

  final dynamic location;

  @override
  State<GridViewTechnicsRepair> createState() => _GridViewTechnicsRepairState();
}

class _GridViewTechnicsRepairState extends State<GridViewTechnicsRepair> {
  @override
  Widget build(BuildContext context) {
    final providerModel = Provider.of<ProviderModel>(context);
    List<Technic> technics = widget.location.technics;
    List<Trouble> troubles = providerModel.getTroubles;
    return Scaffold(
        appBar: CustomAppBar(typePage: TypePage.listTechnics, location: widget.location, technic: null),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async{
              downloadTechnicsClosedRepair(providerModel);
            },
          label: Text('Отремонтированная техника')),
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          primary: false,
          slivers: [
              SliverPadding(
                padding: EdgeInsets.all(technics.isNotEmpty ? 8 : 0),
                sliver: SliverGrid.builder(
                    itemCount: technics.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (_, int index) {
                      Technic technic = technics[index];
                      bool isTroubleHas = false;
                      for(final trouble in troubles){
                        if(technic.number == trouble.numberTechnic){
                          if (trouble.numberTechnic != 0) {
                            isTroubleHas = true;
                          }
                          break;
                        }
                      }
                      return GridTile(
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Row(
                                  children: [
                                    isTroubleHas ? Icon(
                                      Icons.check,
                                      color: Colors.red,
                                    ) : SizedBox(),
                                    Expanded(
                                      child: Text(
                                        technic.category,
                                        style: Theme.of(context).textTheme.titleSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black54, width: 1),
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(technic.number == 0 ? 'БН' :
                                  technic.number.toString()),
                                )),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context,
                                animationRouteSlideTransition(LoadingOverlay(
                                    child: TechnicView(
                                        location: widget.location,
                                        technic: technic))));
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
                                Row(
                                  children: [
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
              title: providerModel.getTechnicsClosedRepair.isNotEmpty
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
                          'История:',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ],
                    )
                  : SizedBox(),
            ),
            SliverPadding(
                padding: EdgeInsets.only(
                    bottom: providerModel.getTechnicsClosedRepair.isNotEmpty ? 14.0 : 0,
                    left: providerModel.getTechnicsClosedRepair.isNotEmpty ? 14.0 : 0,
                    right: providerModel.getTechnicsClosedRepair.isNotEmpty ? 14.0 : 0),
                sliver: SliverGrid.builder(
                    itemCount: providerModel.getTechnicsClosedRepair.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (_, int index) {
                      Technic technic = providerModel.getTechnicsClosedRepair[index];

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
                                animationRouteSlideTransition(LoadingOverlay(child: TechnicView(location: widget.location, technic: technic))));
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

  void downloadTechnicsClosedRepair(ProviderModel providerModel) async{
    LoadingOverlay.of(context).show();
    List<Technic> technicsClosedRepair = await TechnicalSupportRepoImpl.downloadData.getTechnicsFinishedRepairsByRepairman(widget.location.name);
    providerModel.updateTechnicsClosedRepair(technicsClosedRepair);
    if (mounted) {
      LoadingOverlay.of(context).hide();
    }
  }
}
